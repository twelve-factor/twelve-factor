## II. Dependencies
### Explicitly declare and isolate dependencies

#### 1\. A twelve-factor app is built and run in deterministic environments.

One benefit of explicit dependency declaration is that it simplifies setup for developers new to the app. The new developer can check out the app’s codebase onto their development machine, requiring only the language runtime and dependency manager installed as prerequisites. They will be able to set up everything needed to run the app’s code with a deterministic build command.

##### Examples

For example, the build command for Ruby/Bundler is bundle install, while for Clojure/Leiningen it is lein deps.

#### 2\. A twelve-factor app does not rely on the implicit existence of system-wide packages.

It declares all dependencies, completely and exactly, via a dependency declaration manifest. Furthermore, it uses a dependency isolation tool during execution to ensure that no implicit dependencies “leak in” from the surrounding system. The full and explicit dependency specification is applied uniformly to both production and development.

##### Examples

For example, Bundler for Ruby offers the Gemfile manifest format for dependency declaration and bundle exec for dependency isolation. In Python there are two separate tools for these steps – Pip is used for declaration and Virtualenv for isolation. Even C has Autoconf for dependency declaration, and static linking can provide dependency isolation. No matter what the toolchain, dependency declaration and isolation must always be used together – only one or the other is not sufficient to satisfy twelve-factor.

#### 3\. A twelve-factor app does not rely on the implicit existence of any system tools.

While these tools may exist on many or even most systems, there is no guarantee that they will exist on all systems where the app may run in the future, or whether the version found on a future system will be compatible with the app.

##### Examples

Examples include shelling out to ImageMagick or curl.

##### Guidance

If the app needs to shell out to a system tool, that tool should be vendored into the app.
