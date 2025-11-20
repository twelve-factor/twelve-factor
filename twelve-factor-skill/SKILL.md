---
name: twelve-factor-methodology
description: Analyze and design cloud-native applications using the twelve-factor methodology. Use when reviewing application architecture, designing SaaS applications, evaluating cloud readiness, or when users mention twelve-factor principles, cloud-native development, microservices, or application modernization.
---

# Twelve-Factor Methodology

This Skill helps you apply the twelve-factor methodology to analyze, design, and improve cloud-native software-as-a-service applications.

## When to Use This Skill

Use this Skill when:
- Analyzing application architecture for cloud readiness
- Reviewing codebases for twelve-factor compliance
- Designing new SaaS applications
- Modernizing legacy applications for cloud deployment
- Evaluating microservices architecture
- Auditing deployment practices
- Troubleshooting scalability or portability issues

## Quick Reference: The Twelve Factors

1. **Codebase** - One codebase tracked in revision control, many deploys
2. **Dependencies** - Explicitly declare and isolate dependencies
3. **Config** - Store config in the environment
4. **Backing Services** - Treat backing services as attached resources
5. **Build, Release, Run** - Strictly separate build and run stages
6. **Processes** - Execute the app as one or more stateless processes
7. **Port Binding** - Export services via port binding
8. **Concurrency** - Scale out via the process model
9. **Disposability** - Maximize robustness with fast startup and graceful shutdown
10. **Dev/Prod Parity** - Keep development, staging, and production as similar as possible
11. **Logs** - Treat logs as event streams
12. **Admin Processes** - Run admin/management tasks as one-off processes

## How to Apply the Methodology

### Step 1: Assess Current State

When analyzing an application, systematically evaluate it against each factor:

1. Read the relevant factor documentation from the `content/` directory
2. Identify violations or gaps in the current implementation
3. Note partial compliance and areas for improvement
4. Document specific examples from the codebase

**Example assessment prompt structure:**
```
For Factor X ([factor-name]):
- Current state: [description]
- Compliance level: [None/Partial/Full]
- Violations: [specific examples]
- Recommendations: [actionable improvements]
```

### Step 2: Prioritize Improvements

Not all factors have equal impact. Prioritize based on:

**High Priority (Foundation):**
- I. Codebase - Essential for version control and deployment
- II. Dependencies - Critical for reproducible builds
- III. Config - Necessary for environment portability
- V. Build, Release, Run - Core deployment pipeline

**Medium Priority (Scale & Reliability):**
- VI. Processes - Required for horizontal scaling
- VIII. Concurrency - Important for performance
- IX. Disposability - Key for cloud environments
- X. Dev/Prod Parity - Reduces deployment risks

**Standard Priority (Operations):**
- IV. Backing Services - Improves architecture flexibility
- VII. Port Binding - Enables service composition
- XI. Logs - Essential for observability
- XII. Admin Processes - Ensures consistency

### Step 3: Provide Concrete Guidance

For each factor, provide specific, actionable recommendations:

1. **Reference the factor documentation**: Use content from the `content/` directory for authoritative guidance
2. **Show code examples**: Demonstrate correct implementation patterns
3. **Identify anti-patterns**: Point out violations to avoid
4. **Suggest tools**: Recommend appropriate tools and frameworks
5. **Consider context**: Adapt recommendations to the specific language, framework, and platform

## Detailed Factor Guidance

### I. Codebase
**Key principle:** One codebase, one app, many deploys

**Check for:**
- Single source repository per application
- Shared code extracted to libraries (not duplicated)
- Clear separation between apps in distributed systems

**Common violations:**
- Multiple apps sharing the same repo (monolith with coupled components)
- Same code duplicated across multiple repos
- Lack of version control

**Reference:** Read `content/codebase.md` for detailed guidance

### II. Dependencies
**Key principle:** Explicitly declare and isolate all dependencies

**Check for:**
- Dependency manifest file (package.json, requirements.txt, Gemfile, pom.xml, go.mod, Cargo.toml)
- Dependency isolation (virtualenv, bundler, npm, Go modules)
- No reliance on implicit system packages

**Common violations:**
- Missing dependency declarations
- Relying on system-wide packages
- Inconsistent dependency versions across environments

**Tools by language:**
- Node.js: npm, yarn, pnpm
- Python: pip + virtualenv, poetry, pipenv
- Ruby: bundler
- Java: Maven, Gradle
- Go: Go modules
- Rust: Cargo

