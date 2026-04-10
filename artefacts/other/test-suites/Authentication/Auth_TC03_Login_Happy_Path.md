# Test Case: Auth_TC03_Login_Happy_Path

> **Status:** READY
> **ID:** `Auth_TC03_Login_Happy_Path`
> **Priority:** High
> **Type:** Happy Path
> **Linked BRD:** None — baseline PD
> **FR/AC:** Authentication module — login
> **Date:** 2026-04-10

---

## Preconditions

- A user account exists with `email: "jane@example.com"`, `password: "SecurePass1!"`, and `is_active: true`

---

## Test Steps

| Step | Action | Input Data | Expected Result |
|------|--------|------------|-----------------|
| 1 | POST `/api/auth/login` | `{ "email": "jane@example.com", "password": "SecurePass1!" }` | HTTP 200 |
| 2 | Inspect response body | — | Body contains `token` (JWT string) and `user` object |
| 3 | Decode JWT token | — | Payload contains `id` matching the user's `_id` in MongoDB |
| 4 | Confirm `last_login_at` updated | Query MongoDB for user | `last_login_at` is set to a timestamp within the last 5 seconds |

---

## Postconditions

- Client holds a valid JWT token to use in subsequent requests
- `last_login_at` field updated on the User document

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
