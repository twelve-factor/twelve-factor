## IV. Backing services

### Treat backing services as attached resources

#### 1. A twelve-factor app relies on backing services for normal operation.

A _backing service_ is any service the app consumes over the network as part of
its normal operation.

##### Examples

Examples include datastores (such as [MySQL](http://dev.mysql.com/) or
[CouchDB](http://couchdb.apache.org/)), messaging/queueing systems (such as
[RabbitMQ](http://www.rabbitmq.com/) or
[Beanstalkd](https://beanstalkd.github.io)), SMTP services for outbound email
(such as [Postfix](http://www.postfix.org/)), and caching systems (such as
[Memcached](http://memcached.org/)).

#### 2. A twelve-factor app treats each distinct backing service as an attachable resource.

Each distinct backing service is a _resource_, indicating its loose coupling to
the deploy it is attached to.

##### Examples

A MySQL database is a resource; two MySQL databases (used for sharding at the
application layer) qualify as two distinct resources.

![A production deploy attached to four backing services.](/images/attached-resources.png)

##### Guidance

Resources can be attached to and detached from deploys at will. For example, if
the app’s database is misbehaving due to a hardware issue, the app’s
administrator might spin up a new database server restored from a recent backup.
The current production database could be detached, and the new database
attached—all without any code changes.

#### 3. A twelve-factor app references all services with a connection string stored in config.

Backing services like the database are traditionally managed by the same systems
administrators who deploy the app's runtime. In addition to these
locally-managed services, the app may also have services provided and managed by
third parties. The code for a twelve-factor app makes no distinction between
local and third-party services; to the app, both are _attached resources_,
accessed via a URL or other locator/credentials stored in the
[config](./config.md).

##### Examples

Examples of third-party services include SMTP services (such as
[Postmark](http://postmarkapp.com/)), metrics-gathering services (such as
[New Relic](http://newrelic.com/) or [Loggly](http://www.loggly.com/)), binary
asset services (such as [Amazon S3](http://aws.amazon.com/s3/)), and even
API-accessible consumer services (such as [Twitter](http://dev.twitter.com/),
[Google Maps](https://developers.google.com/maps/), or
[Last.fm](http://www.last.fm/api)).

##### Guidance

A [deploy](./codebase.md) of the twelve-factor app should be able to swap out a
local MySQL database with one managed by a third party (such as
[Amazon RDS](http://aws.amazon.com/rds/)) without any changes to the app's code.
Likewise, a local SMTP server could be swapped with a third-party SMTP service
(such as Postmark) without code changes. In both cases, only the resource handle
in the config needs to change.
