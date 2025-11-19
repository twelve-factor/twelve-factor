# Twelve-Factor Compliance Checklist

Use this checklist for quick compliance verification. Check off items as you verify them in the codebase.

## I. Codebase
**One codebase tracked in revision control, many deploys**

- [ ] Application uses version control (Git, Mercurial, etc.)
- [ ] Single repository per application
- [ ] Shared code extracted to libraries (not duplicated across repos)
- [ ] Clear separation between different applications
- [ ] Same codebase deployed to all environments

**Common files to check:**
- `.git/` directory exists
- `README.md` or `CONTRIBUTING.md` references repository
- No duplicate codebases for different environments

---

## II. Dependencies
**Explicitly declare and isolate dependencies**

- [ ] Dependency manifest file exists
  - Python: `requirements.txt`, `Pipfile`, or `pyproject.toml`
  - Node.js: `package.json`
  - Ruby: `Gemfile`
  - Java: `pom.xml` or `build.gradle`
  - Go: `go.mod`
  - Rust: `Cargo.toml`
- [ ] All dependencies explicitly declared
- [ ] No reliance on system-wide packages
- [ ] Dependency isolation configured (virtualenv, bundler, npm, etc.)
- [ ] Lock file present for reproducible builds
  - Python: `requirements.txt` with exact versions or `Pipfile.lock`
  - Node.js: `package-lock.json` or `yarn.lock`
  - Ruby: `Gemfile.lock`
  - Go: `go.sum`

**Commands to verify:**
```bash
# Python
ls requirements.txt Pipfile pyproject.toml 2>/dev/null

# Node.js
ls package.json package-lock.json 2>/dev/null

# Ruby
ls Gemfile Gemfile.lock 2>/dev/null

# Go
ls go.mod go.sum 2>/dev/null
```

---

## III. Config
**Store config in the environment**

- [ ] No credentials in source code
- [ ] No environment-specific config files checked in
- [ ] All config in environment variables
  - Database URLs
  - API keys and secrets
  - Service credentials
  - Feature flags
  - Resource handles
- [ ] `.env` files in `.gitignore`
- [ ] `.env.example` or similar template provided
- [ ] Config validated at application startup
- [ ] Environment variables not grouped by environment

**Files to check:**
```bash
# Good signs
ls .env.example .env.template config.example.yml 2>/dev/null
grep -r "os.environ\|process.env\|ENV\[" . 2>/dev/null | head -5

# Bad signs (should return nothing)
grep -r "password.*=.*['\"]" --include="*.py" --include="*.js" . 2>/dev/null
grep -r "api_key.*=.*['\"]" --include="*.py" --include="*.js" . 2>/dev/null
```

**Red flags:**
- Files like `config/production.yml`, `config/staging.yml` with different credentials
- Hardcoded database passwords or API keys
- Different config mechanisms for different environments

---

## IV. Backing Services
**Treat backing services as attached resources**

- [ ] Databases accessed via URL from config
- [ ] Cache services accessed via URL from config
- [ ] Message queues accessed via URL from config
- [ ] External APIs accessed via config
- [ ] No distinction in code between local and third-party services
- [ ] Services can be swapped without code changes
- [ ] No hard-coded hostnames or IPs

**Code patterns to check:**
```bash
# Good - URL-based connections
grep -r "DATABASE_URL\|REDIS_URL\|RABBITMQ_URL" . 2>/dev/null

# Bad - hard-coded hosts (should be minimal)
grep -r "localhost\|127.0.0.1" --include="*.py" --include="*.js" . 2>/dev/null
```

---

## V. Build, Release, Run
**Strictly separate build and run stages**

- [ ] Distinct build process exists
- [ ] Build produces deployable artifact
  - Docker image
  - JAR/WAR file
  - Compiled binary
  - Packaged application
- [ ] Releases have unique identifiers (version, commit hash, timestamp)
- [ ] No code compilation in production
- [ ] Can rollback to previous releases
- [ ] Build is reproducible

**Files to check:**
```bash
# Build configuration
ls Dockerfile Makefile build.sh package.json setup.py 2>/dev/null

# CI/CD configuration
ls .github/workflows/* .gitlab-ci.yml .circleci/config.yml Jenkinsfile 2>/dev/null
```

**Anti-patterns to look for:**
- `git pull` in production deployment scripts
- `npm install` or `pip install` in production (without lock files)
- Code compilation during deployment

---

## VI. Processes
**Execute the app as one or more stateless processes**

