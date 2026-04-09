# Product Requirements Document (PRD)

> **Status:** DRAFT | IN REVIEW | APPROVED | SUPERSEDED
> **Artefact ID:** `{YYYY-MM-DD}-{project-slug}-PRD`
> **Product:** {Product Name}
> **Version:** {1.0}
> **Author:** Claude (AI) — Human Verified
> **Product Owner:** {Name}
> **Date:** {YYYY-MM-DD}

---

## Table of Contents

1. [Product Overview](#1-product-overview)
2. [Problem Statement](#2-problem-statement)
3. [Goals & Success Metrics](#3-goals--success-metrics)
4. [Stakeholders & Personas](#4-stakeholders--personas)
5. [Feature Specifications](#5-feature-specifications)
6. [Non-Functional Requirements](#6-non-functional-requirements)
7. [Release Plan](#7-release-plan)
8. [Dependencies](#8-dependencies)
9. [Open Items](#9-open-items)
10. [Appendix — Linked Artefacts](#10-appendix--linked-artefacts)
11. [Appendix — Glossary](#11-appendix--glossary)
12. [Revision History](#12-revision-history)

---

## 1. Product Overview

{3–5 sentences describing the product. What it is, who it serves, and what makes it valuable. Written for a new stakeholder who has no prior context.}

**Product domain:** {e.g. Healthcare IT — Electronic Care Record}
**Regulatory context:** {e.g. CQC-registered providers, NHS Data Security Standards}
**Current version:** {e.g. v2.4}
**Base URL (staging):** {e.g. https://demo.staging.product.app}

---

## 2. Problem Statement

{Describe the core problems this product solves. Use the perspective of the end user, not the technology team. 3–5 bullet points or short paragraphs.}

- {Problem 1}
- {Problem 2}
- {Problem 3}

---

## 3. Goals & Success Metrics

| Goal | Metric | Target | Measurement Method |
|---|---|---|---|
| {What we want to achieve} | {How we measure it} | {Specific target value} | {Where/how measured} |
| Reduce time to create a care plan | Average time from open to submit | < 5 minutes | Analytics event tracking |
| Eliminate duplicate incident reports | Duplicate incident rate | < 1% | Monthly data audit |

---

## 4. Stakeholders & Personas

{One subsection per primary role. Derived from CONTEXT.json stakeholders.}

### 4.1 {Role Name} (Primary)

**Who they are:** {1–2 sentences}
**Goals:** {What they are trying to achieve when using this product}
**Pain points:** {What slows them down or causes errors today}
**Key features they use:** {List of modules}

---

### 4.2 {Role Name} (Secondary)

**Who they are:**
**Goals:**
**Pain points:**
**Key features they use:**

---

## 5. Feature Specifications

{One subsection per feature/epic. Each section is assembled from the corresponding BRD. BRD content is summarised here — link to the full BRD for complete detail.}

---

### 5.1 {Feature Title}

> **Linked BRD:** [{filename}](../requirements/{filename}.md)
> **Module:** {Module}
> **Status:** Approved / In Review

#### Summary
{2–3 sentences from the BRD Executive Summary}

#### User Stories
- **US-01:** As a {role}, I want {capability} so that {benefit}.
- **US-02:** As a {role}, I want {capability} so that {benefit}.

#### Functional Requirements

| FR | Description | Priority |
|---|---|---|
| FR-01 | {Requirement description} | Must have |
| FR-02 | {Requirement description} | Should have |
| FR-03 | {Requirement description} | Could have |

#### Acceptance Criteria
- AC-01: {Observable outcome}
- AC-02: {Observable outcome}

#### Out of Scope
- {Item not included}

#### Open Items
- {Any unresolved items from the BRD}

---

### 5.2 {Next Feature Title}

*(Continue pattern for all features)*

---

## 6. Non-Functional Requirements

{Aggregate NFRs across all features. Deduplicate. Applies product-wide unless noted.}

| # | Category | Requirement | Scope |
|---|---|---|---|
| NFR-01 | Performance | All pages must load within 2 seconds on a standard broadband connection | Product-wide |
| NFR-02 | Security | All API endpoints require JWT authentication; minimum role enforced per endpoint | Product-wide |
| NFR-03 | Accessibility | All UI must meet WCAG 2.1 AA | Product-wide |
| NFR-04 | Audit | All create/edit/delete actions logged with user ID, timestamp, and record ID | Product-wide |
| NFR-05 | Data Retention | All clinical records retained for 7 years minimum | Clinical modules |
| NFR-06 | Availability | 99.5% uptime during business hours (07:00–22:00 UK time) | Product-wide |

---

## 7. Release Plan

| Milestone | Features included | Target date | Status |
|---|---|---|---|
| {Release name or sprint} | {Feature list} | {YYYY-MM-DD} | Planned / In Progress / Released |

---

## 8. Dependencies

| Dependency | Type | Required by | Notes |
|---|---|---|---|
| {System or feature} | Internal / External / Infrastructure | {Feature that depends on it} | |

---

## 9. Open Items

| # | Question | Owner | Target date | Status |
|---|---|---|---|---|
| PRD-OI-01 | {Question requiring resolution} | {Role} | {YYYY-MM-DD} | Open |

---

## 10. Appendix — Linked Artefacts

{All artefacts that form part of this PRD. Links are the single source of truth — do not duplicate content.}

### Business Requirements Documents
| Feature | BRD path | Status |
|---|---|---|
| {Feature} | [Link](../requirements/{filename}.md) | Approved |

### Technical Implementation Plans
| Feature | TIP path | Status |
|---|---|---|
| {Feature} | [Link](../implementation/{filename}.md) | In Review |

### Test Suites
| Module | Test suite path | Cases |
|---|---|---|
| {Module} | [Link](../test-suites/{MODULE}/) | {N} test cases |

---

## 11. Appendix — Glossary

{Pulled from context/glossary.md — always the full glossary, not a subset.}

| Term | Definition |
|---|---|
| {Term} | {Definition} |

---

## 12. Revision History

{AI-generated entries are marked (AI). Human review entries must include the reviewer's name.}

| Version | Date | Author | Summary |
|---|---|---|---|
| 1.0 | {YYYY-MM-DD} | Claude (AI) | Initial generation from {N} BRDs |
| 1.1 | {YYYY-MM-DD} | {Name} (Product Owner) | Human review — approved |
