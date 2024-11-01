# Twelve-Factor Update FAQ

## What is this?

We aim to refine and modernize the twelve-factor manifesto. The manifesto must
be **refined**, shedding outdated concepts and focusing on core application
design for cloud deployment. Then the manifesto can be **modernized** for the
current generation of cloud applications, providing best practices for
observability, security, configuration, etc. These changes will make it easier
to deploy, manage, and migrate twelve-factor applications across multiple
compute runtimes and environments (local, testing, staging, production).

The original manifesto is a foundational work that continues to be relevant
today. We plan to make respectful updates to the original, sticking closely to
its spirit and goals. We will also make sure that the original text remains
available as part of the new website.

We intend to work mindfully on the changes in this repository, **beginning by
separating the principles from the examples and updating the examples to
reflect modern practices**. We will start with the simplifying constraint of
stateless request-based apps that made the initial model so popular before
expanding to include other modern workload types.

The examples and guidelines serve as a [**living
document**](https://whatwg.org/faq#living-standard). As best practices evolve,
the maintainer group will adjust the recommendations to ensure the timeless
concepts remain applicable to ecosystem changes. Refer to [the governance
document](GOVERNANCE.md#change-management-process) for the process we will use
to evolve the factors.

## Why now?

Over a decade ago, Heroku co-founder Adam Wiggins published the [Twelve-Factor
App methodology](https://blog.heroku.com/twelve-factor-apps) as a way to codify
the [best practices for writing SaaS
applications](https://en.wikipedia.org/wiki/Twelve-Factor_App_methodology). In
that time, cloud-native has become the default for all new applications, and
technologies like Kubernetes are widespread. Best-practices for software have
evolved, and we believe that Twelve-Factor also needs to evolve.

But we also believe that the core ideas in twelve-factor are timeless and are
more relevant than ever. “The Twelve-Factor App” started a revolution based on
this idea: if there is a clean interface contract between applications and
platforms, application developers can build portable, scalable applications
across multiple compute runtimes and environments (local, testing, staging,
production).

This was decidedly *not* the state of affairs in 2011, when “The Twelve-Factor
App” was first written. By outlining a contract between applications and
platforms, that began to change. Over the years, much of the contract defined
by twelve-factor has become conventional wisdom. At the same time, applications
have become more sophisticated, and the ecosystem’s best practices have drifted
away from the details outlined in the original manifesto.

The goal of this refresh is to revitalize and modernize the contract between
applications and platforms, retaining a strong focus on the perspective of the
application codebase.

## Why isn't \[my favorite software development principle\] a factor?

When selecting factors, we hold closely to the principles laid out in our
[vision](VISON.md). Twelve-factor isn't intended to be a collection of
everything you need to think about when building an application. It
specifically focuses on the interfaces between the application and the
platform. This means that a number of software development principles (DRY,
YAGNI, KISS, etc.) will never be explicit factors.

Additionally, the factors are intended to be agnostic to the programming
language which applications are built in – the factors should apply
consistently whether the application is written in Java, bash, or Haskell.

Finally, some factors may simply be too early to include. Twelve-factor strikes
a balance between capturing established practices and promoting practices that
are not yet widely used. There is no hard-and-fast rule for how established a
practice must be, so inclusion is a judgment call by the maintainers.

## Who’s helping and why?

Twelve-Factor is a community effort, led by application, platform, and
framework developers that understand the value of common principles and shared
understanding of the contract between an application and its underlying
platform. The current list of maintainers can be found in
[MAINTAINERS.md](MAINTAINERS.md).

## Will there always be twelve factors?

The original manifesto had twelve factors. We intend to keep the number of
factors the same. In addition to helping with name-recognition, we view this as
a valuable constraint to keep the manifesto focused and clear.

## What’s not changing?

The introductory framing, which is a great guiding philosophy for the project,
and is just as true today as it was in 2012.

The scope and purpose of the factors will also remain the same. They are
**application** best practices that define a contract between the application
code and a deployment platform.

## What is changing?

The original document contains examples and guidelines that have drifted away
from ecosystem best-practices. We plan to start by modernizing the examples and
guidelines to bring them up to date with current practices. We also plan to
make changes to the structure of the factors so that we can continue to evolve
them moving forward.

## Are you just updating the examples?

One of the key values of the original manifesto was driving consensus across
development communities and driving changes that made it easier to build
applications. We intend for the new version to do the same. We hope to
encourage collaboration across communities to solve thorny application problems
like authentication and service-to-service communication.
