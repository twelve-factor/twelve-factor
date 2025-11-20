#!/usr/bin/env bash
# Shared Context Bus - Multi-backend data exchange for skills
# Supports: JSON (file), SQLite, Redis, Neo4j Graph
set -euo pipefail

# Configuration
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"
SKILL_DIR="${SKILL_DIR:-$ROOT/.claude/skills/twelve-factor-methodology}"
BUS_CFG="${BUS_CFG:-$SKILL_DIR/templates/bus.config.yaml}"
BACKEND="${BUS_BACKEND:-json}"

# Paths (extracted from config)
if command -v yq >/dev/null 2>&1; then
  JSON_PATH="$ROOT/$(yq eval '.json.path' "$BUS_CFG" 2>/dev/null || echo "context/bus/shared-context.jsonl")"
  EVENTS_PATH="$ROOT/$(yq eval '.json.events_path' "$BUS_CFG" 2>/dev/null || echo "context/events.log")"
  SQLITE_PATH="$ROOT/$(yq eval '.sqlite.path' "$BUS_CFG" 2>/dev/null || echo "context/bus/shared-context.db")"
  REDIS_URL="$(yq eval '.redis.url' "$BUS_CFG" 2>/dev/null || echo "redis://localhost:6379/0")"
else
  # Fallback if yq not available
  JSON_PATH="$ROOT/context/bus/shared-context.jsonl"
  EVENTS_PATH="$ROOT/context/events.log"
  SQLITE_PATH="$ROOT/context/bus/shared-context.db"
  REDIS_URL="${REDIS_URL:-redis://localhost:6379/0}"
fi

# Ensure directories exist
mkdir -p "$(dirname "$JSON_PATH")" "$(dirname "$EVENTS_PATH")" "$(dirname "$SQLITE_PATH")"
touch "$JSON_PATH" "$EVENTS_PATH" 2>/dev/null || true

# Utility: ISO 8601 timestamp
ts_now() {
  date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "$(date -u)"
}

# Utility: JSON sanitization (remove sensitive data)
sanitize_json() {
  local payload="$1"
  if command -v jq >/dev/null 2>&1; then
    echo "$payload" | jq 'walk(if type == "object" then
      with_entries(if .key | test("password|secret|api[_-]?key|auth[_-]?token|private[_-]?key"; "i") then .value = "***REDACTED***" else . end)
    else . end)'
  else
    echo "$payload"
  fi
}

# ============================================================================
# PUBLISH EVENT
# Usage: publish_event <topic> <json_payload>
# ============================================================================
publish_event() {
  local topic="$1"
  shift
  local payload="$*"
  local evt

  # Sanitize if security enabled
  if [[ "${SECURITY_LOG_SANITIZATION:-true}" == "true" ]]; then
    payload="$(sanitize_json "$payload")"
  fi

  evt="$(jq -cn \
    --arg t "$topic" \
    --arg ts "$(ts_now)" \
    --argjson p "$payload" \
    '{topic:$t, ts:$ts, payload:$p}')"

  case "$BACKEND" in
    json)
      echo "$evt" >> "$EVENTS_PATH"
      ;;

    sqlite)
      if command -v sqlite3 >/dev/null 2>&1; then
        sqlite3 "$SQLITE_PATH" <<SQL
CREATE TABLE IF NOT EXISTS events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ts TEXT NOT NULL,
  topic TEXT NOT NULL,
  payload TEXT NOT NULL
);
INSERT INTO events (ts, topic, payload) VALUES (
  '$(ts_now)',
  '$topic',
  '$(echo "$payload" | jq -c .)'
);
SQL
      else
        echo "ERROR: sqlite3 not found" >&2
        return 1
      fi
      ;;

    redis)
      if command -v redis-cli >/dev/null 2>&1; then
        redis-cli -u "$REDIS_URL" PUBLISH "$topic" "$evt" >/dev/null
      else
        echo "ERROR: redis-cli not found" >&2
        return 1
      fi
      ;;

    graph)
      echo "WARN: Graph backend not yet implemented, falling back to JSON" >&2
      echo "$evt" >> "$EVENTS_PATH"
      ;;

    *)
      echo "ERROR: Unknown backend: $BACKEND" >&2
      return 1
      ;;
  esac
}

# ============================================================================
# READ EVENTS
# Usage: read_events [topic_filter] [limit]
# ============================================================================
read_events() {
  local topic_filter="${1:-.*}"
  local limit="${2:-100}"

  case "$BACKEND" in
    json)
      if command -v jq >/dev/null 2>&1; then
        jq -c "select(.topic | test(\"$topic_filter\"))" "$EVENTS_PATH" 2>/dev/null | tail -n "$limit"
      else
        grep -E "\"topic\":\".*$topic_filter.*\"" "$EVENTS_PATH" 2>/dev/null | tail -n "$limit" || true
      fi
      ;;

    sqlite)
      if command -v sqlite3 >/dev/null 2>&1; then
        sqlite3 "$SQLITE_PATH" <<SQL
