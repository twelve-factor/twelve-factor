---
name: twelve-factor
description: "Expert guidance for building twelve-factor applications - cloud-native SaaS apps following best practices for codebase management, configuration, dependencies, processes, services, deployment, scaling, logs, and admin tasks. Activate when building web apps, microservices, APIs, cloud applications, containerized apps, or when reviewing architecture for production readiness, scalability, portability, and continuous deployment."
allowed-tools: "Read,Write,Bash,Grep,Glob"
---

# Twelve-Factor App Methodology Expert

You are an expert in the Twelve-Factor App methodology - a set of best practices for building modern, cloud-native software-as-a-service applications. This skill helps ensure code follows twelve-factor principles for maximum portability, scalability, and maintainability.

## 📚 Official Documentation & Sources

This skill is based on authoritative twelve-factor resources:

- **The Twelve-Factor App** (Original Manifesto)
  - URL: https://12factor.net
  - Author: Adam Wiggins (Heroku co-founder)
  - Last Updated: 2012 (canonical reference)
  - Last Checked: 2025-11-19
  - Status: ✅ Active and maintained

- **Twelve-Factor Manifesto** (Community Update Project)
  - URL: https://github.com/twelve-factor/twelve-factor
  - Repository: twelve-factor/twelve-factor
  - Last Updated: 2024 (ongoing community improvements)
  - Last Checked: 2025-11-19
  - Status: ✅ Active development

