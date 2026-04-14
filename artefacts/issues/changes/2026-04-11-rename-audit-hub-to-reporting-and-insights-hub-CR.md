# Rename Audit Hub to Reporting and Insights Hub — Restructure with Reporting and Insights Sub-modules

## Summary

Renames the top-level **Audit Hub** module to **Reporting and Insights Hub** and restructures it into two distinct sub-modules: **Reporting** (migrated from the current Audit Hub) and **Insights** (new). The Insights sub-module introduces CQC-aligned metrics and KPIs drawn from existing product data — starting with the **Safe** domain — providing managers with actionable, regulator-ready intelligence without leaving the platform. The sub-module architecture must be designed to accommodate all remaining CQC domains (Effective, Caring, Responsive, Well-led) without rework.

## Problem & Context

The current Audit Hub is limited to audit-specific workflows. As the product matures, there is a clear need for a broader intelligence layer — one that surfaces meaningful, CQC-aligned metrics from data already captured across modules (incidents, safeguarding, medications). Without this, users must export data and manually collate reports to answer the questions regulators ask.

## User Story

As a **Manager**, I want to view CQC-aligned incident and safeguarding metrics within Reporting and Insights Hub so that I can monitor service safety and demonstrate regulatory compliance in real time.

As an **Organisation Admin**, I want existing audit functionality preserved under a Reporting sub-module so that current workflows are uninterrupted during the transition.

## In Scope Checklist

### Module Rename

- [ ] Rename the top-level module from "Audit Hub" to "Reporting and Insights Hub" across navigation, page titles, breadcrumbs, and access control

### Reporting Sub-module

- [ ] Create "Reporting" as a sub-module under Reporting and Insights Hub
- [ ] Migrate all existing Audit Hub content into Reporting without functional changes

### Insights Sub-module

- [ ] Create "Insights" as a sub-module under Reporting and Insights Hub
- [ ] Sub-module layout and KPI card design must be reusable and domain-driven — built to support Safe, Effective, Caring, Responsive, and Well-led domains without redesign

### Safe Domain

- [ ] Total Incidents Logged — KPI showing count by severity grade with period comparison and trend
- [ ] Safeguarding Concerns — KPI showing open / closed / referred status split with overdue flag
- [ ] Medication Omissions & Errors — KPI showing incident count by medication error sub-type with 30-day period comparison
- [ ] Configurable Incident Type Count — user-configurable KPI showing count for a selected incident type with period comparison and sub-category drill-down

### Permissions

- [ ] Grant Organisation Admin access to Reporting and Insights Hub — this role currently does not have access to Audit Hub and will not inherit it automatically on rename

## Out of Scope

- CQC domains other than Safe (Effective, Caring, Responsive, Well-led) — to be delivered as subsequent iterations using the same sub-module architecture
- AI-powered features within the Insights sub-module — to be specified separately as AI Feature issues
- Changes to the Incident module data capture forms beyond the data model additions noted in Technical Notes

## Design & Media

Wireframes required for:

- Reporting and Insights Hub navigation showing Reporting and Insights sub-modules — recommend **tab-based layout** (Reporting | Insights) within the module page rather than sidebar nesting, to preserve the current flat navigation pattern
- KPI card design — must be reusable and configurable, grouped by CQC domain to support future domain additions without redesign
- Three-level breadcrumb pattern: Home → Reporting and Insights Hub → Reporting / Insights

## Acceptance Criteria (QA Team)

(placeholder — to be confirmed with QA before sprint)

## Technical Notes (Dev Team)

**Architecture — Sub-module Navigation**
The current module structure uses a flat, single-level pattern. Sub-modules must be introduced as nested sections within the renamed Reporting and Insights Hub page. Navigation must be updated to support a two-tier structure and breadcrumbs must display three levels.

**Scalability Requirement**
The Insights sub-module must be built to support all five CQC domains. KPI cards must be configurable by metric definition — not hardcoded per metric. All metrics must support a configurable date range to enable period comparison across all future domains.

**🔴 Blocker 1 — Safeguarding status too coarse**
Safeguarding records currently hold only two possible status values. The open / closed / referred split required by KPI 2 cannot be derived from the existing data without a structural change to how status is recorded. This must be resolved before KPI 2 can be built.

**🔴 Blocker 2 — Medication error sub-type not captured**
Medication incidents are not currently categorised by error sub-type at point of recording. KPI 3 cannot be built until a sub-type selection is added to the medication incident recording form and that data is captured going forward.

**🔴 Blocker 3 — Organisation Admin access missing**
Organisation Admin does not currently have access to the Audit Hub. Access must be explicitly granted to this role as part of the rename — it will not carry over automatically.

**⚠️ Verify period comparison**
Confirm that incident data can be filtered by both a start and end date to support period-over-period comparison. Verify this is possible before KPI development begins and extend the capability if needed.

**⚠️ Overdue flag**
Safeguarding records do not currently hold a review due date. A due date must be recorded against each safeguarding concern, and an overdue indicator derived from it, to support the overdue flag in KPI 2.

## Final Working Loom URL

(placeholder)

## Source Request URL

`request/Safe Domain CQC - Insights hub submodule.csv`

---

**Sanity check:**

- ✅ "Audit Hub" verified — route `/audit-hub`, permission `AUDIT_HUB:READ`, nav label currently "Audit" (not "Audit Hub")
- ✅ Incident module verified — `getIncidentSummary` API exists and is already used by Audit Hub dashboard
- ✅ Severity grades verified — `gradeIncidentConfirmation` field with 8 grades confirmed in migration `0222_incident_schema_safeguarding_updates.sql`
- ✅ Incident type drill-down verified — `IncidentType` + `IncidentCategory` tables exist with correct relationships
- ✅ Sub-module routing feasible — Next.js App Router supports nested `layout.tsx` pattern
- ⚠️ Navigation label is "Audit" not "Audit Hub" — rename scope includes label, route, and permission string
- ⚠️ `getIncidentSummary` uses single `startDate` parameter — period comparison capability needs verification before KPI builds begin
- ❌ `EncounterSafeguardingStatus.Status` is binary (`boolean`) — cannot support open/closed/referred split without schema migration
- ❌ `MedicationAdministrationRecord` has no error sub-type field — migration required before KPI #3 can be built
- ❌ `AUDIT_HUB:READ` not in `DefaultAttributes[ORGANISATION_ADMIN]` — must be explicitly added to both roles files
- ℹ️ Recommend tab-based sub-module layout (Reporting | Insights) over sidebar nesting — preserves existing flat navigation pattern
- ℹ️ Overdue flag requires new `ReviewDueDate` field on `EncounterSafeguardingStatus` — add to migration scope
