# ADR-009 — Authentication and Identity Strategy: OIDC Provider-Agnostic

| Field | Detail |
|---|---|
| **Document Type** | Architecture Decision Record |
| **Version** | v0.1 |
| **Status** | Accepted |
| **Owner** | Core Platform |
| **Location** | `docs/ADR/ADR-009_Authentication_Identity_Strategy.md` |
| **Date** | April 2026 |
| **Related Documents** | ADR-003_UI_Technology_Stack, ADR-007_Module_Composition_DI_Lifetime, ADR-008_API_Surface_Architecture, ADR-010_Tenant_Isolation_Strategy, SPEC/Host_Application_Shell, docs/architecture/governance/Security_and_Access_Control_Model.md |

---

## Context

The platform handles among the most sensitive data categories that exist — national identifiers (SSNs), compensation rates, bank account details, medical leave information, and tax withholding elections. Authentication is not a feature to be added later; it shapes the data access layer, the Blazor component model, the API surface, and the audit trail from day one.

Several constraints shaped the authentication decision:

**DBMS and deployment portability.** The platform supports on-premises deployment against the client's DBMS of choice (ADR-004). The authentication mechanism must be equally portable — it cannot depend on a specific cloud identity service being available.

**Multi-provider client environment.** Prospective clients will have their own identity providers. A PEO serving multiple client companies may need to federate across several providers. The platform must not prescribe a specific identity vendor.

**SSO is the enterprise expectation.** HR and payroll platforms are operated by corporate employees using corporate devices, already authenticated to a corporate identity provider. Maintaining a separate platform credential is friction that enterprise clients do not accept. SSO through the corporate identity provider is the baseline expectation, not a premium feature.

**MFA coverage.** Multi-factor authentication for access to sensitive HR and payroll data is a compliance expectation. If authentication is delegated to the client's identity provider, MFA is enforced at that layer and the platform inherits it automatically without implementing it independently.

**Role and claims portability.** The platform defines its own role model (`HrisAdmin`, `PayrollOperator`, etc.). These roles must be mappable from whatever claims the identity provider issues — not hardcoded to a specific provider's claim format.

---

## Decision

**The platform shall use OpenID Connect (OIDC) as the authentication protocol. The identity provider is a deployment-time configuration choice. No proprietary authentication mechanism and no platform-managed username/password login shall be implemented.**

### Protocol

OpenID Connect (OIDC) over OAuth 2.0 Authorization Code Flow with PKCE. This is the current industry standard for web application authentication and is supported by every major identity provider.

The ASP.NET Core OIDC middleware handles token acquisition, validation, and cookie session management. The platform application code has no knowledge of the specific identity provider.

### Provider Configuration

The identity provider is configured entirely through environment variables established in `SPEC/Host_Application_Shell`:

| Variable | Purpose |
|---|---|
| `AUTH_AUTHORITY` | The OIDC authority URL (e.g. `https://login.example.com/realm/blazorhr`) |
| `AUTH_CLIENT_ID` | The client ID registered with the identity provider |
| `AUTH_CLIENT_SECRET` | The client secret for confidential client authentication |

Changing the identity provider requires only environment variable changes — no application code changes.

### Recommended Default — Keycloak

For on-premises deployments and development environments, **Keycloak** is the recommended identity provider. Keycloak is open source, self-hosted, supports OIDC and SAML, can federate with on-premises Active Directory via LDAP, and requires no cloud dependency. It runs in Docker and can be deployed alongside the platform application on a single server for small client deployments.

For clients with existing cloud identity providers (Microsoft Entra ID, Google Workspace, Auth0, Okta, Ping Identity), the platform connects to their existing authority without modification. The same application code runs in all cases.

### Role Mapping

The platform defines its own role vocabulary:

| Platform Role | Description |
|---|---|
| `HrisViewer` | Read-only HRIS access |
| `HrisAdmin` | Full HRIS read/write including lifecycle events |
| `PayrollViewer` | Read-only payroll access |
| `PayrollOperator` | Initiate runs, view register, manage exceptions |
| `PayrollAdmin` | Approve and release runs |
| `PayrollSupervisor` | Cancel running jobs; initiate corrections |
| `TimeViewer` | Read-only T&A access |
| `TimeAdmin` | Full T&A access including handoff |
| `Manager` | Scoped access to direct reports |
| `Employee` | Self-service access to own record |
| `ReportViewer` | Base reporting access |
| `ReportAdmin` | Scheduled report configuration |
| `Auditor` | Read-only access to all in-scope data |

