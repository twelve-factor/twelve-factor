## XII. Identity

### Use a workload identity to connect to backing services

#### 1. Workload identity credentials used for a connection are narrowly scoped and short-lived.

A twelve-factor app connects to a [backing service](./backing-services.md) using
credentials that are restricted to the minimal necessary scope for that
connection and are short-lived to reduce the risk of misuse.

##### Examples

- The platform issues a short-lived OIDC JWT or [SPIFFE](https://spiffe.io/)
  JWT-SVID already tied to the intended backing service.
- A [WIMSE](https://datatracker.ietf.org/doc/draft-ietf-wimse-s2s-protocol/)
  Workload Identity Token is issued for the service, and the service binds it to
  the connection via proof-of-possession.
- An mTLS certificate is issued and bound to the client to communicate with the
  backing service.

##### Guidance

- Ensure the credentials used for each connection are as narrow in scope as
  possible for the use case.
- Use short-lived, automatically-rotated credentials to minimize exposure.
- Provide credentials via a secure, well-known mechanism (file path, metadata
  endpoint, or socket) rather than embedding them in [config](./config.md).

#### 2. The platform provides the identity and validation information for backing services.

The execution platform delivers both the workload identity credentials and the
information needed for the backing service to validate them. This ensures the
app can authenticate without manual configuration of static secrets.

##### Examples

- A platform injects an OIDC token along with a JWKS URL for signature
  validation.
- A SPIFFE implementation delivers both an SVID and its trust bundle.
- A WIMSE implementation provides both a WIT and the public key metadata
  required for validation.

##### Guidance

- Use the platform’s built-in mechanisms to inject credentials and trust
  material.
- Keep trust anchors and validation configuration out of the app’s source and
  config files.
- Ensure the injection approach is consistent across local, CI, and production
  environments.

#### 3. Backing services validate the workload identity credentials upon connection.

When an app connects, the backing service verifies that the supplied credentials
are authentic, unexpired, and correctly scoped for the request.

##### Examples

- A service validates an OIDC JWT by checking issuer, subject, and audience
  claims against expected values.
- A SPIFFE-enabled service validates a JWT-SVID against its trust bundle.
- A WIMSE-enabled service verifies a WIT and its proof-of-possession signature.
- An mTLS-secured service authenticates the client certificate’s SubjectAltName
  and trust domain.

##### Guidance

- Configure the backing service with the validation parameters supplied by the
  platform (issuer patterns, audience values, trust domains, or public key
  sources).
- For bearer-token schemes, validate on every request using current key
  material.
- For proof-of-possession or mTLS, enforce binding between the key material and
  the session.
- Where possible, delegate validation to platform-provided proxies or libraries
  to reduce application-layer complexity.
