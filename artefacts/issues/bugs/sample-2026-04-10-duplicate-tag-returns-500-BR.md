# Duplicate Tag Name Returns HTTP 500 Instead of 409

## Problem and Context

When a user attempts to create a tag with a name that already exists for their account, the API returns an unhandled HTTP 500 Internal Server Error rather than a descriptive 409 Conflict response. This exposes a raw MongoDB duplicate key error to the client and provides no actionable feedback to the user or frontend. The unique constraint is enforced correctly at the database level via a compound index on `name + owner` in `Tag.js`, but there is no application-level handler to intercept the error and return a user-friendly response.

## How to Reproduce

- **Instance:** Staging / Local
- **Role tested:** member
- **Endpoint:** `POST /api/tags`
- **Auth:** Valid JWT Bearer token required

**Steps:**

1. Authenticate as a `member` user and obtain a JWT token.
2. POST `/api/tags` with `{ "name": "Work", "colour": "#3b82f6" }` — this creates the first tag successfully (HTTP 201).
3. POST `/api/tags` again with `{ "name": "Work", "colour": "#ef4444" }` — same name, same authenticated user.
4. Observe HTTP 500 response with body `{ "error": "Internal server error" }`.

**Expected:** HTTP 409 with body `{ "error": "A tag with this name already exists" }`.
**Actual:** HTTP 500 with a raw server error body.

## Checklist

- [ ] Add a try/catch block in `POST /api/tags` route handler in `backend/routes/tags.js`
- [ ] Detect MongoDB duplicate key error code `11000` and return HTTP 409 with a clear message
- [ ] Confirm no other write routes on tags are missing equivalent error handling

## Instances Tested

- [ ] Development
- [ ] Staging
- [ ] Demo
- [ ] Production

## Media

(placeholder — attach reproduction video or JAM.dev link if available)
