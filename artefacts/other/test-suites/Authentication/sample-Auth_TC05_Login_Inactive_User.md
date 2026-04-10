# Test Case: Auth_TC05_Login_Inactive_User

> **Status:** READY
> **ID:** `Auth_TC05_Login_Inactive_User`
> **Priority:** High
> **Type:** Negative / Role-Based
> **Linked BRD:** None — baseline PD
> **FR/AC:** Authentication module — inactive user guard
> **Date:** 2026-04-10

---

## Preconditions

- A user account exists with `email: "inactive@example.com"`, correct password, and `is_active: false`

---

## Test Steps

| Step | Action | Input Data | Expected Result |
|------|--------|------------|-----------------|
| 1 | POST `/api/auth/login` | `{ "email": "inactive@example.com", "password": "SecurePass1!" }` | HTTP 401 |
| 2 | Inspect response body | — | Body contains `{ "error": "Invalid credentials" }` |

---

## Postconditions

- No token issued
- Inactive account remains inaccessible

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