Roles are issued as JWT claims by the identity provider. The claim name is configurable (default: `roles`). The identity provider administrator maps their user groups or attributes to the platform's role values. The application maps the JWT `roles` claim to `ClaimsPrincipal` roles that ASP.NET Core's `[Authorize(Roles = "...")]` and `User.IsInRole(...)` evaluate natively.

```csharp
// Program.cs — role claim mapping
.AddOpenIdConnect(options =>
{
    options.Authority    = Environment.GetEnvironmentVariable("AUTH_AUTHORITY");
    options.ClientId     = Environment.GetEnvironmentVariable("AUTH_CLIENT_ID");
    options.ClientSecret = Environment.GetEnvironmentVariable("AUTH_CLIENT_SECRET");
    options.ResponseType = "code";
    options.SaveTokens   = true;

    options.Scope.Add("openid");
    options.Scope.Add("profile");
    options.Scope.Add("roles");

    // Map the identity provider's role claim to ASP.NET Core roles
    options.TokenValidationParameters = new TokenValidationParameters
    {
        RoleClaimType = "roles"
    };

    // Map tenant_id claim — consumed by ADR-010
    options.ClaimActions.MapJsonKey("tenant_id", "tenant_id");
});
```

### Tenant Context

The `tenant_id` claim carries the tenant identifier for multi-tenant deployments. This claim is set by the identity provider at login time — the user's account is associated with their tenant. The application uses this claim to resolve the correct database connection per ADR-010. No tenant identifier is passed as a query parameter or URL segment.

### Security Considerations

**All Blazor pages require authentication by default.** `<AuthorizeRouteView>` in `App.razor` redirects unauthenticated users to the OIDC login page. There are no anonymous pages in the application except a minimal error page.

**All Minimal API endpoints require authentication.** Every endpoint uses `.RequireAuthorization()` with the appropriate role scope. HTTP 401 is returned for missing or invalid tokens.

**Tokens are stored in encrypted HTTP-only cookies.** The ASP.NET Core OIDC middleware handles this. Tokens are never exposed to JavaScript.

**Sensitive data access is role-gated at the service layer, not only at the UI layer.** Role checks in Blazor components control visibility. Role checks in service methods enforce access regardless of how the service is called. Both layers are required.

**Download audit logging is mandatory for sensitive documents.** Every document download creates an audit record regardless of how access was obtained. This is enforced at the service layer, not the UI layer.

---

## Consequences

**Positive:**
- Provider-agnostic — same application code works with any OIDC-compliant identity provider
- MFA inherited from the identity provider at no implementation cost
- SSO aligns with enterprise client expectations
- No platform-managed passwords — no password reset workflows, no credential storage, no password policy enforcement
- Role mapping is flexible — identity provider administrators configure role assignments without code changes
- Keycloak default covers on-premises deployments with no cloud dependency

**Constraints to manage:**
- Each deployment requires a configured OIDC provider — there is no fallback login if the provider is unavailable
- Development requires a local OIDC provider — Keycloak in Docker is the standard development setup
- Role claim name may differ between providers — the `RoleClaimType` configuration must be verified per provider
- Token expiry and refresh handling must be tested per provider — some providers issue short-lived tokens that require refresh token handling

**Future consideration:**
- For PEO deployments serving multiple client companies, each with their own identity provider, OIDC federation or a broker identity provider (Keycloak can act as an identity broker) can aggregate multiple upstream providers into a single OIDC authority for the platform

---

## Alternatives Considered

**ASP.NET Core Identity with local username/password**
Platform manages its own user store, passwords, and MFA. Rejected — does not meet SSO expectations for enterprise clients; adds credential management complexity; MFA must be implemented independently; no integration with corporate directory services.

**Microsoft Entra ID (Azure AD) specifically**
Simple to implement for Microsoft 365 clients. Rejected — creates a cloud provider dependency that conflicts with on-premises portability requirement; excludes clients on other identity providers; couples the platform to a specific vendor.

**SAML 2.0**
Older but widely supported federation protocol. Rejected — OIDC is the current standard and is supported by all providers that support SAML; OIDC is simpler to implement in .NET Core; the ASP.NET Core OIDC middleware is mature and well-supported.

**API key authentication for Minimal API endpoints**
Simple token-based authentication for integration endpoints. Rejected as primary mechanism — OIDC covers both UI and API; consistent authentication model reduces attack surface; API keys can be layered on top for specific machine-to-machine integrations if needed in future.
