# Technical Implementation Plan (TIP)

> **Status:** DRAFT | IN REVIEW | APPROVED
> **Artefact ID:** `{YYYY-MM-DD}-{feature-slug}-TIP`
> **Feature:** {Feature Title}
> **Linked BRD:** [{BRD filename}](../requirements/{BRD-filename}.md)
> **Author:** Claude (AI) — **Verified by:** {Dev Lead}
> **Date:** {YYYY-MM-DD}

---

## 1. Summary

{2–3 sentences: what this covers, key technical changes, scope.}

**Effort:** S (<1 day) / M (1–3 days) / L (3–7 days) / XL (>7 days)
**Dependencies:** {Blocking items or "None"}

---

## 2. Implementation Tasks

### Backend

| #     | Task | FR(s) | Effort |
|-------|------|-------|--------|
| BE-01 |      |       |        |

### API

| #      | Task                     | FR(s) | Effort |
|--------|--------------------------|-------|--------|
| API-01 | {Endpoint to add/modify} |       |        |

### Frontend

| #     | Task                           | FR(s) | Effort |
|-------|--------------------------------|-------|--------|
| FE-01 | {Component/page to add/modify} |       |        |

---

## 3. API Contracts

### `{METHOD} /api/{endpoint}`

**Purpose:** {What it does} | **Auth:** JWT — min role: {Role}

**Request:**

```json
{
  "field_name": "string"
}
```

**Success — `{2xx}`:**

```json
{
  "id": "uuid"
}
```

**Errors:**

| Code | Condition         |
|------|-------------------|
| 400  | Missing field     |
| 401  | Unauthenticated   |
| 403  | Insufficient role |

---

## 4. Data Model Changes

{Skip if no schema changes — write "None required."}

**Table:** `{table_name}`

| Column       | Type         | Nullable | Default           |
|--------------|--------------|----------|-------------------|
| `id`         | UUID         | No       | gen_random_uuid() |
| `{field}`    | VARCHAR(255) | No       | —                 |
| `created_at` | TIMESTAMPTZ  | No       | NOW()             |

**Migration:** `{YYYY-MM-DD}-{description}.sql`

---

## 5. Risks & Open Questions

**Risks:**

| #    | Risk | Likelihood        | Mitigation |
|------|------|-------------------|------------|
| R-01 |      | High / Med / Low  |            |

**Open questions:**

| #     | Question | Owner | Due |
|-------|----------|-------|-----|
| OQ-01 |          |       |     |

---

## 6. Testing Notes

- {Specific conditions QA should cover — race conditions, permission boundaries, etc.}

**Linked test suite:** [{Module} Test Suite](../test-suites/{MODULE}/)
