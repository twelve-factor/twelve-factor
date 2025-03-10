## XII. Identity

### Use a short-lived workload identity to connect to backing services

#### 1. A twelve-factor app uses a connection-specific, short-lived workload identity to connect to backing services.

A twelve-factor app is provided with a dynamic, ephemeral identity that is
specific to each connected [backing service](./backing-services.md). This
identity is delivered via a well-known location (e.g., a file or known network
location) and is short-lived to minimize the risk of compromise.

##### Examples

- An app retrieves its connection-specific identity from a file like
  `/var/run/identity/token` referenced by an environment variable (e.g.,
  `DEFAULT_IDENTITY`).

##### Guidance

- Ensure that the workload identity is short-lived to reduce exposure in case of
  compromise.
- Avoid static credentials; rely on dynamic, connection-specific identities
  injected or retrieved at runtime.

#### 2. The platform provides the identity and validation information for backing services.

The execution platform is responsible for delivering both the workload identity
and the accompanying validation metadata (such as issuer details or public keys)
into the runtime environment. This mechanism ensures that the app can seamlessly
authenticate to backing services without manual configuration of static secrets.

##### Examples

- A cloud platform might expose the identity token along with validation
  endpoints (e.g., issuer URL, JWKS URL) via dynamic configuration.
- The platform can offer an explicit connection model or an exchange mechanism
  that allows the app to obtain a service-specific token from the default
  identity.

##### Guidance

- Leverage the platform’s built-in mechanisms to securely inject both the
  identity and its validation details.
- Use dynamic [configuration](./config.md) to keep identity and validation
  information current and automatically rotated.

#### 3. Backing services validate the workload identity upon connection.

Backing services must verify the provided identity token when an app attempts to
connect. This validation confirms that the token is authentic, unexpired, and
properly scoped, ensuring that the connection is secure and authorized.

##### Guidance

The backing service should be configured with the validation information
specified by the platform. With OIDC this means configuring the expected issuer,
subject and audience values. Then the token can be validated dynamically using
JWKS URL
