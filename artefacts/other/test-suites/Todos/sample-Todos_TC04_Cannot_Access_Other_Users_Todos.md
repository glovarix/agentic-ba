# Test Case: Todos_TC04_Cannot_Access_Other_Users_Todos

> **Status:** READY
> **ID:** `Todos_TC04_Cannot_Access_Other_Users_Todos`
> **Priority:** High
> **Type:** Role-Based / Negative
> **Linked BRD:** None — baseline PD
> **FR/AC:** Todos module — ownership scoping
> **Date:** 2026-04-10

---

## Preconditions

- Two user accounts exist: **User A** (`member`) and **User B** (`member`)
- User B owns a todo — note its `_id`
- Authenticated as **User A** with a valid JWT token

---

## Test Steps

| Step | Action | Input Data | Expected Result |
|------|--------|------------|-----------------|
| 1 | GET `/api/todos/<user_b_todo_id>` with User A's token | — | HTTP 404 |
| 2 | Inspect response body | — | `{ "error": "Todo not found" }` |
| 3 | PATCH `/api/todos/<user_b_todo_id>` with User A's token | `{ "title": "Hijacked" }` | HTTP 404 |
| 4 | DELETE `/api/todos/<user_b_todo_id>` with User A's token | — | HTTP 404 |
| 5 | GET `/api/todos` with User A's token | — | Response only contains User A's own todos |

---

## Postconditions

- User B's todo is unchanged
- No data leakage between users

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
