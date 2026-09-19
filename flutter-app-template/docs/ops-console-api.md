# Ops console API contract (client)

Server is **out of scope** for this App template repo. Clients POST heartbeats here when `OPS_CONSOLE_BASE_URL` is set.

## Endpoint

`POST {OPS_CONSOLE_BASE_URL}/v1/heartbeat`

### JSON body

| Field | Type | Description |
|-------|------|-------------|
| `appId` | string | **应用实例身份** id |
| `displayName` | string | Display name |
| `type` | string | Always `heartbeat` for this call |

### Headers

- `Content-Type: application/json`

### Errors

- Network / non-2xx: surfaced as `HttpException` from the HTTP port.
- Empty `OPS_CONSOLE_BASE_URL`: client no-ops (no request).
