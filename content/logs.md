## XI. Logs
### Treat logs as event streams

#### 1\. A twelve-factor app produces logs as a stream of time-ordered events.

*Logs* provide visibility into the behavior of a running app. Logs are the
[stream](https://adam.herokuapp.com/past/2011/4/1/logs_are_streams_not_files/)
of aggregated, time-ordered events collected from the output streams of all
running processes and backing services. Logs have no fixed beginning or end,
but flow continuously as long as the app is operating.

##### Examples

Logs in their raw form are typically a text format with one event per line
(though backtraces from exceptions may span multiple lines).

In server-based environments, logs are commonly written to a file on disk (a
"logfile"); but this is only an output format. During local development, the
developer views the log stream in the foreground of their terminal to observe
the app’s behavior.

##### Guidance

Each running process writes its event stream, unbuffered, to `stdout`.

#### 2\. A twelve-factor app never concerns itself with routing or storage of its output stream.

It should not attempt to write to or manage logfiles. The handling of log
streams, including capturing, routing, and storing them, is the responsibility
of the execution environment. This allows the event stream for an app to be
routed to a file, or watched via real-time tail in a terminal.

##### Examples

The stream can be sent to a log indexing and analysis system such as
[Splunk](http://www.splunk.com/), or a general-purpose data warehousing system
such as [Hadoop/Hive](http://hive.apache.org/).  These systems allow for great
power and flexibility for introspecting an app's behavior over time, including:

* Finding specific events in the past.
* Large-scale graphing of trends (such as requests per minute).
* Active alerting according to user-defined heuristics (such as an alert when
  the quantity of errors per minute exceeds a certain threshold).

##### Guidance

In staging or production deploys, each process' stream will be captured by the
execution environment, collated together with all other streams from the app,
and routed to one or more final destinations for viewing and long-term
archival.  These archival destinations are not visible to or configurable by
the app, and instead are completely managed by the execution environment.
Open-source log routers (such as [Logplex](https://github.com/heroku/logplex)
and [Fluentd](https://github.com/fluent/fluentd)) are available for this
purpose.
