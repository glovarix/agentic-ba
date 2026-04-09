# Business Requirements Document (BRD)

> **Status:** DRAFT
> **Artefact ID:** `2026-04-10-due-date-reminders-BRD`
> **Feature:** Due Date Reminders
> **Author:** Claude (AI) — **Verified by:** (placeholder — Product Owner to confirm)
> **Date:** 2026-04-10

---

## 1. Summary

Users of the Todo App currently have no way of knowing when a todo is approaching its due date without manually checking the app. This feature introduces automated email reminders sent to the todo owner 24 hours before a todo's `due_date`, helping users stay on top of their commitments without relying on memory.

---

## 2. Problem & Objectives

**Problem:** Todos with due dates are frequently missed because the app provides no proactive notification. Users must check the app manually to discover overdue items.

| #      | Objective                                         | Success Indicator                                              |
|--------|---------------------------------------------------|----------------------------------------------------------------|
| OBJ-01 | Reduce overdue todos by prompting users in advance | 20% reduction in todos remaining in `pending` past their `due_date` after 30 days |
| OBJ-02 | Deliver reminders without requiring app login      | Email open rate ≥ 40% in first month                          |

---

## 3. User Stories

- **US-01:** As a member, I want to receive an email 24 hours before a todo is due so that I can act on it before it becomes overdue.
- **US-02:** As a member, I want to opt out of reminder emails so that I am not notified for todos I no longer intend to complete.
- **US-03:** As an admin, I want reminders to apply to all active users so that the entire team benefits without manual configuration.

---

## 4. Functional Requirements

### FR-01: 24-Hour Due Date Reminder Email

**Description:** The system sends an email to the `owner` of any todo whose `due_date` falls within the next 24 hours and whose `status` is `pending` or `in_progress`. Todos with `status` of `completed` or `archived` must not receive a reminder.

**Triggered by:** Scheduled job running once per hour.

**Acceptance Criteria:**

- AC-01-01: An email is sent to the todo owner's registered `email` address when `due_date` is between now and 24 hours from now and `status` is `pending` or `in_progress`.
- AC-01-02: No email is sent for todos with `status` of `completed` or `archived`.
- AC-01-03: No duplicate reminder is sent if the job runs again within the same window.
- AC-01-04: The email includes the todo `title` and `due_date` formatted as `DD MMM YYYY HH:mm`.

### FR-02: Reminder Opt-Out

**Description:** Users can disable reminder emails from their profile settings. When opted out, no reminder emails are sent regardless of due dates.

**Triggered by:** User toggling the preference in profile settings.

**Acceptance Criteria:**

- AC-02-01: A boolean preference `reminders_enabled` is available in user profile settings, defaulting to `true`.
- AC-02-02: When `reminders_enabled` is `false`, no reminder emails are sent to that user.
- AC-02-03: Changing the preference takes effect for the next scheduled job run.

---

## 5. Non-Functional Requirements

| #      | Category    | Requirement                                                                 |
|--------|-------------|-----------------------------------------------------------------------------|
| NFR-01 | Reliability | Reminder job must process all eligible todos within 5 minutes of scheduled start |
| NFR-02 | Security    | Email must not expose other users' data — one email per owner per due todo  |
| NFR-03 | Deliverability | Emails must be sent via a transactional email provider (e.g. SendGrid, Resend) with SPF/DKIM configured |

---

## 6. Scope

**In scope:**

- 24-hour email reminder for todos owned by any active user
- Opt-out preference on user profile
- Scheduled background job to identify eligible todos

**Out of scope:**

- Push notifications (mobile or browser)
- Reminders for todos assigned via `assigned_to` (owner only)
- Custom reminder intervals (only 24-hour supported in v1)
- In-app notification inbox

---

## 7. Assumptions & Open Items

**Assumptions:**

- A transactional email provider account is available and configured before development begins.
- Server infrastructure supports scheduled jobs (cron or equivalent).
- `due_date` is stored in UTC in MongoDB — reminder logic operates in UTC.

**Open items:**

| #     | Question                                                        | Owner          | Due        |
|-------|-----------------------------------------------------------------|----------------|------------|
| OI-01 | Which email provider will be used — SendGrid, Resend, or other? | Engineering Lead | To be confirmed before TIP |
| OI-02 | Should the reminder email include a direct link to the todo?   | Product Owner  | Before design sign-off |
| OI-03 | What happens if a todo has no `due_date` set — confirm no email | Engineering Lead | Before dev begins |
