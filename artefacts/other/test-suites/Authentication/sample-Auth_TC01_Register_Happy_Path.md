# Test Case: Auth_TC01_Register_Happy_Path

> **Status:** READY
> **ID:** `Auth_TC01_Register_Happy_Path`
> **Priority:** High
> **Type:** Happy Path
> **Linked BRD:** None — baseline PD
> **FR/AC:** Authentication module — registration
> **Date:** 2026-04-10

---

## Preconditions

- No account exists for the email address being used
- API server is running and connected to MongoDB

---

## Test Steps

| Step | Action | Input Data | Expected Result |
|------|--------|------------|-----------------|
| 1 | POST `/api/auth/register` | `{ "name": "Jane Smith", "email": "jane@example.com", "password": "SecurePass1!" }` | HTTP 201 |
| 2 | Inspect response body | — | Body contains `token` (JWT string) and `user` object with `id`, `name`, `email`, `role` |
| 3 | Confirm `role` value | — | `role` equals `"member"` (default) |
| 4 | Confirm `password_hash` is not returned | — | Response body does not contain `password_hash` |

---

## Postconditions

- A new User document exists in MongoDB with `is_active: true` and `role: "member"`
- `password_hash` in the database is a bcrypt hash — not the plaintext password

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
