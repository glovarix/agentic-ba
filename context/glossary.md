# Domain Glossary

> This glossary is the authoritative source for terminology used across all artefacts in this repository.
> Replace the example entries below with your project's actual domain terms.
> All artefacts (BRDs, TIPs, PRDs, test cases, issues) must use these terms exactly as defined.
> Never invent abbreviations without adding them here first.

---

| Term | Definition | Aliases | Module(s) |
| --- | --- | --- | --- |
| Admin | A user who manages system configuration, user accounts, and organisational settings | System Admin, Super Admin | All |
| Manager | A user who oversees operations, approves work items, and views reports | Team Lead, Department Manager | All |
| User | A standard user performing day-to-day tasks within the product | Staff, Operator, End User | All |
| QA Engineer | A team member who writes and executes test cases and validates acceptance criteria | Tester, QA | All |
| Draft | An unsaved or partially completed record not yet formally submitted | — | Any module with save states |
| Submission | The act of formally completing and locking a record for review or processing | — | Any module with workflows |
| Audit Log | A system-generated, immutable record of all user actions on data | Activity Log | All |
| Acceptance Criteria | Observable, testable conditions that must be true for a requirement to be met | AC | BRDs, Test Cases |
| Functional Requirement | A specific behaviour the system must exhibit | FR | BRDs |
| Non-Functional Requirement | A quality attribute the system must have (performance, security, accessibility) | NFR | BRDs, PRDs |
| BRD | Business Requirements Document — specifies what the system must do | — | SDLC artefacts |
| TIP | Technical Implementation Plan — specifies how the system will be built | — | SDLC artefacts |
| PRD | Product Requirements Document — unified product specification across all features | — | SDLC artefacts |

---

## How to add a term

1. Add a row to the table above
2. Use sentence case for the term name
3. Keep the definition to one sentence
4. List all common aliases (these should redirect to the canonical term in artefacts)
5. Specify which modules the term applies to, or "All" if product-wide
