# Missed Medication Incident Notification — Clarification Required Before We Proceed

Subject: Missed Medication Incident Notification — Clarification Required Before We Proceed

Thank you for this request. Our codebase review has confirmed the problem and surfaced some additional detail that will shape the scope before we write a Change Request.

---

## What we found

The overnight job runs at midnight each day. It looks at the previous day's MAR records, identifies any medications marked as Not Administered, creates a general note, and generates a draft incident report in the Incidents module. This confirms the current behaviour you described.

There is code in that job that attempts to send an in-app notification to managers when the draft is created, but it is gated behind an organisation-level notification setting that is not reliably configured. In practice this means the notification does not fire, which is consistent with your experience of having to manually check each service user's draft section.

There is no dashboard widget or panel that surfaces pending draft incident reports to managers.

---

## Questions for the client

Before we scope this as a Change Request, please confirm the following:

1. When you say "timely", do you mean you want the notification at the point the medication is marked Not Administered in the MAR — in other words, in real time rather than the following day when the overnight job runs? Or is next-day notification acceptable provided it is visible and actionable?

2. Should the notification go to the manager of the facility the service user is admitted to, or to a specific role or individual? For example, does the ward manager or a named medication lead need to receive it rather than all managers?

3. Is the ask limited to a notification (bell/alert), or do you also want a dedicated section on the manager's dashboard that lists all outstanding draft missed medication incident reports across their service users — so they can see the full picture without relying on a notification they may have missed?

4. Should the manager be able to assign the draft to a specific care team member for completion from the notification or dashboard, or is the current workflow (manager reviews the draft and prompts the team member manually) sufficient?

The answers will determine whether this is a targeted notification fix, a dashboard feature, or both.