SELECT json_object('topic', topic, 'ts', ts, 'payload', json(payload))
FROM events
WHERE topic LIKE '%$topic_filter%'
ORDER BY id DESC
LIMIT $limit;
SQL
      fi
      ;;

    redis)
      echo "WARN: Redis read_events requires subscription, use JSON fallback" >&2
      read_events "$topic_filter" "$limit"
      ;;

    *)
      echo "ERROR: Unknown backend: $BACKEND" >&2
      return 1
      ;;
  esac
}

# ============================================================================
# KEY-VALUE STORE: PUT
# Usage: put_kv <key> <json_value>
# ============================================================================
put_kv() {
  local key="$1"
  local value="$2"

  case "$BACKEND" in
    json)
      publish_event "kv.set" "$(jq -cn --arg k "$key" --argjson v "$value" '{key:$k, value:$v}')"
      ;;

    sqlite)
      if command -v sqlite3 >/dev/null 2>&1; then
        sqlite3 "$SQLITE_PATH" <<SQL
CREATE TABLE IF NOT EXISTS kv (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
INSERT INTO kv (key, value, updated_at) VALUES (
  '$key',
  '$(echo "$value" | jq -c .)',
  '$(ts_now)'
)
ON CONFLICT(key) DO UPDATE SET
  value = excluded.value,
  updated_at = excluded.updated_at;
SQL
      fi
      ;;

    redis)
      if command -v redis-cli >/dev/null 2>&1; then
        redis-cli -u "$REDIS_URL" SET "kv:$key" "$value" >/dev/null
      fi
      ;;

    *)
      echo "ERROR: Unknown backend: $BACKEND" >&2
      return 1
      ;;
  esac
}

# ============================================================================
# KEY-VALUE STORE: GET
# Usage: get_kv <key>
# ============================================================================
get_kv() {
  local key="$1"

  case "$BACKEND" in
    json)
      if command -v jq >/dev/null 2>&1; then
        jq -c "select(.topic==\"kv.set\" and .payload.key==\"$key\")" "$EVENTS_PATH" 2>/dev/null \
          | tail -n1 \
          | jq -r '.payload.value // empty'
      fi
      ;;

    sqlite)
      if command -v sqlite3 >/dev/null 2>&1; then
        sqlite3 "$SQLITE_PATH" "SELECT value FROM kv WHERE key='$key' LIMIT 1;" 2>/dev/null || true
      fi
      ;;

    redis)
      if command -v redis-cli >/dev/null 2>&1; then
        redis-cli -u "$REDIS_URL" GET "kv:$key" 2>/dev/null || true
      fi
      ;;

    *)
      echo "ERROR: Unknown backend: $BACKEND" >&2
      return 1
      ;;
  esac
}

# ============================================================================
# SELF-TEST
# Usage: bus_selftest
# ============================================================================
bus_selftest() {
  echo "=== Bus Self-Test ==="
  echo "Backend: $BACKEND"
  echo "Events: $EVENTS_PATH"

  # Test publish
  publish_event "test.ping" '{"msg":"hello","ts":"'$(ts_now)'"}'

  # Test KV
  put_kv "test.key" '{"status":"ok"}'
  local val
  val="$(get_kv "test.key")"

  if [[ -n "$val" ]]; then
    echo "✓ KV store working: $val"
  else
    echo "✗ KV store failed"
    return 1
  fi

  # Test read
  local events
  events="$(read_events "test\\.ping" 1)"
  if [[ -n "$events" ]]; then
    echo "✓ Event read working"
  else
    echo "✗ Event read failed"
    return 1
  fi

  echo "=== All tests passed ==="
}

# ============================================================================
# CLI Interface
# ============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  case "${1:-help}" in
    publish)
      shift
      publish_event "$@"
      ;;
    get)
      get_kv "$2"
      ;;
    put)
      put_kv "$2" "$3"
      ;;
    read)
      read_events "${2:-.*}" "${3:-10}"
      ;;
    selftest)
      bus_selftest
      ;;
    help|*)
      cat <<HELP
Usage: bus.sh <command> [args...]

Commands:
  publish <topic> <json>   Publish event to bus
  get <key>                Get value from KV store
  put <key> <json>         Put value to KV store
  read [topic] [limit]     Read events (default: last 10)
  selftest                 Run self-test

Environment:
  BUS_BACKEND              Backend type: json|sqlite|redis|graph
  BUS_CFG                  Path to bus.config.yaml

Examples:
  ./bus.sh publish "skill.run" '{"skill":"twelve-factor","action":"audit"}'
  ./bus.sh put "project.name" '"my-app"'
  ./bus.sh get "project.name"
  ./bus.sh read "skill\\." 5
HELP
      ;;
  esac
fi
