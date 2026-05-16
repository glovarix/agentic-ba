# Test Case: Todos_TC01_Create_Todo_Happy_Path

> **Status:** READY
> **ID:** `Todos_TC01_Create_Todo_Happy_Path`
> **Priority:** High
> **Type:** Happy Path
> **Linked BRD:** None — baseline PD
> **FR/AC:** Todos module — create
> **Date:** 2026-04-10

---

## Preconditions

- Authenticated as a `member` user with a valid JWT token
- At least one Tag exists for the user (to test tag assignment)

---

## Test Steps

| Step | Action | Input Data | Expected Result |
|------|--------|------------|-----------------|
| 1 | POST `/api/todos` with `Authorization: Bearer <token>` | `{ "title": "Buy milk", "description": "Full fat", "priority": "high", "due_date": "2026-04-20", "tags": ["<tag_id>"] }` | HTTP 201 |
| 2 | Inspect response body | — | Body contains `_id`, `title: "Buy milk"`, `status: "pending"`, `priority: "high"`, `owner` matching authenticated user ID |
| 3 | Confirm `status` default | — | `status` equals `"pending"` |
| 4 | Confirm `completed_at` is null | — | `completed_at` field is absent or null |

---

## Postconditions

- Todo document exists in MongoDB with `owner` set to the authenticated user's `_id`

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
