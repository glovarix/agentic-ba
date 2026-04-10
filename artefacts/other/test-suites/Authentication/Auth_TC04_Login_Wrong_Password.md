# Test Case: Auth_TC04_Login_Wrong_Password

> **Status:** READY
> **ID:** `Auth_TC04_Login_Wrong_Password`
> **Priority:** High
> **Type:** Negative
> **Linked BRD:** None — baseline PD
> **FR/AC:** Authentication module — login credential validation
> **Date:** 2026-04-10

---

## Preconditions

- A user account exists with `email: "jane@example.com"` and `is_active: true`

---

## Test Steps

| Step | Action | Input Data | Expected Result |
|------|--------|------------|-----------------|
| 1 | POST `/api/auth/login` | `{ "email": "jane@example.com", "password": "WrongPassword!" }` | HTTP 401 |
| 2 | Inspect response body | — | Body contains `{ "error": "Invalid credentials" }` |
| 3 | Confirm no token returned | — | Response body does not contain a `token` field |

---

## Postconditions

- No session or token issued
- `last_login_at` is not updated

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
