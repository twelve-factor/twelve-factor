## IX. Disposability

### Maximize robustness with fast startup and graceful shutdown

#### 1. A twelve-factor app’s processes are disposable.

Processes are designed to be started or stopped at a moment’s notice. This
disposability underpins fast elastic scaling, rapid deployment of code or config
changes, and overall production robustness.

##### Examples

Disposable processes allow an app to quickly adapt to changing load or updated
releases by simply replacing processes without lengthy downtime.

#### 2. A twelve-factor app’s processes minimize startup time.

Processes should start in just a few seconds from the moment the launch command
is executed until they are ready to receive requests or jobs. A fast startup is
key to agile releases and dynamic scaling.

##### Guidance

Aim for minimal startup time so that process managers can efficiently move
processes to new machines and support rapid deployment cycles.

#### 3. A twelve-factor app’s processes shut down gracefully.

Processes are expected to handle a
[SIGTERM](http://en.wikipedia.org/wiki/SIGTERM) signal by cleaning up and
exiting in a controlled manner, thereby avoiding abrupt terminations.

##### Examples

For a web process, graceful shutdown is achieved by ceasing to listen on the
service port—refusing new requests while allowing current ones to finish. For a
worker process, it means returning the current job to the work queue (for
example, by sending a `NACK` on [RabbitMQ](http://www.rabbitmq.com/), relying on
automatic job return on [Beanstalkd](https://beanstalkd.github.io/), or
releasing a lock in systems like
[Delayed Job](https://github.com/collectiveidea/delayed_job#readme)).

##### Guidance

Implement shutdown procedures that allow your processes to complete in-flight
tasks or safely return work, ensuring that deployments and scaling events cause
minimal disruption.

#### 4. A twelve-factor app’s processes are robust against sudden termination.

Even in cases of unexpected, non-graceful shutdown—such as hardware
failures—processes are architected to recover without data loss or corruption.

##### Examples

Using a robust queuing backend, such as Beanstalkd, ensures that jobs are
returned to the queue when a process disconnects or times out. Embracing
crash-only design principles further reinforces system resilience.

##### Guidance

Design your app so that any in-progress work can be recovered or retried
automatically, handling unexpected process death with minimal manual
intervention.
