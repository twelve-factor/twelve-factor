#!/usr/bin/env bash
# Twelve-Factor Skill Context Bus
# Unified interface for multiple storage backends (json|sqlite|redis|graph)

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUS_CFG="${BUS_CFG:-$SCRIPT_DIR/../bus.config.yaml}"
BACKEND="${BUS_BACKEND:-json}"

# Paths (extracted from config or defaults)
JSON_PATH="${JSON_PATH:-./.claude/bus/twelve-factor-context.jsonl}"
SQLITE_PATH="${SQLITE_PATH:-./.claude/bus/twelve-factor-context.db}"
REDIS_URL="${REDIS_URL:-redis://localhost:6379/0}"

# Ensure directories exist
mkdir -p "$(dirname "$JSON_PATH")"
mkdir -p "$(dirname "$SQLITE_PATH")"
[ -f "$JSON_PATH" ] || touch "$JSON_PATH"

# Timestamp helper
ts_now() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# ============================================================================
# Event Publishing (write events to bus)
# ============================================================================
publish_event() {
    local topic="$1"
    shift
    local payload="$*"

    # Create event JSON
    local evt
    evt="$(jq -cn \
        --arg t "$topic" \
        --arg ts "$(ts_now)" \
        --argjson p "$payload" \
        '{topic:$t, ts:$ts, payload:$p}')"

    case "$BACKEND" in
        json)
            echo "$evt" >> "$JSON_PATH"
            ;;
        sqlite)
            local ts=$(ts_now)
            local payload_clean=$(printf "%s" "$payload" | jq -c .)
            sqlite3 "$SQLITE_PATH" <<SQL
CREATE TABLE IF NOT EXISTS events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ts TEXT NOT NULL,
    topic TEXT NOT NULL,
    payload TEXT NOT NULL
);
INSERT INTO events (ts, topic, payload) VALUES ('${ts}', '${topic}', '${payload_clean}');
SQL
            ;;
        redis)
            if command -v redis-cli >/dev/null 2>&1; then
                echo "$evt" | redis-cli -u "$REDIS_URL" -x PUBLISH "$topic" >/dev/null 2>&1 || true
            else
                echo "⚠️  redis-cli not found, event not published" >&2
            fi
            ;;
        *)
            echo "❌ Unknown backend: $BACKEND" >&2
            return 1
            ;;
    esac
}

# ============================================================================
# Event Reading (query events from bus)
# ============================================================================
read_events() {
    local topic="${1:-}"
    local limit="${2:-100}"

    case "$BACKEND" in
        json)
            if [ -n "$topic" ]; then
                jq -c "select(.topic == \"$topic\")" "$JSON_PATH" | tail -n "$limit"
            else
                tail -n "$limit" "$JSON_PATH"
            fi
            ;;
        sqlite)
            local where_clause=""
            [ -n "$topic" ] && where_clause="WHERE topic = '$topic'"

            sqlite3 "$SQLITE_PATH" <<SQL
CREATE TABLE IF NOT EXISTS events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ts TEXT NOT NULL,
    topic TEXT NOT NULL,
    payload TEXT NOT NULL
);
SELECT json_object(
    'topic', topic,
    'ts', ts,
    'payload', json(payload)
) FROM events
$where_clause
ORDER BY id DESC
LIMIT $limit;
SQL
            ;;
        redis)
            echo "ℹ️  Reading events not supported in redis mode (pub/sub only)" >&2
            ;;
        *)
            echo "❌ Unknown backend: $BACKEND" >&2
            return 1
            ;;
    esac
}

# ============================================================================
# Key-Value Storage (shared state between skills)
# ============================================================================
get_kv() {
    local key="$1"

    case "$BACKEND" in
        json)
            jq -c "select(.topic == \"kv.set\" and .payload.key == \"$key\")" "$JSON_PATH" | \
                tail -n1 | \
                jq -r '.payload.value // empty'
            ;;
        sqlite)
            sqlite3 "$SQLITE_PATH" <<SQL
CREATE TABLE IF NOT EXISTS kv (
    k TEXT PRIMARY KEY,
    v TEXT NOT NULL,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);
SELECT v FROM kv WHERE k = '$key';
SQL
            ;;
        redis)
            if command -v redis-cli >/dev/null 2>&1; then
                redis-cli -u "$REDIS_URL" GET "kv:$key" 2>/dev/null || echo ""
            fi
            ;;
        *)
            echo "❌ Unknown backend: $BACKEND" >&2
            return 1
            ;;
    esac
}