- [ ] Processes are stateless
- [ ] No local state stored between requests
- [ ] Session state in backing service (Redis, Memcached, database)
- [ ] No reliance on memory cache for permanent data
- [ ] No sticky sessions required
- [ ] File uploads go to backing service (S3, Cloud Storage)
- [ ] No assumption of single-server deployment

**Code to examine:**
```bash
# Session storage - should use backing service
grep -r "session\|SESSION" --include="*.py" --include="*.js" . 2>/dev/null | head -10

# File operations - check if using local filesystem for permanent storage
grep -r "open(.*'w'\|fs.writeFile\|File.write" --include="*.py" --include="*.js" --include="*.rb" . 2>/dev/null
```

**Red flags:**
- In-memory session storage
- Writing files to `/tmp` or local directories for permanent storage
- Global variables holding request-specific state
- Requirement for sticky sessions in load balancer

---

## VII. Port Binding
**Export services via port binding**

- [ ] Application binds to port specified by environment variable
- [ ] Self-contained web server (not requiring separate web server)
- [ ] No runtime injection of web server
- [ ] Application can act as backing service for another app
- [ ] Multiple instances can run on different ports

**Code to check:**
```bash
# Port binding from environment
grep -r "PORT\|port.*=.*os.environ\|port.*=.*process.env" . 2>/dev/null

# Self-contained server
grep -r "app.listen\|app.run\|http.ListenAndServe" --include="*.py" --include="*.js" --include="*.go" . 2>/dev/null
```

**Good signs:**
- `app.run(port=int(os.environ.get('PORT')))`
- `app.listen(process.env.PORT || 3000)`
- Procfile with `web:` process type

**Bad signs:**
- Hard-coded port numbers
- Requirement for Apache/nginx as runtime dependency
- No port configuration flexibility

---

## VIII. Concurrency
**Scale out via the process model**

- [ ] Multiple process types defined (web, worker, scheduler)
- [ ] Processes can be scaled independently
- [ ] Work distributed via process model, not threads
- [ ] Background jobs in separate worker processes
- [ ] Process manager can handle different process types
- [ ] Designed for horizontal scaling

**Files to check:**
```bash
# Procfile defining process types
cat Procfile 2>/dev/null

# Worker/job definitions
ls -la workers/ jobs/ tasks.py celery.py 2>/dev/null
```

**Good patterns:**
```
Procfile:
web: gunicorn app:app
worker: celery -A tasks worker
scheduler: celery -A tasks beat
```

**Red flags:**
- All work done in single process type
- Background jobs blocking web requests
- No separation of concerns by process type

---

## IX. Disposability
**Maximize robustness with fast startup and graceful shutdown**

- [ ] Startup time < 10 seconds (preferably < 5 seconds)
- [ ] Graceful shutdown on SIGTERM
- [ ] No data loss on process termination
- [ ] Worker processes requeue jobs on shutdown
- [ ] Processes can crash and restart safely
- [ ] No long-running transactions or operations that can't be interrupted

**Code to check:**
```bash
# Shutdown handlers
grep -r "SIGTERM\|SIGINT\|signal.signal\|process.on.*SIGTERM" . 2>/dev/null

# Startup code - should be minimal
```

**Test:**
```bash
# Measure startup time
time docker run myapp /bin/sh -c "exit 0"

# Test graceful shutdown
# Start app, send SIGTERM, verify cleanup
```

**Red flags:**
- Startup initialization taking minutes
- No signal handlers
- Writing to local files without proper cleanup
- Long-running database transactions

---

## X. Dev/Prod Parity
**Keep development, staging, and production as similar as possible**

- [ ] Same backing services in dev and prod (PostgreSQL, Redis, etc.)
- [ ] No lightweight alternatives in development (SQLite vs PostgreSQL)
- [ ] Same OS/platform in dev and prod (use Docker)
- [ ] Short deployment cycle (hours or days, not weeks)
- [ ] Developers can deploy to production
- [ ] Same versions of dependencies across environments

**Check:**
```bash
# Docker setup for dev parity
ls docker-compose.yml Dockerfile 2>/dev/null

# Database - should be same in dev and prod
grep -i "sqlite\|postgres\|mysql\|mongodb" docker-compose.yml README.md 2>/dev/null
```

**Anti-patterns:**
- SQLite in development, PostgreSQL in production
- Different OS in development (Windows/Mac) vs production (Linux)
- Only ops team can deploy
- Months between deployments
- Different library versions in different environments

---

## XI. Logs
**Treat logs as event streams**

- [ ] Writing to stdout/stderr
- [ ] Not managing log files
- [ ] Not configuring log rotation in app
- [ ] Structured logging (JSON) for parsing
- [ ] Log aggregation handled by execution environment
- [ ] Consistent log format across all process types

