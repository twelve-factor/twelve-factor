## I. Codebase
### One codebase tracked in revision control, many deploys

#### 1. A twelve-factor app is always tracked in a version control system.

A twelve-factor app is always tracked in a version control system. A copy of 
the revision tracking database is known as a *code repository*, often shortened 
to *code repo* or just *repo*.

##### Examples

Examples of version control systems include 
[Git](http://git-scm.com/), [Mercurial](https://www.mercurial-scm.org/), 
and [Subversion](http://subversion.apache.org/).

##### Guidance

A *codebase* is any single repo (in a centralized revision control system like 
Subversion), or any set of repos that share a root commit (in a decentralized 
revision control system like Git).

#### 2. There is always a one-to-one correlation between the codebase and the app.

There is always a one-to-one correlation between the codebase and the app:

* If there are multiple codebases, it’s not an app — it’s a distributed system. 
  Each component in a distributed system is an app, and each can individually 
  comply with twelve-factor.
* Multiple apps sharing the same code is a violation of twelve-factor.

![One codebase maps to many deploys](/images/codebase-deploys.png)

##### Guidance

If multiple apps need to share functionality, factor out the shared code into 
libraries that can be included through the [dependency manager](./dependencies.md).

#### 3. One codebase can be deployed in multiple environments.

There is only one codebase per app, but there will be many deploys of the app. 
A *deploy* is a running instance of the app, typically a production site plus 
one or more staging sites. Additionally, every developer has a copy of the app 
running in their local development environment, each of which also qualifies 
as a deploy.

The codebase is the same across all deploys, although different versions may be 
active in each deploy. For example, a developer may have some commits not yet 
deployed to staging; staging may have some commits not yet deployed to 
production. But they all share the same codebase, making them identifiable as 
different deploys of the same app.