**Reference:** Read `content/dependencies.md` for detailed guidance

### III. Config
**Key principle:** Store config in environment variables

**Check for:**
- Environment variables for all environment-specific config
- No credentials in code or config files
- Granular env vars (not grouped by environment)

**Common violations:**
- Credentials in code or committed config files
- Different config mechanisms for different environments
- Grouped environments (development, staging, production configs)

**Good patterns:**
- Use .env files for local development (not committed)
- Use platform-provided env vars in production
- Validate required env vars at startup

**Reference:** Read `content/config.md` for detailed guidance

### IV. Backing Services
**Key principle:** Treat all backing services as attached resources

**Check for:**
- Database, cache, queue accessed via URL/credentials
- Ability to swap services without code changes
- No distinction between local and third-party services

**Common violations:**
- Hard-coded database hostnames or file paths
- Code that differs based on service provider
- Tight coupling to specific service implementations

**Reference:** Read `content/backing-services.md` for detailed guidance

### V. Build, Release, Run
**Key principle:** Strictly separate build, release, and run stages

**Check for:**
- Distinct build step producing artifacts
- Release combines build artifacts with config
- Run stage executes the release
- No code changes at runtime

**Common violations:**
- Compiling code in production
- Modifying code during deployment
- Unclear release versioning
- Unable to rollback releases

**Reference:** Read `content/build-release-run.md` for detailed guidance

### VI. Processes
**Key principle:** Execute app as stateless processes

**Check for:**
- No local state stored between requests
- Session state in backing services (Redis, Memcached, database)
- No sticky sessions required

**Common violations:**
- Local filesystem used for persistent storage
- Session state in memory
- Assuming single-server deployment

**Reference:** Read `content/processes.md` for detailed guidance

### VII. Port Binding
**Key principle:** Export services via port binding

**Check for:**
- App binds to port via environment variable
- Self-contained web server (no separate web server injection)
- Can be used as backing service for other apps

**Common violations:**
- Requiring separate web server deployment
- Hard-coded port numbers
- Unable to run multiple instances locally

**Reference:** Read `content/port-binding.md` for detailed guidance

### VIII. Concurrency
**Key principle:** Scale out via the process model

**Check for:**
- Different process types for different work (web, worker, scheduler)
- Processes are first-class citizens
- Designed for horizontal scaling

**Common violations:**
- Single-process, multi-threaded architecture only
- Inability to scale different work types independently
- Background jobs in web processes

**Reference:** Read `content/concurrency.md` for detailed guidance

### IX. Disposability
**Key principle:** Fast startup, graceful shutdown

**Check for:**
- Startup time under a few seconds
- Graceful shutdown on SIGTERM
- Crash resistance (processes can die and restart)
- Robust queueing for worker processes

**Common violations:**
- Long startup times (minutes)
- No shutdown signal handling
- Lost work on process termination
- State corruption from crashes

**Reference:** Read `content/disposability.md` for detailed guidance

### X. Dev/Prod Parity
**Key principle:** Keep dev, staging, and production similar

**Check for:**
- Same backing services across environments
- Small time gap between code write and deploy
- Same people write and deploy code
- Avoid lightweight substitutes in development

**Common violations:**
- SQLite in dev, PostgreSQL in production
- Different OS/platform in dev vs production
- Developers don't have production access
- Long deployment cycles

**Reference:** Read `content/dev-prod-parity.md` for detailed guidance

### XI. Logs
**Key principle:** Treat logs as event streams

**Check for:**
- Writing to stdout/stderr
- Not managing log files
- Execution environment handles routing and storage

**Common violations:**
- Writing to log files
- Log rotation in application code
- Logs stored in application filesystem

**Tools:**
- Local: tail, grep
- Staging: Centralized logging services
- Production: Log aggregation (Splunk, ELK, Datadog, CloudWatch)

**Reference:** Read `content/logs.md` for detailed guidance

### XII. Admin Processes
**Key principle:** Run admin tasks as one-off processes

**Check for:**
- Admin tasks use same codebase and config
- Admin tasks shipped with application code
- Same dependency isolation as regular processes

**Common violations:**
- Admin scripts outside version control
- Direct database manipulation from local machine
- Different dependencies for admin tasks
- Manual SQL run in production

