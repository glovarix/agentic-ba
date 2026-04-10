# Test Case: Todos_TC03_Filter_By_Status

> **Status:** READY
> **ID:** `Todos_TC03_Filter_By_Status`
> **Priority:** High
> **Type:** Happy Path
> **Linked BRD:** None — baseline PD
> **FR/AC:** Todos module — list with status filter
> **Date:** 2026-04-10

---

## Preconditions

- Authenticated as a `member` user with a valid JWT token
- User has at least 2 todos with `status: "pending"` and 1 with `status: "completed"`

---

## Test Steps

| Step | Action | Input Data | Expected Result |
|------|--------|------------|-----------------|
| 1 | GET `/api/todos?status=pending` with `Authorization: Bearer <token>` | Query param: `status=pending` | HTTP 200 |
| 2 | Inspect `todos` array | — | All items in `todos` have `status: "pending"` |
| 3 | Confirm no completed todos returned | — | No item has `status: "completed"` or any other status |
| 4 | Confirm `total` count | — | `total` reflects the number of pending todos only |
| 5 | GET `/api/todos?status=completed` | Query param: `status=completed` | HTTP 200 — returns only completed todos |

---

## Postconditions

- No data modified; read-only operation

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
