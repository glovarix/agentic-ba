# Test Case: {MODULE_SLUG}_TC{NN}_{Short_Name}

> **Status:** DRAFT | READY | PASS | FAIL | BLOCKED
> **Test Case ID:** `{MODULE_SLUG}_TC{NN}_{Short_Name}`
> **Module:** {Module Name}
> **Feature:** {Feature Title}
> **Linked BRD:** [{BRD filename}](../../requirements/{BRD-filename}.md)
> **FR Coverage:** FR-{xx}, FR-{xx}
> **AC Coverage:** AC-{xx}-{xx}, AC-{xx}-{xx}
> **Priority:** High / Medium / Low
> **Test Type:** Happy Path / Negative / Role-Based / Edge Case
> **Author:** Claude (AI)
> **Date:** {YYYY-MM-DD}

---

## Preconditions

{List everything that must be true BEFORE the first test step. Be explicit about role, data state, and environment.}

- Tester is logged in as a **{Role}** on the **{environment}** environment (e.g. `https://demo.staging.app/login`)
- The {Module} module is **enabled** for the test organisation
- A Service User record **"{Name}"** exists in the system
- {Any other prerequisite — be specific}

---

## Test Steps

| Step | Action | Input Data | Expected Result |
|---|---|---|---|
| 1 | {Imperative action — "Click", "Navigate to", "Enter", "Select"} | {Exact value or URL} | {Observable, exact outcome} |
| 2 | | | |
| 3 | | | |
| 4 | | | |
| 5 | | | |

---

## Postconditions

{What should be true in the system AFTER the test completes successfully.}

- {e.g. "A new care plan record exists in the database with status = 'draft'"}
- {e.g. "An audit log entry is created with the tester's user ID and a timestamp"}

---

## Test Execution

| Field | Value |
|---|---|
| Executed by | |
| Execution date | |
| Environment | Development / Staging / Demo / Production |
| Test result | PASS / FAIL / BLOCKED |
| Actual result | {Leave blank — QA completes during execution} |
| Defect link | {Link to bug report if FAIL} |
| Loom / screenshot | {Link if applicable} |

---

## Notes

{Any clarifications, known edge cases, or dependency flags the tester should be aware of.}

- {Note}
- {Note}
