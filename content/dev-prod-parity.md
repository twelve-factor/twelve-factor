## X. Dev/prod parity

### Keep development, staging, and production as similar as possible

#### 1. A twelve-factor app minimizes gaps between development, staging, and production environments.

Historically, there have been substantial gaps between development (a developer
making live edits to a local [deploy](./codebase.md) of the app) and production
(a running deploy of the app accessed by end users). These gaps manifest in
three areas: the time gap, the personnel gap, and the tools gap. The
twelve-factor app is designed for
[continuous deployment](http://avc.com/2011/02/continuous-deployment/) by
keeping these gaps small.

##### Examples

- **The time gap:** In traditional apps, a developer may work on code that takes
  days, weeks, or even months to go into production.
- **The personnel gap:** Developers write code while operations engineers deploy
  it.
- **The tools gap:** Developers might use one stack (e.g., Nginx, SQLite, OS X)
  while production uses another (e.g., Apache, MySQL, Linux).

|                                    | Traditional app  | Twelve-factor app      |
| ---------------------------------- | ---------------- | ---------------------- |
| **Time between deploys**           | Weeks            | Hours                  |
| **Code authors vs deployers**      | Different people | Same people            |
| **Dev vs production environments** | Divergent        | As similar as possible |

##### Guidance

To achieve dev/prod parity:

- **Minimize the time gap:** Aim for deployments within hours or even minutes.
- **Reduce the personnel gap:** Involve the same people in writing and deploying
  code.
- **Narrow the tools gap:** Keep development and production environments as
  similar as possible.

#### 2. A twelve-factor app enforces parity for backing services.

Backing services—such as databases, queueing systems, or caches—are a critical
area where parity between development and production is essential. Many
languages offer libraries that simplify access to these services, including
adapters that abstract differences between various implementations.

##### Examples

| Type     | Language      | Library              | Adapters                      |
| -------- | ------------- | -------------------- | ----------------------------- |
| Database | Ruby/Rails    | ActiveRecord         | MySQL, PostgreSQL, SQLite     |
| Queue    | Python/Django | Celery               | RabbitMQ, Beanstalkd, Redis   |
| Cache    | Ruby/Rails    | ActiveSupport::Cache | Memory, filesystem, Memcached |

Developers sometimes favor lightweight backing services locally—using SQLite
instead of PostgreSQL, or in-memory caching instead of Memcached—while
production employs more robust alternatives.

##### Guidance

The twelve-factor developer resists using different backing services between
development and production. Even when adapters abstract away differences, slight
incompatibilities can cause code that passes tests locally to fail in
production, adding friction that dampens continuous deployment. To ensure
smooth, reliable deployments, all environments (development, staging,
production) should use the same type and version of each backing service. Modern
packaging systems like [Homebrew](http://mxcl.github.com/homebrew/) and
[apt-get](https://help.ubuntu.com/community/AptGet/Howto), as well as
provisioning tools such as [Chef](http://www.opscode.com/chef/),
[Puppet](http://docs.puppetlabs.com/), Docker, and Vagrant, make it practical to
closely align local setups with production.
