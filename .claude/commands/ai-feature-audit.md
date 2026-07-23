# /ai-feature-audit — AI Feature Data Audit

Audit exactly what data feeds a given AI feature, then explain it in plain English and give QA a way to test it. Run exactly as defined below — this command has no corresponding Rule in `CLAUDE.md`; treat this file as the source of truth.

**Usage:** `/ai-feature-audit [feature name]`

If no feature name is given, ask the user which AI feature to audit before proceeding.

---

## Step 1 — Locate the feature

Read `coderepo/` (apply the standard codebase priority rule: if more than one project exists and the user has not said which to use, ask).

1. Look for the router file under `packages/api/src/routers/ai/`.
2. If it is not there, check `packages/api/src/routers/helpers/` — some AI features (e.g. the missed medication summary) live there instead of under `routers/ai/`.
3. If it cannot be found in either location, say so explicitly and ask the user to point to the file.

---

## Step 2 — Trace every data source

1. List every database query the feature makes: table, columns selected, filters (`where` clauses), limits, and ordering. Note any joins/relations included.
2. If the router calls a separate prompt-building or task-config utility (e.g. `packages/ai/src/runTasks/`, `packages/ai/src/tasks.ts`), read that too and list every data section it assembles into the model prompt, the model ID used, and where the system prompt comes from.
3. Find where the feature is called from in the relevant app (e.g. `apps/web/`). Confirm exactly what value is passed for each input field the router expects. Note whether the call fires automatically on load/open, on a schedule (cron), or only on explicit user action.
4. Note any output filtering, post-processing, or validation applied before the AI's response reaches the user (schema validation, empty-result handling, retry/fallback behaviour).
5. Note any condition under which the feature silently produces nothing (no data to summarise, a notification setting turned off, a required field missing).

---

## Step 3 — Report

Present four sections, in this order. Do not save a file unless the user asks for one — this is a point-in-time analysis, not a templated artefact.

**1. Data sources (technical list)**
Every table queried, exact columns/fields read, every filter/limit/ordering applied, and every external input (user action, form field, other record) that feeds the AI call.

**2. Plain English explanation**
2–4 sentences, customer-friendly, no code references, no table or field names. What does this feature do, from the point of view of the person who uses or receives its output?

**3. Trigger behaviour and dependencies**
When does this run — automatically, on a schedule, or only on user action? What must exist first for it to produce output? What happens when that dependency is missing — does it skip silently, or error?

**4. QA testing guide**
- How to trigger the feature manually (or reproduce the conditions that trigger it automatically).
- The minimum data setup needed to see it produce output.
- At least one negative/edge case: no data, malformed data, or the dependency from section 3 missing — confirm it fails safely rather than erroring or showing stale output.
- What "correct" output looks like, so a tester can judge a pass without reading the code.

---

## Step 4 — If the user wants it saved

Only if asked: save to `artefacts/product-docs/ai-feature-analysis/audits/{feature-slug}-ai-audit.md`, alongside the AI feature registry and module map. Respect `confirmBeforeSave`.
