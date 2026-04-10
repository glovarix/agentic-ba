# Technical Implementation Plan (TIP)

> **Status:** DRAFT
> **Artefact ID:** `2026-04-10-due-date-reminders-TIP`
> **Feature:** Due Date Reminders
> **Linked BRD:** [2026-04-10-due-date-reminders-BRD](../requirements/2026-04-10-due-date-reminders-BRD.md)
> **Author:** Claude (AI) — **Verified by:** (placeholder — Dev Lead to confirm)
> **Date:** 2026-04-10

---

## 1. Summary

This TIP covers the backend implementation of automated 24-hour due date reminder emails for the Todo App. It adds a scheduled job, an email service integration, and a user-level opt-out preference. No frontend changes are required beyond the opt-out toggle in profile settings.

**Effort:** M (1–3 days)
**Dependencies:** Transactional email provider credentials (SendGrid or Resend) — must be confirmed before BE-01 begins.

---

## 2. Implementation Tasks

### Backend

| #     | Task                                                                                       | FR(s)       | Effort |
|-------|--------------------------------------------------------------------------------------------|-------------|--------|
| BE-01 | Add `reminders_enabled` field (Boolean, default `true`) to `User` schema in `User.js`     | FR-02       | S      |
| BE-02 | Create `services/emailService.js` — wraps transactional provider SDK, exposes `sendReminderEmail(user, todo)` | FR-01 | S |
| BE-03 | Create `jobs/dueDateReminder.js` — queries todos where `due_date` is between `now` and `now + 24h`, `status` is `pending` or `in_progress`, and `owner.reminders_enabled` is `true`. Calls `sendReminderEmail` for each. | FR-01 | M |
| BE-04 | Add deduplication guard — store `last_reminder_sent_at` on `Todo` or use a separate `reminders` collection to prevent duplicate sends within the same 24h window | FR-01 AC-01-03 | S |
| BE-05 | Register the job in `server.js` using `node-cron` or equivalent — run every hour | FR-01       | S      |

### API

| #      | Task                                                                              | FR(s) | Effort |
|--------|-----------------------------------------------------------------------------------|-------|--------|
| API-01 | `PATCH /api/auth/me` — already exists in `auth.js`. Extend `allowed` array to include `reminders_enabled` | FR-02 | S |

### Frontend

| #     | Task                                                                                       | FR(s) | Effort |
|-------|--------------------------------------------------------------------------------------------|-------|--------|
| FE-01 | Add "Email reminders" toggle to profile settings page — calls `PATCH /api/auth/me` with `{ reminders_enabled: true/false }` | FR-02 | S |

---

## 3. API Contracts

### `PATCH /api/auth/me`

**Purpose:** Update user profile — extended to include `reminders_enabled` | **Auth:** JWT — min role: member

**Request:**

```json
{
  "reminders_enabled": false
}
```

**Success — `200`:**

```json
{
  "id": "64f1a2b3c4d5e6f7a8b9c0d1",
  "name": "Jane Smith",
  "email": "jane@example.com",
  "role": "member",
  "reminders_enabled": false
}
```

**Errors:**

| Code | Condition         |
|------|-------------------|
| 401  | Unauthenticated   |
| 400  | Invalid field value |

---

## 4. Data Model Changes

### `User` — add field

| Field               | Type    | Nullable | Default |
|---------------------|---------|----------|---------|
| `reminders_enabled` | Boolean | No       | `true`  |

### `Todo` — add field (for deduplication)

| Field                   | Type | Nullable | Default |
|-------------------------|------|----------|---------|
| `last_reminder_sent_at` | Date | Yes      | `null`  |

No SQL migration required — MongoDB/Mongoose adds new fields on next write. Existing documents without `reminders_enabled` treat the field as `undefined`; job query must treat `undefined` as `true` (opt-in by default).

> ⚠️ The job query must explicitly handle `{ reminders_enabled: { $ne: false } }` to include existing users who have no value set for this field.

---

## 5. Risks & Open Questions

**Risks:**

| #    | Risk                                                                 | Likelihood | Mitigation                                                        |
|------|----------------------------------------------------------------------|------------|-------------------------------------------------------------------|
| R-01 | Email provider credentials not available at dev time                 | Med        | Use a test/sandbox account during development                     |
| R-02 | Job sends duplicate emails if server restarts mid-run               | Low        | `last_reminder_sent_at` guard on `Todo` prevents re-send within 24h window |
| R-03 | Large number of todos due simultaneously causes slow job execution  | Low        | Process in batches of 100; add index on `due_date` + `status`    |

**Open questions:**

| #     | Question                                                                 | Owner          | Due                  |
|-------|--------------------------------------------------------------------------|----------------|----------------------|
| OQ-01 | Confirm email provider — SendGrid or Resend?                            | Engineering Lead | Before BE-02 begins |
| OQ-02 | Should `last_reminder_sent_at` live on `Todo` or a separate collection? | Dev Lead       | Before BE-04 begins  |

---

## 6. Testing Notes

- Test that todos with `status: completed` or `archived` do not trigger a reminder even if `due_date` is within 24h.
- Test that a user with `reminders_enabled: false` receives no email.
- Test deduplication: run the job twice in quick succession — confirm only one email is sent.
- Test that existing users with no `reminders_enabled` field are treated as opted in.

**Linked test suite:** [Todos Test Suite](../test-suites/Todos/)
