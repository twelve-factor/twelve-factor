## III. Config

### Store config in the environment

#### 1. A twelve-factor app strictly separates config from code

An app's _config_ is everything that is likely to vary between
[deploys](./codebase.md) (staging, production, developer environments, etc).
Config varies substantially across deploys; code does not. Apps sometimes store
config as constants in the code. This is a violation of twelve-factor, which
requires **strict separation of config from code**.

A litmus test for whether an app has all config correctly factored out of the
code is whether the codebase could be made open source at any moment, without
compromising any credentials.

Note that this definition of "config" does **not** include internal application
config, such as `config/routes.rb` in Rails, or how
[code modules are connected](http://docs.spring.io/spring/docs/current/spring-framework-reference/html/beans.html)
in [Spring](http://spring.io/). This type of config does not vary between
deploys, and so is best done in the code.

##### Examples

- Resource handles to the database, Memcached, and other
  [backing services](./backing-services.md)
- Credentials to external services such as Amazon S3 or X (formerly Twitter)
- Per-deploy values such as the canonical hostname for the deploy

#### 2. A twelve-factor app stores config in environment variables

Another approach to config is the use of config files which are not checked into
revision control, such as `config/database.yml` in Rails. This is a huge
improvement over using constants which are checked into the code repo, but still
has weaknesses: it's easy to mistakenly check in a config file to the repo;
there is a tendency for config files to be scattered about in different places
and different formats, making it hard to see and manage all the config in one
place. Further, these formats tend to be language- or framework-specific.

**The twelve-factor app stores config in _environment variables_** (often
shortened to _env vars_ or _env_). Env vars are easy to change between deploys
without changing any code; unlike config files, there is little chance of them
being checked into the code repo accidentally; and unlike custom config files,
or other config mechanisms such as Java System Properties, they are a language-
and OS-agnostic standard.

#### 3. A twelve-factor app treats env vars as granular controls, never grouped by environment

Another aspect of config management is grouping. Sometimes apps batch config
into named groups (often called "environments") named after specific deploys,
such as the `development`, `test`, and `production` environments in Rails. This
method does not scale cleanly: as more deploys of the app are created, new
environment names are necessary, such as `staging` or `qa`. As the project grows
further, developers may add their own special environments like `joes-staging`,
resulting in a combinatorial explosion of config which makes managing deploys of
the app very brittle.

In a twelve-factor app, env vars are independently managed for each deploy. They
are never grouped together as "environments," but instead are treated as
granular controls. This model scales up smoothly as the app naturally expands
into more deploys over its lifetime.

#### 4. A twelve-factor app uses environment variables to locate dynamic credentials

While configuration should ideally remain static for the lifetime of a process
instance (tied to a [release](./release-stage.md)), a critical exception exists
for short-lived credentials required to securely connect to
[backing services](./backing-services.md). These credentials _must_ rotate
during the process lifetime for security.

**The twelve-factor app handles this by storing the _location_ where the current
credential can be retrieved in an environment variable.** This location might be
a file path or a network address. The environment variable itself, specifying
this location, is static configuration set per deploy. The application code
reads the credential from the location specified by the env var when needed.

This approach maintains the strict separation of config (the static location
pointer in the env var) from code (the logic to read from that location), and
preserves operational simplicity. The specific mechanisms for providing and
managing these short-lived credentials are detailed in the
[Identity](./identity.md) factor.

##### Examples

- An environment variable `DB_CREDS` contains a reference to credentials that
  are stored in `/var/run/identity/token`.

##### Guidance

- Use this pattern strictly for retrieving credentials that require rotation
  during the process lifetime.
- Configure the _location_ of the credential via an environment variable, not
  the credential value itself.
- For all other configuration changes, prefer creating a new release and
  restarting processes.
