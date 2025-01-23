## VIII. Concurrency
### Scale out via the process model

#### 1. Any computer program, once run, is represented by one or more processes

Any computer program, once run, is represented by one or more processes. Web
apps have taken a variety of process-execution forms, and in many cases the
running process(es) are only minimally visible to the developers of the app.

##### Examples
- PHP processes run as child processes of Apache, started on demand as needed
  by request volume.
- Java processes often take the opposite approach, with the JVM providing one
  large “uberprocess” that reserves a block of system resources on startup,
  managing concurrency internally via threads.

![Scale is expressed as running processes, workload diversity is expressed as process types.](/images/process-types.png)

#### 2. A twelve-factor app treats processes as first-class citizens

**In the twelve-factor app, processes are a first class citizen.** Processes in
the twelve-factor app take strong cues from [the unix process model for running
service
daemons](https://adam.herokuapp.com/past/2011/5/9/applying_the_unix_process_model_to_web_apps/).

#### 3. A twelve-factor app scales out by assigning workloads to separate process types

Using this model, the developer can architect the app to handle diverse
workloads by assigning each type of work to a *process type*. For example, HTTP
requests may be handled by a web process, and long-running background tasks
handled by a worker process.

This does not exclude individual processes from handling their own internal
multiplexing, via threads inside the runtime VM or the async/evented model
found in tools such as
[EventMachine](https://github.com/eventmachine/eventmachine),
[Twisted](http://twistedmatrix.com/trac/), or [Node.js](http://nodejs.org/).
But an individual VM can only grow so large (vertical scale), so the
application must also be able to span multiple processes running on multiple
physical machines.

The process model truly shines when it comes time to scale out. The
[share-nothing, horizontally partitionable nature of twelve-factor app
processes](./processes) means that adding more concurrency is a simple and
reliable operation. The array of process types and the number of processes of
each type is known as the *process formation*.

#### 4. A twelve-factor app relies on the execution environment to manage processes

Twelve-factor app processes [should never
daemonize](https://web.archive.org/web/20190827220442/http://dustin.sallings.org/2010/02/28/running-processes.html)
or write PID files.

##### Guidance
Instead, rely on the operating system's process manager (such as
[systemd](https://www.freedesktop.org/wiki/Software/systemd/), a distributed
process manager on a cloud platform, or a tool like
[Foreman](http://blog.daviddollar.org/2011/05/06/introducing-foreman.html) in
development) to manage [output streams](./logs), respond to crashed processes,
and handle user-initiated restarts and shutdowns.
