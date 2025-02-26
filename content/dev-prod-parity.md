## X. Dev/prod parity

### Keep development, staging, and production as similar as possible

#### 1. A twelve-factor app minimizes the gaps between development, staging, and production.

Historically, there have been substantial gaps between development (a developer
making live edits to a local [deploy](./codebase.md) of the app) and production
(a running deploy of the app accessed by end users). These gaps manifest in
three areas:

- **The time gap**: A developer may work on code that takes days, weeks, or even
  months to go into production.
- **The personnel gap**: Developers write code, ops engineers deploy it.
- **The tools gap**: Developers may be using a stack like Nginx, SQLite, and
  OS X, while the production deploy uses Apache, MySQL, and Linux.

**The twelve-factor app is designed for
[continuous deployment](http://avc.com/2011/02/continuous-deployment/) by
keeping the gap between development and production small.**

|                               | Traditional app  | Twelve-factor app      |
| ----------------------------- | ---------------- | ---------------------- |
| **Time between deploys**      | Weeks            | Hours                  |
| **Code authors vs deployers** | Different people | Same people            |
| **Dev vs production**         | Divergent        | As similar as possible |

##### Guidance

- Make the time gap small: a developer may write code and have it deployed hours
  or even just minutes later.
- Make the personnel gap small: developers who wrote code are closely involved
  in deploying it and watching its behavior in production.
- Make the tools gap small: keep development and production as similar as
  possible.

#### 2. A twelve-factor app uses the same backing services in all deploys.

[Backing services](./backing-services.md), such as the app's database, queueing
system, or cache, are a key area where dev/prod parity is important. Many
languages offer libraries which simplify access to the backing service,
including _adapters_ to different types of services.

| Type     | Language      | Library              | Adapters                      |
| -------- | ------------- | -------------------- | ----------------------------- |
| Database | Ruby/Rails    | ActiveRecord         | MySQL, PostgreSQL, SQLite     |
| Queue    | Python/Django | Celery               | RabbitMQ, Beanstalkd, Redis   |
| Cache    | Ruby/Rails    | ActiveSupport::Cache | Memory, filesystem, Memcached |

Developers sometimes find great appeal in using a lightweight backing service in
their local environments, while a more robust backing service is used in
production. For example, using SQLite locally and PostgreSQL in production; or
local process memory for caching in development and Memcached in production.

**The twelve-factor developer resists the urge to use different backing services
between development and production**; tiny incompatibilities can cause code that
worked in development or staging to fail in production, creating friction that
disincentivizes continuous deployment and incurs high costs over the lifetime of
an application.

##### Guidance

All deploys of the app (developer environments, staging, production) should use
the same type and version of each backing service. Modern backing services such
as Memcached, PostgreSQL, and RabbitMQ are not difficult to install and run
thanks to modern packaging systems like
[Homebrew](http://mxcl.github.com/homebrew/) and
[apt-get](https://help.ubuntu.com/community/AptGet/Howto). Declarative
provisioning tools such as [Chef](http://www.opscode.com/chef/) and
[Puppet](http://docs.puppetlabs.com/), combined with lightweight virtual
environments such as [Docker](https://www.docker.com/) and
[Vagrant](http://vagrantup.com/), enable developers to run local environments
that closely approximate production.
