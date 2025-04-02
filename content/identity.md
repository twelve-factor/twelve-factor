## XII. Identity

### Use a workload identity to connect to backing services

#### 1. A workload identity is connection scoped and is represented by short-lived credentials.

A twelve-factor app is provided with an identity that is specific to each
connected [backing service](./backing-services.md). The credentials for this
identity are delivered via a well-known mechanism (e.g., a file or known network
location) and are short-lived to minimize the risk of compromise.

##### Examples

- An app retrieves its connection-specific credentials from a file like
  `/var/run/identity/token` referenced by an environment variable (e.g.,
  `BACKEND_CREDS`).

##### Guidance

- Ensure that the credentials are short-lived to reduce exposure in case of
  compromise.
- Don not store credentials directly in [config](./config.md) but rather provide
  a reference to where they can be securely retrieved.
- Avoid static credentials; rely on dynamic credentials for connection-specific
  identities injected or retrieved at runtime.

#### 2. The platform provides the identity and validation information for backing services.

The execution platform is responsible for delivering both the workload identity
credentials and the accompanying validation metadata (such as issuer details or
public keys) into the runtime environment. This mechanism ensures that the app
can seamlessly authenticate to backing services without manual configuration of
static secrets.

##### Guidance

- Leverage the platform’s built-in mechanisms to securely inject both the
  identity credentials and its validation details.

#### 3. Backing services validate the workload identity upon connection.

Backing services must verify the provided identity token when an app attempts to
connect. This validation confirms that the token is authentic, unexpired, and
properly scoped, ensuring that the connection is secure and authorized.

##### Guidance

The backing service should be configured with the validation information
specified by the platform. With OIDC this means configuring the expected issuer,
subject and audience values. Then the token can be validated dynamically using
JWKS URL
