# Business Requirements Document (BRD)

> **Status:** DRAFT | IN REVIEW | APPROVED
> **Artefact ID:** `{YYYY-MM-DD}-{product-slug}-BRD`
> **Scope:** {Whole product — or the named module(s) this document covers}
> **Version:** {e.g. 1.0}
> **Author:** Claude (AI) — **Verified by:** {Name / Role}
> **Date:** {YYYY-MM-DD}

> This document is written for clients and leadership. It sets out **who** the product is for, **why** it exists, and **what** it does — at a business level only. Detailed requirements, acceptance criteria, and how anything is built live in each module's PRD and its Change Requests, not here.

---

## 1. Overview

{Two or three sentences in plain English: what the product (or this part of it) is, who it serves, and the outcome it delivers. No jargon, no product-internal terminology.}

---

## 2. Who

### 2.1 Roles

{Everyone who uses the product. Product-level by default — one table for the whole document. Where a role only appears in certain modules, name them in the Modules column rather than repeating this table per module.}

| Role | Who they are | What they use the product for | Modules |
| --- | --- | --- | --- |
| {Role name} | {One line — their job, not their permissions} | {One line — the outcome they are after} | {Module names, or "All"} |

### 2.2 Other stakeholders

{People who do not use the product day to day but have an interest in it — commissioners, regulators, finance, senior leadership. Remove this section if there are none.}

| Stakeholder | Interest |
| --- | --- |
| | |

---

## 3. Why

### 3.1 The current situation

{What people do today and where it falls short — described in the client's own terms, not as a list of missing features.}

### 3.2 Objectives

| # | Objective | Why it matters | How we know it worked |
| --- | --- | --- | --- |
| OBJ-01 | {What the product must achieve} | {The business reason} | {An outcome the client can observe} |

### 3.3 Benefits

- {One line per benefit, each tied to a role from Section 2.}

---

## 4. What

{One subsection per module. List every module this document covers. Mark each one **New** (being built) or **Existing** (already live, documented here for completeness) so the client can see at a glance what is being built versus what is being recorded.}

### 4.1 {Module Name} — {New | Existing}

**Purpose:** {One sentence — what this module does for the people who use it.}
**Used by:** {Roles from Section 2.}

**Features:**

- {Feature name} — {one line: what the user can do, and what they get from it.}
- {Feature name} — {…}

### 4.2 {Module Name} — {New | Existing}

**Purpose:**
**Used by:**

**Features:**

- 

> Features are listed at capability level only. No field lists, screen layouts, business rules, edge cases, or acceptance criteria — those belong in the module's PRD and its Change Requests. If a feature needs more than one line to describe, it is a PRD item, not a BRD item.

---

## 5. Scope

**In scope:**

- {Module or capability included in this piece of work}

**Out of scope:**

- {Explicitly not included, and one line on why}

**Descoped:**

{Items that were originally in scope and have since been removed — what, and why. Remove this section if nothing has been descoped.}

- 

---

## 6. Assumptions and Constraints

**Assumptions:**

- {Something taken as true but not yet confirmed. Flag anything that would change the shape of the work if it turned out to be wrong.}

**Constraints:**

- {A business, regulatory, budget, or timing limit the product must work within. Business constraints only — not technical ones.}

---

## 7. Open Questions

| # | Question | Owner | Needed by |
| --- | --- | --- | --- |
| OQ-01 | | | |

---

## 8. Linked Documents

{Where the detail lives. Fill in as each module's documents are written.}

| Module | PRD | Product Documentation |
| --- | --- | --- |
| {Module Name} | {path, or "Not yet written"} | {path, or "Not yet written"} |

---

## 9. Revision History

| Version | Date | Author | Summary of change |
| --- | --- | --- | --- |
| 1.0 | {YYYY-MM-DD} | | Initial version |
