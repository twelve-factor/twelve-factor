## V. Build, release, run
### Strictly separate build and run stages

#### 1\. An app has distinct build, release, and run stages

A [codebase](./codebase.md) is transformed into a (non-development) deploy
through three stages:

* The *build stage* is a transform which converts a code repo into an
  executable bundle known as a *build*. Using a version of the code at a commit
  specified by the deployment process, the build stage fetches vendors
  [dependencies](./dependencies.md) and compiles binaries and assets.
* The *release stage* takes the build produced by the build stage and combines
  it with the deploy’s current [config](./config.md). The resulting *release*
  contains both the build and the config and is ready for immediate execution
  in the execution environment.
* The *run stage* (also known as "runtime") runs the app in the execution
  environment, by launching some set of the app’s [processes](./processes.md)
  against a selected release.

The twelve-factor app enforces strict separation between the build, release,
and run stages.

##### Examples

It is impossible to make changes to the code at runtime, since there is no way
to propagate those changes back to the build stage. Deployment tools typically
offer release management tools, most notably the ability to roll back to a
previous release.

#### 2\. Each release is a unique, immutable snapshot

Every release should always have a unique release ID, such as a timestamp of
the release (for example, `2011-04-06-20:32:17`) or an incrementing number
(such as `v100`). Releases are an append-only ledger and a release cannot be
mutated once it is created.

##### Guidance

Any change must create a new release.

##### Examples

For example, the [Capistrano](https://github.com/capistrano/capistrano/wiki)
deployment tool stores releases in a subdirectory named `releases`, where the
current release is a symlink to the current release directory. Its `rollback`
command makes it easy to quickly roll back to a previous release.

#### 3\. Push deployment complexity into the build stage and keep run minimal

Builds are initiated by the app’s developers whenever new code is deployed.
Runtime execution, by contrast, can happen automatically in cases such as a
server reboot or a crashed process being restarted by the process manager.

##### Guidance

Therefore, the run stage should be kept to as few moving parts as possible,
since problems that prevent an app from running can cause it to break in the
middle of the night when no developers are on hand. The build stage can be more
complex, since errors are always in the foreground for a developer who is
driving the deploy.

