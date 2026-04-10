# Test Case: Tags_TC01_Create_Tag_Happy_Path

> **Status:** READY
> **ID:** `Tags_TC01_Create_Tag_Happy_Path`
> **Priority:** Medium
> **Type:** Happy Path
> **Linked BRD:** None — baseline PD
> **FR/AC:** Tags module — create
> **Date:** 2026-04-10

---

## Preconditions

- Authenticated as a `member` user with a valid JWT token
- No tag named `"Work"` exists for this user

---

## Test Steps

| Step | Action | Input Data | Expected Result |
|------|--------|------------|-----------------|
| 1 | POST `/api/tags` with `Authorization: Bearer <token>` | `{ "name": "Work", "colour": "#ef4444" }` | HTTP 201 |
| 2 | Inspect response body | — | Body contains `_id`, `name: "Work"`, `colour: "#ef4444"`, `owner` matching authenticated user ID |
| 3 | GET `/api/tags` | — | The new tag appears in the list |

---

## Postconditions

- Tag document exists in MongoDB with `owner` set to the authenticated user's `_id`

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
