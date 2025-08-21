## VI. Processes

### Execute the app as one or more stateless processes

#### 1. A twelve-factor app runs as one or more processes.

The app is executed in the execution environment as one or more _processes_.

##### Examples

In the simplest case, the code is a stand-alone script, the execution
environment is a developer’s local laptop with an installed language runtime,
and the process is launched via the command line (for example,
`python my_script.py`).

On the other end of the spectrum, a production deploy of a sophisticated app may
use many
[process types, instantiated into zero or more running processes](./concurrency.md).

#### 2. A twelve-factor app’s processes are stateless and share nothing.

Any data that needs to persist must be stored in a stateful
[backing service](./backing-services.md), typically a database. The memory space
or filesystem of the process can be used as a brief, single-transaction cache
(for example, downloading a large file, operating on it, and storing the results
of the operation in the database). However, the twelve-factor app never assumes
that anything cached in memory or on disk will be available on a future request
or job.

With many processes of each type running, chances are high that a future request
will be served by a different process. Even when running only one process, a
restart (triggered by code deploy, config change, or the execution environment
relocating the process to a different physical location) will usually wipe out
all local (e.g., memory and filesystem) state.

##### Examples

Asset packagers like
[django-assetpackager](http://code.google.com/p/django-assetpackager/) use the
filesystem as a cache for compiled assets. A twelve-factor app prefers to do
this compiling during the [build stage](./build-release-run.md). Asset packagers
such as [Jammit](http://documentcloud.github.io/jammit/) and the
[Rails asset pipeline](http://ryanbigg.com/guides/asset_pipeline.html) can be
configured to package assets during the build stage.

##### Guidance

Some web systems rely on
["sticky sessions"](http://en.wikipedia.org/wiki/Load_balancing_%28computing%29#Persistence)
— that is, caching user session data in memory of the app’s process and
expecting future requests from the same visitor to be routed to the same
process. Sticky sessions are a violation of twelve-factor and should never be
used or relied upon. Session state data is a good candidate for a datastore that
offers time-expiration, such as [Memcached](http://memcached.org/) or
[Redis](http://redis.io/).

#### 3. A twelve-factor app distinguishes between its regular business processes and one-off administrative tasks.

The [process formation](./concurrency.md) defines the array of processes used to
run the app’s regular operations (such as handling web requests). Separately,
developers often need to perform ad hoc administrative or maintenance tasks.

##### Examples

Administrative tasks include:

- Running database migrations (e.g. `manage.py migrate` in Django,
  `rake db:migrate` in Rails).
- Launching a REPL (Read-Eval-Print Loop) shell to execute arbitrary code or
  inspect the app’s models against the live database.
- Executing one-time scripts committed into the app’s repository (for example,
  `php scripts/fix_bad_records.php`).

#### 4. A twelve-factor app runs admin processes in an environment identical to its long-running processes.

Admin processes are executed against a [release](./build-release-run.md) using
the same [codebase](./codebase.md) and [config](./config.md) as all other
processes. This ensures consistency and prevents synchronization issues between
administrative tasks and the running app.

##### Examples

The same [dependency isolation](./dependencies.md) techniques apply to every
process type. For instance, if a Ruby web process is started with
`bundle exec thin start`, then a database migration should be run with
`bundle exec rake db:migrate`. Likewise, a Python application using Virtualenv
should invoke the vendored `bin/python` for both the web server and any
`manage.py` admin tasks.

##### Guidance

In local deployments, one-off admin processes are invoked directly via shell
commands within the app’s checkout directory. In production, such tasks are
executed using SSH or another remote command execution mechanism provided by the
deployment environment.