**Code to check:**
```bash
# Logging to stdout
grep -r "logging.basicConfig\|console.log\|logger\|print" --include="*.py" --include="*.js" . 2>/dev/null | head -10

# Bad: File logging (should return nothing)
grep -r "FileHandler\|RotatingFileHandler\|createWriteStream.*log" --include="*.py" --include="*.js" . 2>/dev/null
```

**Good patterns:**
- `logging.basicConfig(stream=sys.stdout)`
- `console.log()` in Node.js
- `logger.info()` with stdout handler

**Bad patterns:**
- `logging.FileHandler('/var/log/app.log')`
- `RotatingFileHandler`
- Log management in application code

---

## XII. Admin Processes
**Run admin/management tasks as one-off processes**

- [ ] Admin scripts in version control
- [ ] Admin tasks use same codebase as application
- [ ] Admin tasks use same config (environment variables)
- [ ] Database migrations in repo
- [ ] REPL/console available with same environment
- [ ] No direct database access from local machine
- [ ] Admin tasks have same dependencies as app

**Files to check:**
```bash
# Admin scripts and migrations
ls scripts/ migrations/ db/migrate/ manage.py 2>/dev/null

# Database migrations
ls -la migrations/ alembic/ db/migrate/ 2>/dev/null
```

**Good patterns:**
```bash
# Run with same environment
heroku run python manage.py migrate
heroku run rails console
heroku run python scripts/import_data.py

# Or with Docker
docker run --env-file .env myapp python scripts/import_data.py
```

**Red flags:**
- Admin scripts outside version control
- Different dependencies for admin tasks
- Direct SQL run from local machine to production
- Manual database operations

---

## Overall Compliance Scorecard

Calculate your compliance:

```
Compliant factors: ___ / 12
Partial compliance: ___ / 12
Non-compliant: ___ / 12

Percentage: ____%
```

**Compliance levels:**
- ✓ **Full (Green)**: All criteria met for this factor
- ⚠ **Partial (Yellow)**: Some criteria met, needs improvement
- ✗ **None (Red)**: Violates this factor, needs immediate attention

## Priority Action Items

Based on the checklist, identify top 3 priorities:

1. **Factor ___**: _______________________
2. **Factor ___**: _______________________
3. **Factor ___**: _______________________

## Next Steps

1. Address all ✗ (non-compliant) factors
2. Improve ⚠ (partial) factors
3. Document compliance in `TWELVE-FACTOR-COMPLIANCE.md`
4. Set up monitoring to maintain compliance
5. Re-assess quarterly

## Quick Verification Commands

Run these commands to automatically check some aspects:

```bash
# Check for dependency files
echo "=== Dependency Management ==="
ls requirements.txt package.json Gemfile go.mod Cargo.toml 2>/dev/null || echo "❌ No dependency manifest found"

# Check for config in environment
echo -e "\n=== Configuration ==="
if grep -r "os.environ\|process.env\|ENV\[" . --include="*.py" --include="*.js" --include="*.rb" 2>/dev/null | head -1 > /dev/null; then
    echo "✓ Using environment variables"
else
    echo "❌ Not using environment variables"
fi

# Check for credentials in code (should be empty)
echo -e "\n=== Security Check ==="
if grep -r "password\s*=\s*['\"][^$]" --include="*.py" --include="*.js" --include="*.rb" . 2>/dev/null | head -1 > /dev/null; then
    echo "❌ WARNING: Possible hardcoded credentials found"
else
    echo "✓ No obvious hardcoded credentials"
fi

# Check for Procfile
echo -e "\n=== Process Types ==="
if [ -f Procfile ]; then
    echo "✓ Procfile found:"
    cat Procfile
else
    echo "⚠ No Procfile found"
fi

# Check for Docker
echo -e "\n=== Containerization ==="
ls Dockerfile docker-compose.yml 2>/dev/null && echo "✓ Docker configuration found" || echo "⚠ No Docker configuration"

# Check logging patterns
echo -e "\n=== Logging ==="
if grep -r "FileHandler\|RotatingFileHandler" --include="*.py" . 2>/dev/null | head -1 > /dev/null; then
    echo "❌ WARNING: File-based logging found"
else
    echo "✓ No file-based logging detected"
fi
```

## Resources

For detailed guidance on each factor, see:
- `content/` directory for full factor documentation
- `SKILL.md` in this directory for implementation guidance
- `EXAMPLES.md` for code examples
- `CAPABILITIES.md` for benefits and use cases
