# Test Case: Todos_TC06_Unauthenticated_Request_Rejected

> **Status:** READY
> **ID:** `Todos_TC06_Unauthenticated_Request_Rejected`
> **Priority:** High
> **Type:** Negative
> **Linked BRD:** None — baseline PD
> **FR/AC:** Todos module — authentication guard
> **Date:** 2026-04-10

---

## Preconditions

- No `Authorization` header is sent with the request

---

## Test Steps

| Step | Action | Input Data | Expected Result |
|------|--------|------------|-----------------|
| 1 | GET `/api/todos` with no Authorization header | — | HTTP 401 |
| 2 | Inspect response body | — | `{ "error": "Authentication required" }` |
| 3 | POST `/api/todos` with no Authorization header | `{ "title": "Test" }` | HTTP 401 |
| 4 | GET `/api/tags` with no Authorization header | — | HTTP 401 |

---

## Postconditions

- No data returned or modified

---

## Execution

| Field | Value |
|-------|-------|
| Executed by | |
| Date | |
| Environment | Staging / Demo / Production |
| Result | PASS / FAIL / BLOCKED |
| Actual result | |
| Defect link | |
