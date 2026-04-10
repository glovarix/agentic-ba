# Test Case: Auth_TC02_Register_Duplicate_Email

> **Status:** READY
> **ID:** `Auth_TC02_Register_Duplicate_Email`
> **Priority:** High
> **Type:** Negative
> **Linked BRD:** None — baseline PD
> **FR/AC:** Authentication module — registration duplicate guard
> **Date:** 2026-04-10

---

## Preconditions

- An account with `email: "jane@example.com"` already exists in the database

---

## Test Steps

| Step | Action | Input Data | Expected Result |
|------|--------|------------|-----------------|
| 1 | POST `/api/auth/register` | `{ "name": "Jane Again", "email": "jane@example.com", "password": "AnotherPass1!" }` | HTTP 409 |
| 2 | Inspect response body | — | Body contains `{ "error": "Email already registered" }` |
| 3 | Confirm no new user created | Query MongoDB for `email: "jane@example.com"` | Exactly one User document exists |

---

## Postconditions

- No new User document created in MongoDB

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