**Reference:** Read `content/admin-processes.md` for detailed guidance

## Assessment Templates

### Quick Compliance Check

Use this template for rapid assessment:

```markdown
# Twelve-Factor Compliance Assessment

## Application: [Name]
## Date: [YYYY-MM-DD]

| Factor | Status | Notes |
|--------|--------|-------|
| I. Codebase | ✓/⚠/✗ | |
| II. Dependencies | ✓/⚠/✗ | |
| III. Config | ✓/⚠/✗ | |
| IV. Backing Services | ✓/⚠/✗ | |
| V. Build, Release, Run | ✓/⚠/✗ | |
| VI. Processes | ✓/⚠/✗ | |
| VII. Port Binding | ✓/⚠/✗ | |
| VIII. Concurrency | ✓/⚠/✗ | |
| IX. Disposability | ✓/⚠/✗ | |
| X. Dev/Prod Parity | ✓/⚠/✗ | |
| XI. Logs | ✓/⚠/✗ | |
| XII. Admin Processes | ✓/⚠/✗ | |

Legend: ✓ = Compliant, ⚠ = Partial, ✗ = Non-compliant
```

### Detailed Assessment Template

For comprehensive analysis:

```markdown
# Twelve-Factor Methodology - Detailed Assessment

## Executive Summary
- Overall compliance: [percentage]
- Critical issues: [count]
- Priority recommendations: [top 3]

## Factor-by-Factor Analysis

### I. Codebase
**Compliance:** [Full/Partial/None]
**Findings:**
- [Specific observation 1]
- [Specific observation 2]

**Recommendations:**
1. [Action item 1]
2. [Action item 2]

**Priority:** [High/Medium/Low]
**Effort:** [Small/Medium/Large]

[Repeat for each factor]

## Remediation Roadmap

### Phase 1: Foundation (Weeks 1-4)
- [Critical fixes]

### Phase 2: Improvement (Weeks 5-8)
- [Important enhancements]

### Phase 3: Optimization (Weeks 9-12)
- [Nice-to-have improvements]
```

## Code Review Checklist

When reviewing code for twelve-factor compliance:

**Pre-Deployment Checklist:**
- [ ] All dependencies declared in manifest
- [ ] No credentials in code
- [ ] All config in environment variables
- [ ] Backing services accessed via URLs
- [ ] Build process produces deployable artifact
- [ ] Processes are stateless
- [ ] Port from environment variable
- [ ] Different process types defined
- [ ] Graceful shutdown handlers
- [ ] Logs to stdout/stderr
- [ ] Admin tasks in codebase

**Architecture Review Checklist:**
- [ ] Can deploy to any cloud platform
- [ ] Can scale horizontally
- [ ] Can rollback releases
- [ ] Dev environment matches production
- [ ] New developer can set up in < 1 hour
- [ ] Can run multiple instances locally

## Common Modernization Patterns

### Moving from Monolith to Twelve-Factor

1. **Start with Config (Factor III)**
   - Extract all environment-specific values
   - Move credentials to environment variables
   - Remove environment-specific code branches

2. **Fix Dependencies (Factor II)**
   - Create dependency manifest
   - Set up dependency isolation
   - Remove system package dependencies

3. **Separate Build and Run (Factor V)**
   - Create reproducible build process
   - Generate versioned releases
   - Deploy artifacts, not source code

4. **Make Processes Stateless (Factor VI)**
   - Move session state to Redis/database
   - Remove local file dependencies
   - Design for process replaceability

5. **Improve Disposability (Factor IX)**
   - Reduce startup time
   - Add graceful shutdown
   - Make processes crash-resistant

### Containerization and Twelve-Factor

Docker and containers naturally align with twelve-factor:

- **Codebase:** Dockerfile in repo
- **Dependencies:** Declared in Dockerfile
- **Config:** Environment variables in container runtime
- **Build, Release, Run:** Docker build → Docker image → Docker run
- **Port Binding:** EXPOSE and PORT environment variable
- **Disposability:** Containers are designed to be ephemeral
- **Logs:** Docker captures stdout/stderr

## Anti-Patterns to Avoid

### ❌ Don't Do This

**Config anti-patterns:**
```python
# DON'T: Config in code
if environment == "production":
    db_host = "prod-db.example.com"
else:
    db_host = "localhost"
```

