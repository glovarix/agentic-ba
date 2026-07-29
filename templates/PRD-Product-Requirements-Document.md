# Product Requirements Document (PRD)

> **Status:** DRAFT | IN REVIEW | APPROVED
> **Artefact ID:** `{YYYY-MM-DD}-{module-slug}-PRD`
> **Module:** {Module Name} (or named group of modules)
> **Version:** {e.g. 1.0}
> **Author:** Claude (AI) — **Verified by:** {Name / Role}
> **Date:** {YYYY-MM-DD}

---

## 1. Module Summary

{2–3 sentences: what this module does today, who uses it, and its scope within the product.}

---

## 2. Source Change Requests

{Every CR joined into this PRD. One row per CR. This is the join — the mechanism that makes a PRD current.}

| CR | Summary | Date |
|----|---------|------|
| [{CR title}]({relative path to CR}) | {What it added or changed} | {YYYY-MM-DD} |

---

## 3. Functional Requirements

{One FR per capability. Tag every FR with its source — a specific CR, or "Baseline" for existing behaviour no CR ever covered. Baseline FRs are what make this PRD cover the full module, not just its CR-shaped pieces.}

### FR-01: {Title}

**Description:** {What the system must do.}
**Source:** [{CR title}]({relative path}) — or — Baseline (existing behaviour, no CR)

**Acceptance Criteria:**

- AC-01-01: {Observable, testable outcome}
- AC-01-02:

---

### FR-02: {Title}

**Description:**
**Source:**

**Acceptance Criteria:**

- AC-02-01:

---

## 4. Non-Functional Requirements

{Only include if a source CR or the codebase surfaces one. Leave the table empty otherwise.}

| #      | Category      | Requirement |
|--------|---------------|-------------|
| NFR-01 | Performance   |             |

---

## 5. Scope

**In scope (current, consolidated):**

- {What the module covers today, across all its joined CRs}

**Out of scope:**

- {What is explicitly not covered}

---

## 6. Open Items / Gaps

{Behaviour observed in the codebase with no formal requirement anywhere — no CR, no BRD. Flag for the team to formalise, don't invent a requirement to fill the gap.}

| # | Gap | Recommendation |
|---|-----|-----------------|
| G-01 | | |

---

## 7. Linked Artefacts

| Type | Description | Path |
|------|-------------|------|
| BRD  |             |      |
| PD   |             |      |
