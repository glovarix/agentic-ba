# Test Case: Tags_TC02_Duplicate_Tag_Name_Rejected

> **Status:** READY
> **ID:** `Tags_TC02_Duplicate_Tag_Name_Rejected`
> **Priority:** Medium
> **Type:** Negative / Edge Case
> **Linked BRD:** None — baseline PD
> **FR/AC:** Tags module — unique name per owner constraint
> **Date:** 2026-04-10

---

## Preconditions

- Authenticated as a `member` user with a valid JWT token
- A tag named `"Work"` already exists for this user

---

## Test Steps

| Step | Action | Input Data | Expected Result |
|------|--------|------------|-----------------|
| 1 | POST `/api/tags` | `{ "name": "Work", "colour": "#3b82f6" }` | HTTP 500 (MongoDB duplicate key error — no application-level 409 handler exists) |
| 2 | Inspect response body | — | Body contains `{ "error": "Internal server error" }` |
| 3 | Confirm no duplicate created | GET `/api/tags` | Only one tag named `"Work"` exists |

> ⚠️ **Note:** The unique constraint is enforced by a MongoDB compound index (`name + owner`) in `Tag.js`. The application does not currently return a user-friendly 409 response — a CR should be raised to handle this gracefully.

---

## Postconditions

- No duplicate tag created

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
