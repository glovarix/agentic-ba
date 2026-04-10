# Test Case: Todos_TC05_Admin_Can_View_All_Todos

> **Status:** READY
> **ID:** `Todos_TC05_Admin_Can_View_All_Todos`
> **Priority:** High
> **Type:** Role-Based
> **Linked BRD:** None — baseline PD
> **FR/AC:** Todos module — admin/all route
> **Date:** 2026-04-10

---

## Preconditions

- Two user accounts exist: **User A** (`member`) and **Admin User** (`admin`)
- User A owns at least one todo
- Authenticated as **Admin User** with a valid JWT token

---

## Test Steps

| Step | Action | Input Data | Expected Result |
|------|--------|------------|-----------------|
| 1 | GET `/api/todos/admin/all` with Admin token | — | HTTP 200 |
| 2 | Inspect `todos` array | — | Array includes User A's todos with `owner` populated (name, email) |
| 3 | Confirm `owner` field is present | — | Each todo has `owner.name` and `owner.email` |
| 4 | Attempt same request as `member` user | — | HTTP 403 — `{ "error": "Insufficient permissions" }` |

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
