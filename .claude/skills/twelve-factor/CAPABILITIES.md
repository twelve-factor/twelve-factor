# Twelve-Factor Methodology - Capabilities Overview

This document provides a structured overview of the Twelve-Factor Methodology skill capabilities, implementation guidance, and success metrics.

## 📊 Capability Matrix

| Factor | Capability | Automated Check | Agent | Priority |
|--------|------------|----------------|-------|----------|
| **I. Codebase** | Version control validation | ✅ | compliance-checker | High |
| **II. Dependencies** | Dependency manifest detection | ✅ | compliance-checker | Critical |
| **III. Config** | Secrets detection, env var audit | ✅ | config-auditor | Critical |
| **IV. Backing Services** | Service attachment patterns | 🔄 | Manual review | Medium |
| **V. Build/Release/Run** | Dockerfile multi-stage check | ✅ | deployment-validator | High |
| **VI. Processes** | Stateless pattern detection | ✅ | compliance-checker | High |
| **VII. Port Binding** | Self-contained service check | 🔄 | Manual review | Medium |
| **VIII. Concurrency** | Process model validation | 🔄 | Manual review | Medium |
| **IX. Disposability** | Graceful shutdown patterns | 🔄 | deployment-validator | High |
| **X. Dev/Prod Parity** | Environment consistency check | ✅ | deployment-validator | Critical |
| **XI. Logs** | Stdout logging detection | ✅ | compliance-checker | High |
| **XII. Admin Processes** | One-off process patterns | 🔄 | Manual review | Low |

**Legend:**
- ✅ Automated check available
- 🔄 Manual review recommended
- Priority: Critical > High > Medium > Low

## 🎯 Benefits by Role

### For Developers

**Faster Onboarding**
- Declarative dependency management
- Reproducible builds (Factor II)
- Clear environment setup (Factor III)

**Better Developer Experience**
- Consistent dev/prod environments (Factor X)
- Fast local development with Docker
- Clear deployment pipelines (Factor V)

**Code Quality**
- Stateless architecture (Factor VI)
- Clean separation of concerns
- Testable, maintainable code

### For DevOps/SRE

**Operational Excellence**
- Horizontal scaling without code changes (Factor VIII)
- Fast recovery with disposable processes (Factor IX)
- Centralized log aggregation (Factor XI)

**Deployment Reliability**
- Immutable releases (Factor V)
- Easy rollbacks
- Blue-green deployments

**Infrastructure as Code**
- Portable across cloud providers
- Consistent deployment patterns
- Automated compliance checks

### For Engineering Managers

**Risk Reduction**
- No vendor lock-in
- Disaster recovery readiness
- Security best practices (Factor III)

**Team Velocity**
- Faster feature delivery
- Reduced production incidents
- Clear architectural guidelines

**Cost Optimization**
- Efficient resource utilization (Factor VIII)
- Auto-scaling capabilities
- Cloud-native cost models

### For Security Teams

**Security Posture**
- No secrets in code (Factor III)
- Environment isolation
- Audit trail via logs (Factor XI)

**Compliance**
- Automated secrets scanning
- Configuration audit logs
- Reproducible deployments

## 🚀 Implementation Path

### Phase 1: Foundation (Weeks 1-2)
**Focus:** Critical Factors

```bash
Priority: Critical
Factors: II (Dependencies), III (Config), X (Dev/Prod Parity)
```

**Actions:**
1. ✅ Create dependency manifests (package.json, requirements.txt, etc.)
2. ✅ Move all secrets to environment variables
3. ✅ Create .env.example template
4. ✅ Add .env to .gitignore
5. ✅ Use same databases in dev and prod

**Validation:**
```bash
.claude/skills/twelve-factor/scripts/check-compliance.sh
.claude/skills/twelve-factor/agents/config-auditor.sh
```

**Success Criteria:**
- [ ] No hardcoded credentials in codebase
- [ ] All dependencies explicitly declared
- [ ] Dev environment matches prod (same DB, cache, etc.)

### Phase 2: Deployment (Weeks 3-4)
**Focus:** Build & Run

```bash
Priority: High
Factors: I (Codebase), V (Build/Release/Run), XI (Logs)
```

**Actions:**
1. ✅ Ensure Git version control
2. ✅ Create Dockerfile with multi-stage builds
3. ✅ Set up CI/CD pipeline
4. ✅ Convert all logging to stdout
5. ✅ Remove log file management from app

**Validation:**
```bash
.claude/skills/twelve-factor/agents/deployment-validator.sh
```

**Success Criteria:**
- [ ] Dockerfile uses multi-stage builds
- [ ] CI/CD pipeline running
- [ ] All logs go to stdout
- [ ] No log rotation in app code

### Phase 3: Scale & Reliability (Weeks 5-6)
**Focus:** Production Readiness

```bash
Priority: High
Factors: VI (Processes), IX (Disposability)
```

**Actions:**
1. ✅ Remove in-memory session storage
2. ✅ Implement external session store (Redis)
3. ✅ Add graceful shutdown handlers
4. ✅ Make startup fast (<10 seconds)
5. ✅ Ensure jobs are reentrant and idempotent

**Validation:**
```bash
.claude/skills/twelve-factor/scripts/agents-runner.sh run
```

**Success Criteria:**
- [ ] No sticky sessions required
- [ ] Processes handle SIGTERM gracefully
- [ ] Startup time < 10 seconds
- [ ] Can scale horizontally

### Phase 4: Optimization (Weeks 7-8)
**Focus:** Remaining Factors

```bash
Priority: Medium-Low
Factors: IV, VII, VIII, XII
```

**Actions:**
1. ✅ Document backing service attachment patterns
2. ✅ Ensure port binding (no runtime webserver injection)
3. ✅ Define process types (web, worker, cron)
4. ✅ Move admin tasks to one-off processes