put_kv() {
    local key="$1"
    local value="$2"

    case "$BACKEND" in
        json)
            local evt=$(jq -cn \
                --arg k "$key" \
                --arg v "$value" \
                --arg ts "$(ts_now)" \
                '{topic:"kv.set", ts:$ts, payload:{key:$k, value:$v}}')
            echo "$evt" >> "$JSON_PATH"
            ;;
        sqlite)
            sqlite3 "$SQLITE_PATH" <<SQL
CREATE TABLE IF NOT EXISTS kv (
    k TEXT PRIMARY KEY,
    v TEXT NOT NULL,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO kv (k, v) VALUES ('$key', '$value')
    ON CONFLICT(k) DO UPDATE SET v = excluded.v, updated_at = CURRENT_TIMESTAMP;
SQL
            ;;
        redis)
            if command -v redis-cli >/dev/null 2>&1; then
                redis-cli -u "$REDIS_URL" SET "kv:$key" "$value" >/dev/null 2>&1
            fi
            ;;
        *)
            echo "❌ Unknown backend: $BACKEND" >&2
            return 1
            ;;
    esac
}

# ============================================================================
# Status/Health Check
# ============================================================================
bus_health() {
    echo "🔍 Context Bus Health Check"
    echo "Backend: $BACKEND"

    case "$BACKEND" in
        json)
            if [ -f "$JSON_PATH" ]; then
                local count=$(wc -l < "$JSON_PATH")
                echo "✓ JSON backend operational"
                echo "  Events: $count"
                echo "  File: $JSON_PATH"
            else
                echo "⚠️  JSON file not found"
            fi
            ;;
        sqlite)
            if command -v sqlite3 >/dev/null 2>&1; then
                local count=$(sqlite3 "$SQLITE_PATH" "SELECT COUNT(*) FROM events;" 2>/dev/null || echo "0")
                echo "✓ SQLite backend operational"
                echo "  Events: $count"
                echo "  DB: $SQLITE_PATH"
            else
                echo "❌ sqlite3 not installed"
            fi
            ;;
        redis)
            if command -v redis-cli >/dev/null 2>&1; then
                if redis-cli -u "$REDIS_URL" PING >/dev/null 2>&1; then
                    echo "✓ Redis backend operational"
                    echo "  URL: ${REDIS_URL%%@*}@***"
                else
                    echo "❌ Redis connection failed"
                fi
            else
                echo "❌ redis-cli not installed"
            fi
            ;;
    esac
}

# ============================================================================
# CLI Interface
# ============================================================================
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    case "${1:-help}" in
        publish)
            shift
            topic="${1:-}"
            shift || true
            payload="${*:-{}}"
            [ -z "$topic" ] && { echo "Usage: bus.sh publish <topic> <json-payload>"; exit 1; }
            publish_event "$topic" "$payload"
            echo "✓ Event published to $topic"
            ;;
        read)
            topic="${2:-}"
            limit="${3:-10}"
            read_events "$topic" "$limit"
            ;;
        get)
            key="${2:-}"
            [ -z "$key" ] && { echo "Usage: bus.sh get <key>"; exit 1; }
            get_kv "$key"
            ;;
        put)
            key="${2:-}"
            value="${3:-}"
            [ -z "$key" ] || [ -z "$value" ] && { echo "Usage: bus.sh put <key> <value>"; exit 1; }
            put_kv "$key" "$value"
            echo "✓ Stored $key = $value"
            ;;
        health)
            bus_health
            ;;
        *)
            cat <<HELP
Twelve-Factor Context Bus - Usage

Commands:
  publish <topic> <json>  Publish event to topic
  read [topic] [limit]    Read events (optionally filtered by topic)
  get <key>               Get value from KV store
  put <key> <value>       Put value to KV store
  health                  Check bus health

Environment:
  BUS_BACKEND            Backend type: json|sqlite|redis (default: json)
  JSON_PATH              Path to JSON file (json backend)
  SQLITE_PATH            Path to SQLite DB (sqlite backend)
  REDIS_URL              Redis connection URL (redis backend)

Examples:
  bus.sh publish twelve-factor.compliance '{"status":"ok","violations":0}'
  bus.sh read twelve-factor.compliance 5
  bus.sh put last_check_date "2025-11-19"
  bus.sh get last_check_date
  bus.sh health
HELP
            ;;
    esac
fi
