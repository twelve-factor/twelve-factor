# Twelve-Factor Governance

This document defines the governance structure for the twelve-factor manifesto
maintained at [https://12factor.net](https://12factor.net). This project is
committed to building an open, inclusive, productive and self-governing open
source community. The guidelines herein describe how the twelve-factor
community should work together to achieve this goal.

## Membership

A member of the project is a person who has contributed to twelve-factor via
source code, documentation, pull requests, issues, or discussions. A member may
additionally have one of the roles listed below. Roles are tied to individuals,
not companies. Therefore a person leaving a role from a company cannot transfer
the role to someone else in that company.

### Maintainers

Maintainers are members who are in charge of the day-to-day work of the project
and its technical governing body. The [maintainership group](MAINTAINERS.md) should be
sufficiently large to provide diverse perspectives and ensure sustainable
governance, ideally comprising more than ten but fewer than fifty members.
Maintainers oversee all aspects of the project and have a mandate to drive
consensus for:

* Defining and maintaining the mission and charter for the project.
* Fostering a healthy and welcoming community, including by defining and
  enforcing our Code of Conduct.
* Defining the governance structure of the project including how changes are
  proposed and merged.
* Anything else that falls through the cracks.

New maintainers must be nominated by existing maintainers and elected by a
(66%+) supermajority of the maintainers. Maintainers may graduate to emeritus
status by request or by a super-majority vote of the rest of the maintainers.

### Contributors

Contributors are members who make regular contributions (documentation,
reviews, responding to issues, participation in proposal discussions, code,
etc.) and are therefore granted additional permissions (triaging issues,
merging approved PRs, pushing to non-protected branches) that support those
activities.

New contributors may be self-nominated or be nominated by existing
contributors, and must be approved by a super-majority of the maintainers.
Likewise, contributors may resign or can be removed by a super-majority of
maintainers.

### Emeritus

Serving as a member of an open source project requires a significant amount of
work that cannot be sustained indefinitely. The project recognizes emeritus
members to whom we will always be grateful, but who no longer actively
participate in the project.

Project members should graduate to emeritus status through self-nomination when
they no longer intend to actively fulfill an assigned role in the project.
Members holding multiple roles may choose emeritus status for one role while
retaining other roles.

As a guideline, when members have not been active contributors for longer than
3 months they should be nominated to be moved to emeritus. Out of courtesy, a
notice for nomination should be given to members that fall under this category
prior to being nominated.

If emeritus members in a leadership position in the project wish to regain an
active role, they may skip the normal nomination process and can do so by
renewing their contributions for at least two weeks and contacting an existing
maintainer to review their work and mark them active again.

## Change Management Process

The twelve-factor manifesto is treated as a foundational reference, so changes
follow a defined process:

* **Change Principles**: To accept or reject a change, the following principles
  will be used:
  * Changes should align with the core values and objectives in the
    [Twelve-Factor Vision](VISION.md).
  * Consensus among maintainers is preferred, aiming for broad agreement.
* **Change Approval**: Changes require different levels of approval depending
  on their significance. Medium and large changes should be open for feedback
  for a minimum of one week. This ensures the community has time to comment.
  Members can \-1 the change to represent concerns that need to be discussed. A
  vote should only be held if consensus cannot be reached.
  * **Small Changes**: These include minor updates such as grammar corrections,
    clarifications, or updates to examples. Small changes require sign-off from
    at least one maintainer, with no active maintainer concerns.
  * **Medium Changes**: These include significant modifications to an existing
    factor, such as changing recommendations or updating the scope of a factor.
    Medium changes require sign-off from at least three maintainers, with no
    active maintainer concerns.
  * **Large Changes**: These include adding a new factor, removing an existing
    factor, or making substantial alterations to core principles. Large changes
    require sign-off from at least five maintainers, with no active maintainer
    concerns.
* **Version Control**: Medium and large changes will be made in a "next" branch
  within the version control system (e.g., Git), allowing the community to test
  and evaluate proposed modifications before they are finalized. This ensures
  traceability and the ability to easily review and revert changes if needed.

## Major Releases

Once the changes in the "next" branch have been tested and reviewed,
maintainers will review the set of changes and sign off with a supermajority on
"major releases" of the principles. This process moves the changes from the
"next" branch to the main branch, officially updating the manifesto. Major
releases will happen no more than once a year to ensure stability and provide
sufficient time for evaluation and community feedback.

## Updating Governance

All substantive changes in Governance require a supermajority agreement by the
maintainers.

## Brand

In its pre-foundation form, Heroku will retain control over the brand of the
project. The brand is inclusive of any associated logos, trademarks, and site
designs. The intent is to find a longer term home where this will all be
transferred to a foundation for community governance. The governance will be
updated to reflect when this change occurs.

## Code of Conduct

For code of conduct, we will follow the [Contributor
Covenant](https://www.contributor-covenant.org/). In case of violations of the
covenant, the following process will be followed:

1. **Initial Report**: Violations must be reported to the
   [maintainers](MAINTAINERS.md). Reports can be submitted anonymously or
   directly to a designated maintainer.
2. **Assessment**: Upon receiving a report, a team of three (3) maintainers
   will be selected to assess the situation and gather relevant information.
   This may involve interviewing the involved parties and any witnesses.
3. **Decision**: Based on the gathered information, maintainers will decide on
   the appropriate action. Actions may include issuing warnings, requiring a
   formal apology, removing members from roles, or banning individuals from
   participation.
4. **Notification**: The involved parties will be informed of the decision, and
   a record will be kept for future reference.
5. **Appeal**: The individual subject to disciplinary action has the right to
   appeal the decision. Appeals will be reviewed by a panel of maintainers not
   directly involved in the initial assessment.

Actions may vary depending on the severity of the infraction, and maintainers
will strive to apply consequences consistently and fairly.

## Definitions

#### Supermajority

Throughout these documents, "supermajority" means 66%+.
