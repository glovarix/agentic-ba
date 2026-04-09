# Business Requirements Document (BRD)

> **Status:** DRAFT | IN REVIEW | APPROVED
> **Artefact ID:** `{YYYY-MM-DD}-{feature-slug}-BRD`
> **Feature:** {Feature Title}
> **Module:** {Module Name}
> **Author:** Claude (AI) — Human Verified
> **Verified by:** {Name / Role}
> **Date:** {YYYY-MM-DD}
> **Version:** 1.0

---

## 1. Executive Summary

{2–3 sentences summarising what this feature does, why it exists, and what value it delivers to the business and users. Written for a non-technical executive audience.}

---

## 2. Business Context & Objectives

### 2.1 Problem Statement

{Describe the specific problem or gap this feature addresses. Be concrete — reference pain points, workarounds currently in use, or compliance/regulatory drivers if applicable.}

### 2.2 Business Objectives

| # | Objective | Success Indicator |
|---|---|---|
| OBJ-01 | {What the business wants to achieve} | {How we know it worked} |
| OBJ-02 | | |

### 2.3 Strategic Alignment

{1–2 sentences linking this feature to a product roadmap, compliance requirement, or organisational goal. If not applicable, write "N/A".}

---

## 3. Stakeholders

| Role | Responsibility in this Feature | Primary or Secondary |
|---|---|---|
| {Role from CONTEXT.json} | {What they do with this feature} | Primary |
| {Role} | {Responsibility} | Secondary |

---

## 4. User Stories

{One user story per primary behaviour. Format: **As a [role], I want [capability] so that [benefit].**}

- **US-01:** As a {role}, I want to {action} so that {benefit}.
- **US-02:** As a {role}, I want to {action} so that {benefit}.
- **US-03:** As a {role}, I want to {action} so that {benefit}.

---

## 5. Functional Requirements

{One FR per discrete behaviour. Each FR must be independently testable.}

### FR-01: {Short title}

**Description:** {What the system must do. Present tense, active voice.}
**Triggered by:** {What user action or system event triggers this}
**User role(s):** {Who can perform this action}

**Acceptance Criteria:**
- AC-01-01: {Observable, exact expected outcome}
- AC-01-02: {Observable, exact expected outcome}

---

### FR-02: {Short title}

**Description:**
**Triggered by:**
**User role(s):**

**Acceptance Criteria:**
- AC-02-01:
- AC-02-02:

---

### FR-03: {Short title}

*(Continue for all functional requirements)*

---

## 6. Field Specifications

{Complete this table if the feature involves forms, data capture, or new/modified fields.}

| Field Name | Label (UI) | Input Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| {field_name} | {UI label} | Text / Dropdown / Date / Boolean / Rich Text | Yes / No | {e.g. "Must be a valid date", "Min 1 character"} | {value or "None"} |

---

## 7. User Interface Requirements

{Describe expected UI behaviour at a functional level. Do not specify implementation (no CSS, no component names). Reference existing patterns where applicable.}

- **UI-01:** {Describe what the user sees/interacts with}
- **UI-02:** {Describe a specific UI behaviour, e.g. "The Save as Draft button is disabled until at least one mandatory field is populated"}
- **UI-03:** {Error state behaviour}

---

## 8. Non-Functional Requirements

| # | Category | Requirement |
|---|---|---|
| NFR-01 | Performance | {e.g. "The feature must load within 2 seconds on a standard broadband connection"} |
| NFR-02 | Security | {e.g. "Only users with the Provider role or above may create records"} |
| NFR-03 | Accessibility | {e.g. "All form fields must have visible labels and meet WCAG 2.1 AA contrast requirements"} |
| NFR-04 | Data Retention | {e.g. "All records must be retained for a minimum of 7 years per NHS data standards"} |
| NFR-05 | Audit | {e.g. "All create/edit/delete actions must be recorded in the audit log with user ID and timestamp"} |

---

## 9. Integration Points

{List any external systems, APIs, or internal modules this feature depends on or communicates with.}

| Integration | Direction | Purpose | Notes |
|---|---|---|---|
| {System/Module name} | Inbound / Outbound / Bidirectional | {What data flows and why} | {Any constraints or latency requirements} |

---

## 10. In Scope

- {Explicit list of what IS included in this feature}
- {Keep each item to one sentence}

---

## 11. Out of Scope

- {Explicit list of what is NOT included — prevents scope creep}
- {e.g. "Bulk import of care plans is not in scope for this iteration"}

---

## 12. Constraints & Assumptions

### Constraints
- {Known technical, compliance, or business constraints that limit the design}

### Assumptions
- {Assumptions the BA has made that need validation before development begins}
- {e.g. "It is assumed that the Service User record already exists before a care plan is created"}

---

## 13. Open Items

{Questions that must be resolved before development begins. Assign an owner and a target date.}

| # | Question | Owner | Target date | Status |
|---|---|---|---|---|
| OI-01 | {Question} | {Role} | {YYYY-MM-DD} | Open |

---

## 14. Glossary

{List any domain-specific terms used in this document. Cross-reference with `context/glossary.md`.}

| Term | Definition |
|---|---|
| {Term} | {Definition} |

---

## 15. Revision History

| Version | Date | Author | Summary |
|---|---|---|---|
| 1.0 | {YYYY-MM-DD} | Claude (AI) | Initial draft |
| 1.1 | | | Human review and approval |
