# Twelve-Factor App Compliance Checklist

Use this checklist to quickly assess whether your application follows twelve-factor principles.

## I. Codebase ✓
- [ ] App is tracked in version control (Git, Mercurial, Subversion)
- [ ] One-to-one correlation: one codebase per app
- [ ] Shared code is extracted to libraries, not shared as codebase
- [ ] Same codebase deploys to dev, staging, and production

## II. Dependencies ✓
- [ ] All dependencies explicitly declared in manifest
  - Node.js: `package.json`
  - Python: `requirements.txt` or `Pipfile`
  - Ruby: `Gemfile`
  - Go: `go.mod`
  - Java: `pom.xml` or `build.gradle`
- [ ] Dependency isolation is used
  - Node.js: `node_modules`
  - Python: `virtualenv` or `venv`
  - Ruby: `bundle exec`
  - Go: Go modules
- [ ] No reliance on implicit system packages
- [ ] System tools are vendored if needed (ImageMagick, curl, etc.)

## III. Config ✓
- [ ] Config is stored in environment variables
- [ ] No credentials or secrets in code
- [ ] No environment-specific config files checked into repo
- [ ] Litmus test: Could make repo public without exposing credentials?
- [ ] Env vars are granular, not grouped by environment
- [ ] Internal app config (routes, DI) stays in code

**Anti-patterns to avoid:**
- ❌ Hardcoded API keys or passwords
- ❌ Config files like `config/database.yml`
- ❌ Grouped environments (development, test, production constants)

## IV. Backing Services ✓
- [ ] All backing services accessed via URL/connection string
- [ ] Connection strings stored in environment variables
- [ ] No code distinction between local and third-party services
- [ ] Can swap services by changing config only (no code changes)

**Examples of backing services:**
- Databases (PostgreSQL, MySQL, MongoDB)
- Message queues (RabbitMQ, Kafka, SQS)
- Caches (Redis, Memcached)
- SMTP services
- APIs

## V. Build, Release, Run ✓
- [ ] Build stage: Dependencies fetched, binaries compiled
- [ ] Release stage: Build + config combined
- [ ] Run stage: Processes launched from release
- [ ] Clear separation between three stages
- [ ] Each release has unique ID (timestamp or version number)
- [ ] Releases are immutable (append-only)
- [ ] Can rollback to previous releases
- [ ] No code changes possible at runtime

## VI. Processes ✓
- [ ] Processes are stateless
- [ ] Processes share nothing
- [ ] No in-memory session storage
- [ ] No sticky sessions
- [ ] Persistent data stored in backing services
- [ ] Memory/filesystem used only for brief, single-transaction cache
- [ ] Session state in external store (Redis, Memcached)

**Anti-patterns to avoid:**
- ❌ Storing sessions in process memory
- ❌ Requiring sticky sessions
- ❌ Assuming files written to disk persist
- ❌ Caching beyond single transaction

## VII. Port Binding ✓
- [ ] App is self-contained
- [ ] Web server is a dependency, not injected by runtime
- [ ] App binds to port specified in environment variable
- [ ] App exports HTTP (or other protocol) as a service
- [ ] No reliance on runtime webserver injection (Apache, Tomcat)

**Web server libraries:**
- Node.js: Express, Koa, Fastify
- Python: Flask, Django, FastAPI
- Ruby: Sinatra, Thin, Puma
- Java: Jetty, embedded Tomcat
- Go: net/http

## VIII. Concurrency ✓
- [ ] Processes are first-class citizens
- [ ] Different process types for different workloads
  - `web`: HTTP requests
  - `worker`: Background jobs
  - `cron`: Scheduled tasks
- [ ] App scales horizontally by running more processes
- [ ] Processes never daemonize
- [ ] No PID files written
- [ ] Rely on OS process manager (systemd, supervisord, etc.)

## IX. Disposability ✓
- [ ] Processes can start/stop quickly
- [ ] Startup time is seconds, not minutes
- [ ] Processes handle SIGTERM gracefully
- [ ] Web processes: finish current requests before exit
- [ ] Worker processes: return jobs to queue on shutdown
- [ ] Jobs are reentrant (can be interrupted and restarted)
- [ ] Jobs are idempotent (safe to run multiple times)
- [ ] App is robust against sudden crashes

## X. Dev/Prod Parity ✓
- [ ] Time gap is small (hours, not weeks between deploys)
- [ ] Personnel gap is small (developers deploy their own code)
- [ ] Tools gap is small (same backing services in all environments)
- [ ] **Same database** in dev and prod (e.g., PostgreSQL everywhere)
- [ ] **Same cache** in dev and prod (e.g., Redis everywhere)
- [ ] **Same queue** in dev and prod (e.g., RabbitMQ everywhere)
- [ ] Local dev environment closely matches production

**Anti-patterns to avoid:**
- ❌ SQLite in dev, PostgreSQL in prod
- ❌ In-memory cache in dev, Redis in prod
- ❌ Different message queue implementations
- ❌ Weeks between code commit and production deploy

## XI. Logs ✓
- [ ] App writes logs to stdout
- [ ] Logs are unbuffered
- [ ] App doesn't manage log files
- [ ] App doesn't route or store its own logs
- [ ] One event per line (except multi-line stack traces)
- [ ] Execution environment captures and routes logs
- [ ] In dev: view logs in terminal
- [ ] In prod: logs sent to aggregation system (ELK, Splunk, etc.)

**Anti-patterns to avoid:**
- ❌ Writing to log files directly
- ❌ Log rotation code in app
- ❌ Buffered logging
- ❌ App managing log storage

## XII. Admin Processes ✓
- [ ] Admin tasks are part of codebase
- [ ] Admin tasks run in identical environment as app
- [ ] Same dependencies for admin and app processes
- [ ] Same config (env vars) for admin tasks
- [ ] Admin tasks run against specific release
- [ ] One-off scripts version controlled with app

**Examples of admin tasks:**
- Database migrations
- REPL/console sessions
- One-time data fix scripts
- Seed data scripts

---

## Quick Compliance Score

Count your checkmarks and calculate compliance percentage:

- **90-100%**: Excellent twelve-factor compliance
- **75-89%**: Good compliance with room for improvement
- **60-74%**: Moderate compliance, focus on failing factors
- **Below 60%**: Significant improvements needed

## Priority Recommendations

If you can't implement everything at once, prioritize these high-impact factors:

1. **Config (III)**: Get secrets out of code immediately
2. **Dependencies (II)**: Ensure reproducible builds
3. **Backing Services (IV)**: Enable easy service swapping
4. **Processes (VI)**: Remove state for horizontal scaling
5. **Dev/Prod Parity (X)**: Prevent "works on my machine" issues
