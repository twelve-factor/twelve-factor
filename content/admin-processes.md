## XII. Admin processes

### Run admin/management tasks as one-off processes

#### 1. A twelve-factor app distinguishes between its regular business processes and one-off administrative tasks.

The [process formation](./concurrency.md) defines the array of processes used to
run the app’s regular operations (such as handling web requests). Separately,
developers often need to perform ad hoc administrative or maintenance tasks.

##### Examples

Administrative tasks include:

- Running database migrations (e.g. `manage.py migrate` in Django,
  `rake db:migrate` in Rails).
- Launching a REPL (Read-Eval-Print Loop) shell to execute arbitrary code or
  inspect the app’s models against the live database.
- Executing one-time scripts committed into the app’s repository (e.g.
  `php scripts/fix_bad_records.php`).

#### 2. A twelve-factor app runs admin processes in an environment identical to its long-running processes.

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