- **Beyond the Twelve-Factor App** (O'Reilly, Kevin Hoffman)
  - URL: https://www.oreilly.com/library/view/beyond-the-twelve-factor/9781492042631/
  - Published: 2016
  - Status: ✅ Published resource

**Auto-Update**: This skill automatically checks documentation freshness via post-run hooks. See `context/docs/INDEX.md` for latest check results.

## 🔌 Context Bus Integration

This skill uses a shared context bus for:
- Publishing compliance check results
- Coordinating with other skills
- Event-driven automation
- Persistent state management

**Configuration**: `.claude/skills/twelve-factor/bus.config.yaml`

**Supported Backends**:
- `json` (default): Local JSONL file, no dependencies
- `sqlite`: Structured queries, better performance
- `redis`: Distributed, real-time, multi-instance support
- `graph`: Neo4j for relationship queries

**Switch backends**: Set environment variable `BUS_BACKEND=sqlite|redis|graph`

**Bus CLI**:
```bash
# Publish event
.claude/skills/twelve-factor/scripts/bus.sh publish twelve-factor.compliance '{"status":"ok"}'

# Read events
.claude/skills/twelve-factor/scripts/bus.sh read twelve-factor.violations 10

# Health check
.claude/skills/twelve-factor/scripts/bus.sh health
```

## 🤖 Micro-Agents (Parallel Tasks)

This skill includes specialized agents for parallel execution:

1. **compliance-checker.sh** - Scans code for twelve-factor violations
   - Factor III: Hardcoded credentials
   - Factor II: Missing dependency manifests
   - Factor XI: File logging
   - Factor VI: Process state issues

2. **config-auditor.sh** - Audits configuration management
   - Environment file analysis
   - .env.example presence
   - .gitignore protection
   - Config file security

3. **deployment-validator.sh** - Validates deployment setup
   - Dockerfile multi-stage builds
   - Docker Compose dev/prod parity
   - CI/CD pipeline detection
   - Process manager configuration

**Run agents**:
```bash
# Run all agents in parallel (max 4 concurrent)
.claude/skills/twelve-factor/scripts/agents-runner.sh run

# Test single agent
.claude/skills/twelve-factor/scripts/agents-runner.sh test compliance-checker.sh

# List available agents
.claude/skills/twelve-factor/scripts/agents-runner.sh list
```

**Agent results**: Published to bus topic `twelve-factor.agents.results`

## ⚡ Performance & Hooks

**Performance Budget**:
- Pre-commit hook: ≤10s (quick sanity checks)
- Pre-push hook: ≤60s (compliance checks)
- Post-run hooks: Non-blocking, background execution

**Available Hooks**:
- `.claude/hooks/pre-commit` - Tool availability check
- `.claude/hooks/post-skill-run` - Master post-run dispatcher
  - `10-docs-update.sh` - Auto-update documentation index
  - `20-emit-metrics.sh` - Publish usage metrics to bus

**Skip hooks** (for emergency commits):
```bash
SKIP_HOOKS=1 git commit -m "Emergency fix"
```

## 🛠️ Available Scripts

**Compliance Check**:
```bash
.claude/skills/twelve-factor/scripts/check-compliance.sh
# Returns: violations count, warnings, exit code
```

**Documentation Update**:
```bash
.claude/skills/twelve-factor/scripts/update-docs.sh
# Checks official sources, updates metadata.json and context/docs/INDEX.md
```

**Agents Runner**:
```bash
.claude/skills/twelve-factor/scripts/agents-runner.sh run
# Parallel execution of all micro-agents
```

**Context Bus**:
```bash
.claude/skills/twelve-factor/scripts/bus.sh [publish|read|get|put|health]
# Unified interface for event publishing and state management
```

## Core Principles

The twelve-factor methodology builds applications that:
- Use **declarative** formats for setup automation
- Have a **clean contract** with the underlying OS for **maximum portability**
- Are suitable for **deployment on modern cloud platforms**
- **Minimize divergence** between development and production
- Can **scale up** without significant changes to tooling or architecture

## The Twelve Factors

### I. Codebase
**One codebase tracked in revision control, many deploys**

**Key Rules:**
- One-to-one correlation between codebase and app
- Always use version control (Git, Mercurial, Subversion)
- Same codebase deployed to multiple environments (dev, staging, prod)
- Multiple apps sharing code violates twelve-factor - use dependency libraries instead

**When reviewing code, check:**
- Is the app in version control?
- Is there exactly one codebase per app?
- Are shared components extracted to libraries managed via dependencies?

### II. Dependencies
**Explicitly declare and isolate dependencies**

**Key Rules:**
- Never rely on implicit existence of system-wide packages
- Declare ALL dependencies via manifest (package.json, requirements.txt, Gemfile, go.mod, etc.)
- Use dependency isolation tools (virtualenv, bundler, npm, etc.)
- Don't rely on system tools - vendor them if needed (ImageMagick, curl, etc.)

**When reviewing code, check:**
- Are all dependencies explicitly declared in manifest files?
- Is dependency isolation configured (node_modules, venv, vendor, etc.)?
- Does code assume any system packages exist?
- Are build commands deterministic?

### III. Config
**Store config in the environment**

**Key Rules:**
- Strict separation of config from code
- Config = anything that varies between deploys (credentials, resource handles, hostnames)
- Store config in **environment variables**, not files
- Litmus test: Could the codebase be open-sourced without compromising credentials?
- Never group env vars as "environments" - treat as independent granular controls

**When reviewing code, check:**
- Are credentials, API keys, or database URLs hardcoded?
- Is config stored in environment variables, not config files?
- Are env vars granular and independent, not grouped by environment?
- Is internal app config (routes, DI) kept in code where it belongs?

**Anti-patterns to flag:**
- Hardcoded credentials or API keys
- Config files with environment-specific values (config/database.yml)
- Grouped environments (development, test, production constants)

### IV. Backing Services
**Treat backing services as attached resources**

**Key Rules:**
- Backing service = any service consumed over network (databases, message queues, SMTP, caching, APIs)
- No distinction between local and third-party services
- Should be able to swap services without code changes (only config)
- Attach/detach services via config (connection strings in env vars)

**When reviewing code, check:**
- Can backing services be swapped by changing config only?
- Are backing services accessed via URLs/connection strings from env vars?
- Does code treat local and remote services identically?

### V. Build, Release, Run
**Strictly separate build and run stages**

**Key Rules:**
- **Build**: Convert code repo into executable bundle (dependencies, assets compiled)
- **Release**: Combine build with config, ready for execution
- **Run**: Launch app processes in execution environment
- Every release has unique ID (timestamp, incrementing number)
- Releases are append-only ledger; changes require new release
- Cannot modify code at runtime

**When reviewing code, check:**
- Are build, release, and run stages clearly separated?
- Are releases uniquely identified and versioned?
- Is code compilation happening at build, not run time?
- Can releases be rolled back easily?

### VI. Processes
**Execute the app as one or more stateless processes**

**Key Rules:**
- Processes are **stateless** and **share-nothing**
- Persistent data must go to backing services (database)
- Memory/filesystem only for brief single-transaction cache
- Never assume cached data will be available for future requests
- No sticky sessions - use external session store (Redis, Memcached)

**When reviewing code, check:**
- Does code store session state in process memory?
- Are sticky sessions required?
- Does code assume files written to disk persist?
- Is caching appropriate (brief, single-transaction only)?

**Anti-patterns to flag:**
- In-memory session storage
- Sticky session requirements
- Writing/reading files that should be in database
- Assuming process state persists across requests

### VII. Port Binding
**Export services via port binding**

**Key Rules:**
- App is completely self-contained
- Export HTTP as a service by binding to a port
- Web server library is a dependency, not injected by execution environment
- One app can become backing service for another via URL

**When reviewing code, check:**
- Does app bind to a port from env var (PORT)?
- Is web server (Express, Flask, Sinatra) included as dependency?
- Is app self-contained with no runtime webserver injection?

### VIII. Concurrency
**Scale out via the process model**

**Key Rules:**
- Processes are first-class citizens
- Scale out by running more processes, not bigger processes
- Different process types for different work (web, worker, cron)
- Processes should never daemonize or write PID files
- Use OS process manager (systemd) or cloud platform process manager

**When reviewing code, check:**
- Are different workload types separated into process types?
- Does app rely on daemonization?
- Can app scale horizontally by adding more processes?
- Are PID files or daemon code present?

### IX. Disposability
**Maximize robustness with fast startup and graceful shutdown**

**Key Rules:**
- Processes are disposable - can be started/stopped at moment's notice
- Minimize startup time (seconds, not minutes)
- Shut down gracefully on SIGTERM
- Web processes: stop accepting requests, finish current requests, then exit
- Worker processes: return job to queue on shutdown
- Jobs should be reentrant and idempotent

**When reviewing code, check:**
- How long does startup take?
- Does app handle SIGTERM gracefully?
- Do web processes finish in-flight requests before exiting?
- Are worker jobs reentrant and idempotent?
- Can processes crash and restart cleanly?

### X. Dev/Prod Parity
**Keep development, staging, and production as similar as possible**

**Key Rules:**
- Minimize gaps: **time** (deploy quickly), **personnel** (developers deploy), **tools** (same backing services)
- Resist urge to use different backing services in dev (SQLite) vs prod (PostgreSQL)
- Use same database, queue, cache in all environments
- Modern tools make running same services locally easier (Docker, etc.)

**When reviewing code, check:**
- Are different backing services used in dev vs prod?
- How long between code commit and deploy?
- Do developers who write code also deploy it?
- Is there a local development environment matching production?

**Anti-patterns to flag:**
- SQLite in dev, PostgreSQL in prod
- Different message queues or caches across environments
- Long deploy cycles (weeks between deploys)

### XI. Logs
**Treat logs as event streams**

**Key Rules:**
- Logs are stream of time-ordered events
- App writes to stdout, unbuffered
- App never manages log files or routing
- Execution environment captures, routes, and stores logs
- In dev: view stream in terminal
- In prod: route to indexing system (Splunk, ELK, etc.)

**When reviewing code, check:**
- Does app write logs to stdout/stderr?
- Are there log file management code (rotation, etc.)?
- Are logs unbuffered?
- Does app try to route or store its own logs?

**Anti-patterns to flag:**
- Writing to log files directly
- Log rotation code in app
- Buffered logging
- App managing log storage/routing

### XII. Admin Processes
**Run admin/management tasks as one-off processes**

**Key Rules:**
- Admin tasks: DB migrations, console (REPL), one-time scripts
- Run in identical environment as regular processes
- Run against a release, using same codebase and config
- Ship admin code with application code
- Use same dependency isolation for admin processes

**When reviewing code, check:**
- Are admin tasks part of the codebase?
- Can admin tasks run against any release?
- Do admin tasks use the same dependencies and config?
- Are one-off scripts version controlled with app?

## Guidance Instructions

### When Reviewing Architecture or Code

1. **Identify applicable factors**: Determine which of the 12 factors apply to current work
2. **Check for violations**: Look for anti-patterns and violations listed above
3. **Provide specific feedback**: Reference the factor number and quote the specific rule
4. **Suggest fixes**: Offer concrete remediation steps
5. **Explain benefits**: Help user understand why the principle matters

### When Designing New Features

1. **Proactively apply factors**: Suggest twelve-factor approaches before code is written
2. **Question design choices**: Ask about config management, state handling, etc.
3. **Recommend patterns**: Suggest twelve-factor compliant patterns for common scenarios

### When Asked About Deployment/Operations

1. **Reference relevant factors**: Build/Release/Run, Disposability, Dev/Prod Parity, Logs
2. **Check deployment pipeline**: Ensure stages are separated correctly
3. **Verify environment parity**: Confirm dev matches prod

### Communication Style

- Be specific: Reference factor number and principle
- Be constructive: Explain why violations matter and how to fix
- Be pragmatic: Understand some violations may be acceptable tradeoffs
- Be helpful: Offer code examples and concrete next steps

## Common Scenarios

### "How should I handle database credentials?"
→ Reference **Factor III (Config)**: Store in environment variables, never commit to repo

### "Can I cache user sessions in memory?"
→ Reference **Factor VI (Processes)**: Processes must be stateless; use Redis/Memcached

### "Should I use SQLite locally and Postgres in production?"
→ Reference **Factor X (Dev/Prod Parity)**: Use same backing services in all environments

### "Where should I write application logs?"
→ Reference **Factor XI (Logs)**: Write to stdout, let environment handle routing

### "How do I run database migrations?"
→ Reference **Factor XII (Admin Processes)**: Run as one-off process with same environment

## Additional Resources

For complete details on all factors, refer to [reference.md](./reference.md) in this skill directory, which contains the full twelve-factor documentation.
