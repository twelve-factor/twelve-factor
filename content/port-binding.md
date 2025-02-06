## VII. Port binding

### Export services via port binding

#### 1. A twelve-factor app is completely self-contained and exports HTTP as a service by binding to a port.

Web apps are sometimes executed inside a webserver container. For example, PHP
apps might run as a module inside [Apache HTTPD](http://httpd.apache.org/), or
Java apps might run inside [Tomcat](http://tomcat.apache.org/). **The
twelve-factor app is completely self-contained** and does not rely on runtime
injection of a webserver into the execution environment to create a web-facing
service. Instead, the web app **exports HTTP as a service by binding to a port**
and listening to requests coming in on that port.

##### Examples

In a local development environment, the developer visits a service URL like
`http://localhost:5000/` to access the service exported by their app. In
deployment, a routing layer handles routing requests from a public-facing
hostname to the port-bound web processes.

##### Guidance

This pattern is typically implemented by using
[dependency declaration](./dependencies.md) to add a webserver library to the
app—such as [Tornado](http://www.tornadoweb.org/) for Python,
[Thin](https://github.com/macournoyer/thin) for Ruby, or
[Jetty](http://www.eclipse.org/jetty/) for Java and other JVM-based languages.
This happens entirely in _user space_, within the app’s code, fulfilling the
contract with the execution environment of binding to a port to serve requests.

#### 2. Port binding enables any service to be exported and allows an app to serve as a backing service.

HTTP is not the only service that can be exported by port binding. Nearly any
kind of server software can be run via a process binding to a port and awaiting
incoming requests.

##### Examples

Examples include [ejabberd](http://www.ejabberd.im/) (speaking
[XMPP](http://xmpp.org/)) and [Redis](http://redis.io/) (speaking the
[Redis protocol](http://redis.io/topics/protocol)). Note also that the
port-binding approach means that one app can become the
[backing service](./backing-services.md) for another app, by providing the URL
to the backing app as a resource handle in the [config](./config.md) for the
consuming app.

##### Guidance

Design your application such that all service exports occur via port binding,
ensuring that the app remains self-contained and independent of runtime
webserver injection.