**Dependency anti-patterns:**
```
# DON'T: Assume system packages
import some_package  # Not in requirements.txt
```

**Process anti-patterns:**
```python
# DON'T: Store session in memory
sessions = {}  # Lost on process restart
```

### ✅ Do This Instead

**Config pattern:**
```python
# DO: Config from environment
import os
db_host = os.environ['DATABASE_HOST']
```

**Dependency pattern:**
```
# DO: Explicit dependencies
# requirements.txt
some_package==1.2.3
```

**Process pattern:**
```python
# DO: Session in backing service
import redis
session_store = redis.from_url(os.environ['REDIS_URL'])
```

## Language-Specific Guidance

### Python Applications
- Dependencies: requirements.txt or Pipfile
- Config: python-decouple or python-dotenv
- Web server: Gunicorn or uWSGI
- Process manager: Honcho or foreman

### Node.js Applications
- Dependencies: package.json with npm or yarn
- Config: dotenv package
- Web server: Built-in http server
- Process manager: PM2 or foreman

### Ruby Applications
- Dependencies: Gemfile with bundler
- Config: dotenv or figaro
- Web server: Puma or Unicorn
- Process manager: Foreman

### Java Applications
- Dependencies: pom.xml (Maven) or build.gradle (Gradle)
- Config: System.getenv() or Spring Boot externalized config
- Web server: Embedded Tomcat/Jetty
- Process manager: systemd or container orchestration

### Go Applications
- Dependencies: go.mod
- Config: os.Getenv() or viper
- Web server: net/http package
- Process manager: Native binaries, systemd, or containers

## Platform-Specific Considerations

### AWS
- Config: Systems Manager Parameter Store, Secrets Manager
- Logs: CloudWatch Logs
- Processes: ECS, EKS, Lambda
- Backing services: RDS, ElastiCache, SQS

### Google Cloud
- Config: Secret Manager
- Logs: Cloud Logging
- Processes: Cloud Run, GKE, Cloud Functions
- Backing services: Cloud SQL, Memorystore, Pub/Sub

### Azure
- Config: Key Vault, App Configuration
- Logs: Application Insights
- Processes: Container Apps, AKS, Functions
- Backing services: Azure Database, Azure Cache, Service Bus

### Heroku
Heroku was designed around twelve-factor:
- Config: Config vars
- Logs: Log streams
- Processes: Dynos with Procfile
- Backing services: Add-ons

## Troubleshooting Guide

### "Why can't we deploy to new environments easily?"
Likely violations: I (Codebase), II (Dependencies), III (Config)
- Check for environment-specific code
- Verify all dependencies are declared
- Ensure config is externalized

### "Why doesn't our app scale horizontally?"
Likely violations: VI (Processes), VIII (Concurrency)
- Check for local state storage
- Verify stateless process design
- Review session management

### "Why do deployments take so long?"
Likely violations: V (Build, Release, Run), IX (Disposability)
- Check for builds happening in production
- Review startup time
- Verify build artifacts are reusable

### "Why do dev and production behave differently?"
Likely violations: X (Dev/Prod Parity), II (Dependencies)
- Compare backing services
- Check dependency versions
- Review configuration differences

## Resources

All detailed factor documentation is available in the `content/` directory:

- `content/intro.md` - Introduction to the methodology
- `content/background.md` - Historical context
- `content/codebase.md` through `content/admin-processes.md` - Individual factors
- `content/toc.md` - Table of contents

For capability overview, see `CAPABILITIES.md` in the root directory.

## Best Practices for Using This Skill

1. **Always reference source documentation**: Read the actual factor files from `content/` for authoritative guidance
2. **Provide specific examples**: Use code from the actual application being analyzed
3. **Consider the context**: Adapt recommendations to the specific technology stack and platform
4. **Prioritize actionability**: Focus on concrete, implementable improvements
5. **Measure progress**: Use the assessment templates to track improvements over time

## Output Format

When performing assessments, structure your response as:

1. **Executive Summary** (2-3 sentences)
2. **Compliance Score** (e.g., "8/12 factors fully compliant")
3. **Critical Issues** (High-priority violations)
4. **Factor-by-Factor Analysis** (Brief for each factor)
5. **Prioritized Recommendations** (Top 3-5 actions)
6. **Next Steps** (Clear action items)

Keep assessments concise but actionable. Focus on the most impactful improvements first.
