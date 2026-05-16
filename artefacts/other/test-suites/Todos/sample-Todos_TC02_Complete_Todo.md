# Test Case: Todos_TC02_Complete_Todo

> **Status:** READY
> **ID:** `Todos_TC02_Complete_Todo`
> **Priority:** High
> **Type:** Happy Path
> **Linked BRD:** None — baseline PD
> **FR/AC:** Todos module — complete action
> **Date:** 2026-04-10

---

## Preconditions

- Authenticated as a `member` user with a valid JWT token
- A todo exists with `status: "pending"` owned by the authenticated user — note its `_id`

---

## Test Steps

| Step | Action | Input Data | Expected Result |
|------|--------|------------|-----------------|
| 1 | POST `/api/todos/<id>/complete` with `Authorization: Bearer <token>` | No body required | HTTP 200 |
| 2 | Inspect response body | — | `status` equals `"completed"` |
| 3 | Confirm `completed_at` is set | — | `completed_at` is a timestamp within the last 5 seconds |
| 4 | GET `/api/todos/<id>` | — | Returned todo has `status: "completed"` and `completed_at` set |

---

## Postconditions

- Todo `status` is `"completed"` and `completed_at` is recorded in MongoDB

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
