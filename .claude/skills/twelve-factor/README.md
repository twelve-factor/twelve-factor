# Twelve-Factor App Skill for Claude Code

This skill provides expert guidance on building twelve-factor applications - cloud-native SaaS apps that follow best practices for scalability, portability, and maintainability.

## What is the Twelve-Factor App?

The Twelve-Factor App is a methodology for building modern software-as-a-service applications that:

- Use **declarative** formats for setup automation
- Have a **clean contract** with the underlying OS for **maximum portability**
- Are suitable for **deployment on modern cloud platforms**
- **Minimize divergence** between development and production
- Can **scale up** without significant changes to tooling or architecture

## When This Skill Activates

This skill automatically activates when you're:

- Building web applications, microservices, or APIs
- Working with cloud applications or containerized apps
- Reviewing architecture for production readiness
- Discussing deployment, scaling, or configuration management
- Implementing backing services (databases, queues, caches)
- Setting up CI/CD pipelines
- Addressing portability or scalability concerns

## The Twelve Factors

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

## How to Use This Skill

### During Code Review

Ask Claude to review your code for twelve-factor compliance:

```
Review this code for twelve-factor compliance
```

Claude will check for violations and suggest improvements.

### During Architecture Design

Get recommendations while designing:

```
I'm designing a microservice that handles user authentication.
How should I handle configuration and secrets?
```

Claude will reference Factor III (Config) and guide you to use environment variables.

### During Implementation

Get specific guidance while coding:

```
Where should I store session data in my web app?
```

Claude will reference Factor VI (Processes) and recommend Redis/Memcached instead of in-memory storage.

### Quick Compliance Check

Use the checklist:

```
Run a twelve-factor compliance check on this project
```

Claude will use the checklist.md to assess your application.

## Skill Files

- **SKILL.md** - Main skill instructions for Claude
- **reference.md** - Complete twelve-factor documentation
- **checklist.md** - Quick compliance assessment checklist
- **README.md** - This file

## Example Interactions

### Example 1: Configuration Management

**You:** How should I handle database credentials in my app?

**Claude (with this skill):** According to **Factor III (Config)**, you should store database credentials in environment variables, never commit them to your repository. Here's the recommended approach:

```javascript
// ❌ Bad: Hardcoded credentials
const dbConfig = {
  host: 'localhost',
  user: 'admin',
  password: 'secret123'
};

// ✓ Good: Environment variables
const dbConfig = {
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD
};
```

The litmus test: Could you open-source your codebase without exposing credentials? If no, you have a Factor III violation.

### Example 2: Session Storage

**You:** Can I store user sessions in memory for better performance?

**Claude (with this skill):** No, that violates **Factor VI (Processes)**. Twelve-factor apps must be stateless with share-nothing processes. In-memory session storage creates several problems:

- Can't scale horizontally (requires sticky sessions)
- Sessions lost on process restart
- Not resilient to crashes

Instead, use an external session store:

```python
# ✓ Good: External session store
from flask import Flask
from flask_session import Session

app = Flask(__name__)
app.config['SESSION_TYPE'] = 'redis'
app.config['SESSION_REDIS'] = redis.from_url(os.environ['REDIS_URL'])
Session(app)
```

This allows you to run multiple stateless processes and scale horizontally.

### Example 3: Development Database

**You:** Should I use SQLite for local development and PostgreSQL in production?

**Claude (with this skill):** No, that violates **Factor X (Dev/Prod Parity)**. Using different backing services between environments can cause:

- Code that works in dev but fails in prod
- SQL dialect incompatibilities
- Different behavior with transactions, locking, etc.
- Friction that discourages continuous deployment

**Recommendation:** Use PostgreSQL in all environments. Modern tools make this easy:

```yaml
# docker-compose.yml for local development
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    ports:
      - "5432:5432"
```

The time gap, personnel gap, and tools gap should all be minimized for continuous deployment.

## Benefits of Twelve-Factor Compliance

- **Portability**: Apps run anywhere (cloud, on-prem, containers)
- **Scalability**: Easy horizontal scaling without code changes
- **Maintainability**: Clear separation of concerns
- **Continuous Deployment**: Fast, safe deployments
- **Developer Onboarding**: Automated setup, clear conventions
- **Resilience**: Stateless processes, graceful failures

## Contributing

This skill is based on the twelve-factor manifesto at https://12factor.net and the updated version being developed in this repository.

## License

This skill is part of the twelve-factor repository and follows the same Creative Commons Attribution 4.0 International License.
