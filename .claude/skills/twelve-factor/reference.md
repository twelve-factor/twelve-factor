# The Twelve-Factor App - Complete Reference

## Introduction

In the modern era, software is commonly delivered as a service: called *web apps*, or *software-as-a-service*. The twelve-factor app is a methodology for building software-as-a-service apps that:

* Use **declarative** formats for setup automation, to minimize time and cost for new developers joining the project
* Have a **clean contract** with the underlying operating system, offering **maximum portability** between execution environments
* Are suitable for **deployment** on modern **cloud platforms**, obviating the need for servers and systems administration
* **Minimize divergence** between development and production, enabling **continuous deployment** for maximum agility
* And can **scale up** without significant changes to tooling, architecture, or development practices

The twelve-factor methodology can be applied to apps written in any programming language, and which use any combination of backing services (database, queue, memory cache, etc).

---

## I. Codebase
### One codebase tracked in revision control, many deploys

#### 1. A twelve-factor app is always tracked in a version control system.

A twelve-factor app is always tracked in a version control system. A copy of the revision tracking database is known as a *code repository*, often shortened to *code repo* or just *repo*.

##### Examples

Examples of version control systems include [Git](http://git-scm.com/), [Mercurial](https://www.mercurial-scm.org/), and [Subversion](http://subversion.apache.org/).

##### Guidance

A *codebase* is any single repo (in a centralized revision control system like Subversion), or any set of repos that share a root commit (in a decentralized revision control system like Git).

#### 2. There is always a one-to-one correlation between the codebase and the app.

There is always a one-to-one correlation between the codebase and the app:

* If there are multiple codebases, it's not an app — it's a distributed system. Each component in a distributed system is an app, and each can individually comply with twelve-factor.
* Multiple apps sharing the same code is a violation of twelve-factor.

##### Guidance

If multiple apps need to share functionality, factor out the shared code into libraries that can be included through the dependency manager.

#### 3. One codebase can be deployed in multiple environments.

There is only one codebase per app, but there will be many deploys of the app. A *deploy* is a running instance of the app, typically a production site plus one or more staging sites. Additionally, every developer has a copy of the app running in their local development environment, each of which also qualifies as a deploy.

The codebase is the same across all deploys, although different versions may be active in each deploy. For example, a developer may have some commits not yet deployed to staging; staging may have some commits not yet deployed to production. But they all share the same codebase, making them identifiable as different deploys of the same app.

---

## II. Dependencies
### Explicitly declare and isolate dependencies

#### 1. A twelve-factor app is built and run in deterministic environments.

One benefit of explicit dependency declaration is that it simplifies setup for developers new to the app. The new developer can check out the app's codebase onto their development machine, requiring only the language runtime and dependency manager installed as prerequisites. They will be able to set up everything needed to run the app's code with a deterministic build command.

##### Examples

For example, the build command for Ruby/Bundler is `bundle install`, while for Clojure/Leiningen it is `lein deps`.

#### 2. A twelve-factor app does not rely on the implicit existence of system-wide packages.

It declares all dependencies, completely and exactly, via a dependency declaration manifest. Furthermore, it uses a dependency isolation tool during execution to ensure that no implicit dependencies "leak in" from the surrounding system. The full and explicit dependency specification is applied uniformly to both production and development.

##### Examples

Bundler for Ruby offers the Gemfile manifest format for dependency declaration and `bundle exec` for dependency isolation. In Python there are two separate tools for these steps – Pip is used for declaration and Virtualenv for isolation. Even C has Autoconf for dependency declaration, and static linking can provide dependency isolation. No matter what the toolchain, dependency declaration and isolation must always be used together – only one or the other is not sufficient to satisfy twelve-factor.

#### 3. A twelve-factor app does not rely on the implicit existence of any system tools.

While these tools may exist on many or even most systems, there is no guarantee that they will exist on all systems where the app may run in the future, or whether the version found on a future system will be compatible with the app.

##### Examples

Examples include shelling out to ImageMagick or curl.

##### Guidance

If the app needs to shell out to a system tool, that tool should be vendored into the app.

---

## III. Config
### Store config in the environment

#### 1. A twelve-factor app strictly separates config from code

An app's *config* is everything that is likely to vary between deploys (staging, production, developer environments, etc). Config varies substantially across deploys; code does not. Apps sometimes store config as constants in the code. This is a violation of twelve-factor, which requires **strict separation of config from code**.

A litmus test for whether an app has all config correctly factored out of the code is whether the codebase could be made open source at any moment, without compromising any credentials.

Note that this definition of "config" does **not** include internal application config, such as `config/routes.rb` in Rails, or how code modules are connected in Spring. This type of config does not vary between deploys, and so is best done in the code.

##### Examples

- Resource handles to the database, Memcached, and other backing services
- Credentials to external services such as Amazon S3 or X (formerly Twitter)
- Per-deploy values such as the canonical hostname for the deploy

#### 2. A twelve-factor app stores config in environment variables

Another approach to config is the use of config files which are not checked into revision control, such as `config/database.yml` in Rails. This is a huge improvement over using constants which are checked into the code repo, but still has weaknesses: it's easy to mistakenly check in a config file to the repo; there is a tendency for config files to be scattered about in different places and different formats, making it hard to see and manage all the config in one place. Further, these formats tend to be language- or framework-specific.

**The twelve-factor app stores config in *environment variables*** (often shortened to *env vars* or *env*). Env vars are easy to change between deploys without changing any code; unlike config files, there is little chance of them being checked into the code repo accidentally; and unlike custom config files, or other config mechanisms such as Java System Properties, they are a language- and OS-agnostic standard.

#### 3. A twelve-factor app treats env vars as granular controls, never grouped by environment

Another aspect of config management is grouping. Sometimes apps batch config into named groups (often called "environments") named after specific deploys, such as the `development`, `test`, and `production` environments in Rails. This method does not scale cleanly: as more deploys of the app are created, new environment names are necessary, such as `staging` or `qa`. As the project grows further, developers may add their own special environments like `joes-staging`, resulting in a combinatorial explosion of config which makes managing deploys of the app very brittle.

In a twelve-factor app, env vars are independently managed for each deploy. They are never grouped together as "environments," but instead are treated as granular controls. This model scales up smoothly as the app naturally expands into more deploys over its lifetime.

---

## IV. Backing services
### Treat backing services as attached resources

#### 1. A twelve-factor app relies on backing services for normal operation.

A *backing service* is any service the app consumes over the network as part of its normal operation.

##### Examples

Examples include datastores (such as MySQL or CouchDB), messaging/queueing systems (such as RabbitMQ or Beanstalkd), SMTP services for outbound email (such as Postfix), and caching systems (such as Memcached).

#### 2. A twelve-factor app treats each distinct backing service as an attachable resource.

Each distinct backing service is a *resource*, indicating its loose coupling to the deploy it is attached to.

##### Examples

A MySQL database is a resource; two MySQL databases (used for sharding at the application layer) qualify as two distinct resources.

##### Guidance

Resources can be attached to and detached from deploys at will. For example, if the app's database is misbehaving due to a hardware issue, the app's administrator might spin up a new database server restored from a recent backup. The current production database could be detached, and the new database attached—all without any code changes.

#### 3. A twelve-factor app references all services with a connection string stored in config.

Backing services like the database are traditionally managed by the same systems administrators who deploy the app's runtime. In addition to these locally-managed services, the app may also have services provided and managed by third parties. The code for a twelve-factor app makes no distinction between local and third-party services; to the app, both are *attached resources*, accessed via a URL or other locator/credentials stored in the config.

##### Examples

Examples of third-party services include SMTP services (such as Postmark), metrics-gathering services (such as New Relic or Loggly), binary asset services (such as Amazon S3), and even API-accessible consumer services (such as Twitter, Google Maps, or Last.fm).

##### Guidance

A deploy of the twelve-factor app should be able to swap out a local MySQL database with one managed by a third party (such as Amazon RDS) without any changes to the app's code. Likewise, a local SMTP server could be swapped with a third-party SMTP service (such as Postmark) without code changes. In both cases, only the resource handle in the config needs to change.

---

## V. Build, release, run
### Strictly separate build and run stages

#### 1. An app has distinct build, release, and run stages

A codebase is transformed into a (non-development) deploy through three stages:

* The *build stage* is a transform which converts a code repo into an executable bundle known as a *build*. Using a version of the code at a commit specified by the deployment process, the build stage fetches vendors dependencies and compiles binaries and assets.
* The *release stage* takes the build produced by the build stage and combines it with the deploy's current config. The resulting *release* contains both the build and the config and is ready for immediate execution in the execution environment.
* The *run stage* (also known as "runtime") runs the app in the execution environment, by launching some set of the app's processes against a selected release.

The twelve-factor app enforces strict separation between the build, release, and run stages.

##### Examples

It is impossible to make changes to the code at runtime, since there is no way to propagate those changes back to the build stage. Deployment tools typically offer release management tools, most notably the ability to roll back to a previous release.

#### 2. Each release is a unique, immutable snapshot

Every release should always have a unique release ID, such as a timestamp of the release (for example, `2011-04-06-20:32:17`) or an incrementing number (such as `v100`). Releases are an append-only ledger and a release cannot be mutated once it is created.

##### Guidance

Any change must create a new release.

##### Examples

For example, the Capistrano deployment tool stores releases in a subdirectory named `releases`, where the current release is a symlink to the current release directory. Its `rollback` command makes it easy to quickly roll back to a previous release.

#### 3. Push deployment complexity into the build stage and keep run minimal

Builds are initiated by the app's developers whenever new code is deployed. Runtime execution, by contrast, can happen automatically in cases such as a server reboot or a crashed process being restarted by the process manager.

##### Guidance

Therefore, the run stage should be kept to as few moving parts as possible, since problems that prevent an app from running can cause it to break in the middle of the night when no developers are on hand. The build stage can be more complex, since errors are always in the foreground for a developer who is driving the deploy.

---

## VI. Processes
### Execute the app as one or more stateless processes

#### 1. A twelve-factor app runs as one or more processes.

The app is executed in the execution environment as one or more *processes*.

##### Examples

In the simplest case, the code is a stand-alone script, the execution environment is a developer's local laptop with an installed language runtime, and the process is launched via the command line (for example, `python my_script.py`).

On the other end of the spectrum, a production deploy of a sophisticated app may use many process types, instantiated into zero or more running processes.

#### 2. A twelve-factor app's processes are stateless and share nothing.

Any data that needs to persist must be stored in a stateful backing service, typically a database. The memory space or filesystem of the process can be used as a brief, single-transaction cache (for example, downloading a large file, operating on it, and storing the results of the operation in the database). However, the twelve-factor app never assumes that anything cached in memory or on disk will be available on a future request or job.

With many processes of each type running, chances are high that a future request will be served by a different process. Even when running only one process, a restart (triggered by code deploy, config change, or the execution environment relocating the process to a different physical location) will usually wipe out all local (e.g., memory and filesystem) state.

##### Examples

Asset packagers like django-assetpackager use the filesystem as a cache for compiled assets. A twelve-factor app prefers to do this compiling during the build stage. Asset packagers such as Jammit and the Rails asset pipeline can be configured to package assets during the build stage.

##### Guidance

Some web systems rely on "sticky sessions" — that is, caching user session data in memory of the app's process and expecting future requests from the same visitor to be routed to the same process. Sticky sessions are a violation of twelve-factor and should never be used or relied upon. Session state data is a good candidate for a datastore that offers time-expiration, such as Memcached or Redis.

---

## VII. Port binding
### Export services via port binding

#### 1. A twelve-factor app is completely self-contained and exports HTTP as a service by binding to a port.

Web apps are sometimes executed inside a webserver container. For example, PHP apps might run as a module inside Apache HTTPD, or Java apps might run inside Tomcat. **The twelve-factor app is completely self-contained** and does not rely on runtime injection of a webserver into the execution environment to create a web-facing service. Instead, the web app **exports HTTP as a service by binding to a port** and listening to requests coming in on that port.

##### Examples

In a local development environment, the developer visits a service URL like `http://localhost:5000/` to access the service exported by their app. In deployment, a routing layer handles routing requests from a public-facing hostname to the port-bound web processes.

##### Guidance

This pattern is typically implemented by using dependency declaration to add a webserver library to the app—such as Tornado for Python, Thin for Ruby, or Jetty for Java and other JVM-based languages. This happens entirely in *user space*, within the app's code, fulfilling the contract with the execution environment of binding to a port to serve requests.

#### 2. Port binding enables any service to be exported and allows an app to serve as a backing service.

HTTP is not the only service that can be exported by port binding. Nearly any kind of server software can be run via a process binding to a port and awaiting incoming requests.

##### Examples

Examples include ejabberd (speaking XMPP) and Redis (speaking the Redis protocol). Note also that the port-binding approach means that one app can become the backing service for another app, by providing the URL to the backing app as a resource handle in the config for the consuming app.

##### Guidance

Design your application such that all service exports occur via port binding, ensuring that the app remains self-contained and independent of runtime webserver injection.

---

## VIII. Concurrency
### Scale out via the process model

#### 1. Any computer program, once run, is represented by one or more processes

Any computer program, once run, is represented by one or more processes. Web apps have taken a variety of process-execution forms, and in many cases the running process(es) are only minimally visible to the developers of the app.

##### Examples
- PHP processes run as child processes of Apache, started on demand as needed by request volume.
- Java processes often take the opposite approach, with the JVM providing one large "uberprocess" that reserves a block of system resources on startup, managing concurrency internally via threads.

#### 2. A twelve-factor app treats processes as first-class citizens

**In the twelve-factor app, processes are a first class citizen.** Processes in the twelve-factor app take strong cues from the unix process model for running service daemons.

#### 3. A twelve-factor app scales out by assigning workloads to separate process types

Using this model, the developer can architect the app to handle diverse workloads by assigning each type of work to a *process type*. For example, HTTP requests may be handled by a web process, and long-running background tasks handled by a worker process.

This does not exclude individual processes from handling their own internal multiplexing, via threads inside the runtime VM or the async/evented model found in tools such as EventMachine, Twisted, or Node.js. But an individual VM can only grow so large (vertical scale), so the application must also be able to span multiple processes running on multiple physical machines.

The process model truly shines when it comes time to scale out. The share-nothing, horizontally partitionable nature of twelve-factor app processes means that adding more concurrency is a simple and reliable operation. The array of process types and the number of processes of each type is known as the *process formation*.

#### 4. A twelve-factor app relies on the execution environment to manage processes

Twelve-factor app processes should never daemonize or write PID files.

##### Guidance

Instead, rely on the operating system's process manager (such as systemd, a distributed process manager on a cloud platform, or a tool like Foreman in development) to manage output streams, respond to crashed processes, and handle user-initiated restarts and shutdowns.

---

## IX. Disposability
### Maximize robustness with fast startup and graceful shutdown

#### 1. A twelve-factor app's processes are disposable.

Processes are designed to be started or stopped at a moment's notice. This disposability underpins fast elastic scaling, rapid deployment of code or config changes, and overall production robustness.

##### Examples

Disposable processes allow an app to quickly adapt to changing load or updated releases by simply replacing processes without lengthy downtime.

#### 2. A twelve-factor app's processes minimize startup time.

Processes should start in just a few seconds from the moment the launch command is executed until they are ready to receive requests or jobs. A fast startup is key to agile releases and dynamic scaling.

##### Guidance

Aim for minimal startup time so that process managers can efficiently move processes to new machines and support rapid deployment cycles.

#### 3. A twelve-factor app's processes shut down gracefully.

Processes are expected to handle a SIGTERM signal by cleaning up and exiting in a controlled manner, thereby avoiding abrupt terminations.

##### Examples

For a web process, graceful shutdown is achieved by ceasing to listen on the service port—refusing new requests while allowing current ones to finish. For a worker process, it means returning the current job to the work queue (for example, by sending a NACK on RabbitMQ, relying on automatic job return on Beanstalkd, or releasing a lock in systems like Delayed Job).

##### Guidance

Implement shutdown procedures that allow your processes to complete in-flight tasks or safely return work, ensuring that deployments and scaling events cause minimal disruption.

#### 4. A twelve-factor app's processes are robust against sudden termination.

Even in cases of unexpected, non-graceful shutdown—such as hardware failures—processes are architected to recover without data loss or corruption.

##### Examples

Using a robust queuing backend, such as Beanstalkd, ensures that jobs are returned to the queue when a process disconnects or times out. Embracing crash-only design principles further reinforces system resilience.

##### Guidance

Design your app so that any in-progress work can be recovered or retried automatically, handling unexpected process death with minimal manual intervention.

---

## X. Dev/prod parity
### Keep development, staging, and production as similar as possible

#### 1. A twelve-factor app minimizes the gaps between development, staging, and production.

Historically, there have been substantial gaps between development (a developer making live edits to a local deploy of the app) and production (a running deploy of the app accessed by end users). These gaps manifest in three areas:

- **The time gap**: A developer may work on code that takes days, weeks, or even months to go into production.
- **The personnel gap**: Developers write code, ops engineers deploy it.
- **The tools gap**: Developers may be using a stack like Nginx, SQLite, and OS X, while the production deploy uses Apache, MySQL, and Linux.

**The twelve-factor app is designed for continuous deployment by keeping the gap between development and production small.**

|                               | Traditional app  | Twelve-factor app      |
| ----------------------------- | ---------------- | ---------------------- |
| **Time between deploys**      | Weeks            | Hours                  |
| **Code authors vs deployers** | Different people | Same people            |
| **Dev vs production**         | Divergent        | As similar as possible |

##### Guidance

- Make the time gap small: a developer may write code and have it deployed hours or even just minutes later.
- Make the personnel gap small: developers who wrote code are closely involved in deploying it and watching its behavior in production.
- Make the tools gap small: keep development and production as similar as possible.

#### 2. A twelve-factor app uses the same backing services in all deploys.

Backing services, such as the app's database, queueing system, or cache, are a key area where dev/prod parity is important. Many languages offer libraries which simplify access to the backing service, including *adapters* to different types of services.

| Type     | Language      | Library              | Adapters                      |
| -------- | ------------- | -------------------- | ----------------------------- |
| Database | Ruby/Rails    | ActiveRecord         | MySQL, PostgreSQL, SQLite     |
| Queue    | Python/Django | Celery               | RabbitMQ, Beanstalkd, Redis   |
| Cache    | Ruby/Rails    | ActiveSupport::Cache | Memory, filesystem, Memcached |

Developers sometimes find great appeal in using a lightweight backing service in their local environments, while a more robust backing service is used in production. For example, using SQLite locally and PostgreSQL in production; or local process memory for caching in development and Memcached in production.

**The twelve-factor developer resists the urge to use different backing services between development and production**; tiny incompatibilities can cause code that worked in development or staging to fail in production, creating friction that disincentivizes continuous deployment and incurs high costs over the lifetime of an application.

##### Guidance

All deploys of the app (developer environments, staging, production) should use the same type and version of each backing service. Modern backing services such as Memcached, PostgreSQL, and RabbitMQ are not difficult to install and run thanks to modern packaging systems like Homebrew and apt-get. Declarative provisioning tools such as Chef and Puppet, combined with lightweight virtual environments such as Docker and Vagrant, enable developers to run local environments that closely approximate production.

---

## XI. Logs
### Treat logs as event streams

#### 1. A twelve-factor app produces logs as a stream of time-ordered events.

*Logs* provide visibility into the behavior of a running app. Logs are the stream of aggregated, time-ordered events collected from the output streams of all running processes and backing services. Logs have no fixed beginning or end, but flow continuously as long as the app is operating.

##### Examples

Logs in their raw form are typically a text format with one event per line (though backtraces from exceptions may span multiple lines).

In server-based environments, logs are commonly written to a file on disk (a "logfile"); but this is only an output format. During local development, the developer views the log stream in the foreground of their terminal to observe the app's behavior.

##### Guidance

Each running process writes its event stream, unbuffered, to `stdout`.

#### 2. A twelve-factor app never concerns itself with routing or storage of its output stream.

It should not attempt to write to or manage logfiles. The handling of log streams, including capturing, routing, and storing them, is the responsibility of the execution environment. This allows the event stream for an app to be routed to a file, or watched via real-time tail in a terminal.

##### Examples

The stream can be sent to a log indexing and analysis system such as Splunk, or a general-purpose data warehousing system such as Hadoop/Hive. These systems allow for great power and flexibility for introspecting an app's behavior over time, including:

* Finding specific events in the past.
* Large-scale graphing of trends (such as requests per minute).
* Active alerting according to user-defined heuristics (such as an alert when the quantity of errors per minute exceeds a certain threshold).

##### Guidance

In staging or production deploys, each process' stream will be captured by the execution environment, collated together with all other streams from the app, and routed to one or more final destinations for viewing and long-term archival. These archival destinations are not visible to or configurable by the app, and instead are completely managed by the execution environment. Open-source log routers (such as Logplex and Fluentd) are available for this purpose.

---

## XII. Admin processes
### Run admin/management tasks as one-off processes

#### 1. A twelve-factor app distinguishes between its regular business processes and one-off administrative tasks.

The process formation defines the array of processes used to run the app's regular operations (such as handling web requests). Separately, developers often need to perform ad hoc administrative or maintenance tasks.

##### Examples

Administrative tasks include:

- Running database migrations (e.g. `manage.py migrate` in Django, `rake db:migrate` in Rails).
- Launching a REPL (Read-Eval-Print Loop) shell to execute arbitrary code or inspect the app's models against the live database.
- Executing one-time scripts committed into the app's repository (e.g. `php scripts/fix_bad_records.php`).

#### 2. A twelve-factor app runs admin processes in an environment identical to its long-running processes.

Admin processes are executed against a release using the same codebase and config as all other processes. This ensures consistency and prevents synchronization issues between administrative tasks and the running app.

##### Examples

The same dependency isolation techniques apply to every process type. For instance, if a Ruby web process is started with `bundle exec thin start`, then a database migration should be run with `bundle exec rake db:migrate`. Likewise, a Python application using Virtualenv should invoke the vendored `bin/python` for both the web server and any `manage.py` admin tasks.

##### Guidance

In local deployments, one-off admin processes are invoked directly via shell commands within the app's checkout directory. In production, such tasks are executed using SSH or another remote command execution mechanism provided by the deployment environment.
