# 12 Factor Facets

While the 12 factors serve as helpful specific guidelines for development teams, the rationale behind the factors is to enable a set of application-platform interactions which simplify the operation of applications which follow the recommendations in the factors.  These interactions can be broadly grouped by the platform behaviors they enable, which serve as “facets” of operation where the 12 factors simplify maintenance.  The facets enable applications which are:

* **Continuously Deployable**: it is easy to deploy new software versions in existing environments
* **Composable**: it is easy to set up existing software versions in new environments
* **Scalable**: it is easy to manage the software within an environment
* **Observable**: it is easy to debug the software when running in an production environment

The following sections will map how specific factors contribute to the different facets of application operations.  Applications which apply the contributing factors for a particular facet may be able to derive some benefits from the 12 factors even if they cannot satisfy all of the factors.

# Continuously Deployable

## What

Updateable applications are able to automatically deploy software changes without manual intervention.  These practices have largely been codified as Continuous Integration / Continuous Delivery (CI/CD), but applications which adhere to the updateable facets are able to be *automatically* continuously delivered on an enabling platform without development teams needing to build application-specific deployment pipelines.

## Why

Continuous Deployment enables a number of business benefits, including the ability to easily deploy security and bug patches, as well as lowering the operational toil associated with managing the application.

## Contributing Factors

### 1. Codebase

Having all source code for an application in the same codebase makes it easy to automatically build the software.

### 2. Dependencies

Explicitly storing dependencies (with a lockfile) assists CD in knowing when a dependency needs to be updated and the application rebuilt.

### 3. Config

Explicit configuration in the environment enables deployment without needing to customize the application for each environment.

### 5. Build, Release, Run

Explicitly defining the build process and separating it from running the application helps in defining and automating the delivery process for CD.

### 9. Disposability?

(possible) Disposability means that it is easy to shut down and start up new instances during a rollout without needing manual application orchestration.

### 10. Dev/Prod Parity

Maintaining common software configuration between development, staging and production enables CI/CD processes to automate the deployment and upgrades between environments where applicable.

# Composable

## What

Configurable applications have explicit configuration which allows the underlying software to be customized for new environments without requiring new application software to be written.  This property allows application operators to deploy the application to new environments (cloud platforms, validation platforms, or customer installations) without blocking on the development team to add and release new functionality for that environment.

## Why

Separating the parts of the application which interact with the larger environment and allowing them to be updated and remixed without needing to be rebuilt simplifies deployment and management, and is a common practice for most infrastructure applications.

## Contributing Factors

### 3. Config

Managing application configuration as a series of well-scoped independent variables (rather than flags like “production” or “staging”) enables customizing the application for new environments without needing to update the application itself.

### 4. Backing Services

Explicitly defining backing services as attached resources which are supplied to the application via configuration enables reconfiguring these services for each environment they are deployed to.

### 5. Build, Release, Run

Separating the process of building the application (which happens when the codebase or dependencies change) from the deployment of the application (which happens from an artifact produced by the build) is the critical piece of enabling “configure, don’t rebuild” for applications.

### 10. Dev/Prod Parity

The practice of dev/prod parity is enabled and reinforced by application configurability – developers should be able to use the same application builds between development and production by changing configuration.  This is particularly useful when working with constellations of applications – only the application under development testing needs to be built, while the other applications only need configuration.

# Scalable

## What

Scalable applications are able to grow and shrink to handle varying levels of application traffic. These applications are able to take advantage of multiple processors and physical machines to automatically handle large amounts of load, while also occupying a much smaller footprint when the load is not present.

## Why

Scalability minimizes the amount of work operations teams need to do to manage day-to-day traffic growth, and enables applications to easily handle spikes of requests and or low-traffic periods.  In particular, *horizontal scalability* enables applications to run as a series of identical processes, which can scale larger than the capacity of a single piece of hardware.  Additionally, horizontal scalability allows applications to be resilient to failures of a single hardware device.

## Contributing Factors

### 4. Backing Services

By separating backing services across a network connection, it becomes easier to scale application processes across multiple hosts.  Services which are provided only to the local machine require additional setup and possibly replication when compared with network services, and so should be avoided.

### 6. Processes

Running the application as one or more stateless processes makes it easier to increase and decrease the number of instances of the application, without requiring coordination between the application and the platform layer to choose an instance, and without requiring coordination between application servers to handle loss of state.

### 7. Port Binding

Exposing services via port binding (or a higher-level service, such as HTTP) allows the platform to understand and control which instances are *active*, and which may be scaled down or are available to receive a new request when scaling up.

### 8. Concurrency

Scale-out via concurrency is the cornerstone of scalable applications. By ensuring that each instance is an independent share-nothing process which is designed to run multiple instances, application authors can enable scalability without needing to invest deeply in the complexity of distributed applications.

### 9. Disposability

Automatic, well-managed startup and shutdown is essential for the automation of scaling via the concurrency model.  While an application could be built to scale via the concurrency model without assuming instances are easily replaced, it would be difficult to connect such an application to infrastructure which could scale it automatically.

# Observable

## What

Observable applications make it possible to understand and measure the state of the running application by making measurements without disturbing the running code.  Examples of these measurements can include aggregate metrics, logged application messages, traces and profiles captured during application execution, and more.

## Why

While local development instances may be easy to debug and interact with by pausing and interacting with using a debugger, scalable distributed systems in production often need to be able to operate continuously, even while debugging issues.  Applications which provide a suite of interfaces to understand the internal application state while operating are easier to fix and maintain than applications which need interactive debugging, particularly for issues caused by data differences between environments.

## Contributing Factors

### 4. Backing Services?

(possible) treating all connected services as network-connected, measurement of basic system interactions (tracing, latency metrics, errors) can be measured more easily and uniformly at the application level.

### 6. Processes

Applications which execute as stateless share-nothing processes are more easily able to represent their own internal state without needing to coordinate and represent data from other processes.

### 7. Port Binding

Applications which present a network (or HTTP) port as their primary point of interaction are more easily able to measure and represent their work than applications which operate in coordination with other software to process a request – for example, correlating a request with more detailed information derived from a backing service when reporting an error.

### 8. Concurrency

Applications which scale out via the concurrency model need better observability, because there are many parallel things going on which cannot be paused and debugged in unison.

### 11. Logs

(Assuming this is renamed to Observability) Exporting application internal state via well-defined interfaces enables the external collection and aggregation of these metrics across all application instances, or even across collections of instances for correlation of events.