**Success Criteria:**
- [ ] Services swap via config only
- [ ] App exports HTTP via port binding
- [ ] Clear process formation defined
- [ ] Admin tasks use same environment

## 📈 Success Metrics

### Technical Metrics

**Deployment Frequency**
- Target: Daily deployments
- Measure: Time between commits and production
- Tool: CI/CD analytics

**Mean Time to Recovery (MTTR)**
- Target: < 15 minutes
- Measure: Incident detection to resolution
- Tool: Monitoring dashboards

**Change Failure Rate**
- Target: < 5%
- Measure: Deployments causing incidents
- Tool: Incident tracking

**Lead Time for Changes**
- Target: < 1 day
- Measure: Commit to production deployment
- Tool: Git + deployment logs

### Operational Metrics

**Scalability**
- Metric: Can handle 10x traffic without code changes
- Test: Load testing with horizontal scaling

**Portability**
- Metric: Deploy to new cloud provider in < 1 week
- Test: Multi-cloud deployment exercise

**Developer Productivity**
- Metric: New developer productive in < 1 day
- Test: Onboarding time tracking

**Infrastructure Costs**
- Metric: Cost per transaction/request
- Test: Cloud billing analysis

### Compliance Score

```bash
# Run comprehensive check
.claude/skills/twelve-factor/scripts/agents-runner.sh run

# View aggregated score
.claude/skills/twelve-factor/scripts/bus.sh read twelve-factor.agents.results 3
```

**Scoring:**
- 90-100%: Excellent (production-ready)
- 75-89%: Good (minor improvements needed)
- 60-74%: Fair (focus on critical factors)
- <60%: Poor (significant work required)

## 🌍 Language-Agnostic Guidance

### Node.js / JavaScript
- Dependencies: `package.json` + `npm ci`
- Config: `dotenv` + `process.env`
- Web server: Express, Koa (self-contained)
- Logs: `console.log()` (stdout)
- Process manager: PM2, node cluster

### Python
- Dependencies: `requirements.txt` + `pip install -r`
- Config: `python-dotenv` + `os.environ`
- Web server: Flask, FastAPI (built-in)
- Logs: `logging` to `StreamHandler(sys.stdout)`
- Process manager: Gunicorn, uWSGI

### Ruby
- Dependencies: `Gemfile` + `bundle install`
- Config: `dotenv` + `ENV[]`
- Web server: Puma, Thin (Rack-based)
- Logs: `Rails.logger` to stdout
- Process manager: Puma, Unicorn

### Go
- Dependencies: `go.mod` + `go mod download`
- Config: `godotenv` + `os.Getenv()`
- Web server: `net/http` (self-contained)
- Logs: `log.SetOutput(os.Stdout)`
- Process manager: systemd, supervisor

### Java
- Dependencies: `pom.xml` or `build.gradle`
- Config: Environment variables via System.getenv()
- Web server: Embedded Tomcat/Jetty
- Logs: SLF4J to stdout
- Process manager: systemd, Docker

### Docker/Kubernetes Common Patterns

**Dockerfile Best Practices:**
```dockerfile
# Multi-stage build (Factor V)
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

FROM node:18-slim
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules

# Port binding (Factor VII)
EXPOSE 3000

# Graceful shutdown (Factor IX)
STOPSIGNAL SIGTERM

# Logs to stdout (Factor XI)
CMD ["node", "dist/server.js"]
```

**Kubernetes Deployment:**
```yaml
apiVersion: apps/v1
kind: Deployment
spec:
  # Concurrency (Factor VIII)
  replicas: 3

  template:
    spec:
      containers:
      - name: app
        # Config (Factor III)
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: database-url

        # Port binding (Factor VII)
        ports:
        - containerPort: 3000

        # Disposability (Factor IX)
        lifecycle:
          preStop:
            exec:
              command: ["/bin/sh", "-c", "sleep 10"]
```

## 🔗 Related Resources

### Official Documentation
- [The Twelve-Factor App](https://12factor.net) (Original manifesto)
- [Twelve-Factor Update](https://github.com/twelve-factor/twelve-factor) (Community improvements)
- [Beyond the Twelve-Factor App](https://www.oreilly.com/library/view/beyond-the-twelve-factor/9781492042631/) (O'Reilly book)

### Skill Resources
- [SKILL.md](./SKILL.md) - Detailed methodology and guidance
- [checklist.md](./checklist.md) - Factor-by-factor compliance checklist
- [examples.md](./examples.md) - Multi-language code examples
- [README.md](./README.md) - Skill overview and usage

### Tools & Scripts
- `check-compliance.sh` - Quick compliance scan
- `agents-runner.sh` - Parallel agent execution
- `bus.sh` - Context bus CLI
- `update-docs.sh` - Documentation freshness check

## 📞 Getting Help

**Quick Start:**
```bash
# Check compliance
.claude/skills/twelve-factor/scripts/check-compliance.sh

# Run all agents
.claude/skills/twelve-factor/scripts/agents-runner.sh run

# View results
.claude/skills/twelve-factor/scripts/bus.sh read twelve-factor.agents.results
```

**Ask Claude Code:**
```
"Review this project for twelve-factor compliance"
"How should I handle database credentials?"
"Check if my deployment follows twelve-factor principles"
```

**Community:**
- [Twelve-Factor Discussions](https://github.com/twelve-factor/twelve-factor/discussions)
- [Discord](https://discord.gg/9HFMDMt95z)
- [Google Group](https://groups.google.com/g/twelve-factor)

---

**Last Updated:** 2025-11-19
**Skill Version:** 1.0.0
**Documentation Version:** Based on twelve-factor.net (2012) + community updates (2024)
