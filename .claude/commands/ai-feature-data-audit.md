# /ai-feature-data-audit — AI Feature Data Audit

Audit exactly what data feeds a given AI feature, then explain it in plain English and give QA a way to test it. Run exactly as defined below — this command has no corresponding Rule in `CLAUDE.md`; treat this file as the source of truth.

**Usage:** `/ai-feature-data-audit [feature name]`

If no feature name is given, ask the user which AI feature to audit before proceeding.

---

## Step 1 — Locate the feature

Read `coderepo/` (apply the standard codebase priority rule: if more than one project exists and the user has not said which to use, ask).

1. If `artefacts/product-docs/ai-feature-review/ai-features.md` exists, read the feature's row — its Code Location column is the fastest route to the right file.
2. Otherwise, find the handler yourself. Search `coderepo/` for the feature's user-facing name and its flag constant, then for the AI layer generally — model or provider SDK clients, prompt strings, and any directory or package named for `ai`, `llm`, `prompt`, `agent`, or similar. The handler is wherever this codebase exposes callable server-side operations (routers, controllers, API routes, serverless functions, service classes).
3. Check outside the AI layer too. A feature triggered by a background job, a scheduled task, or a threshold rather than a user action often sits alongside ordinary handlers rather than in an AI-specific folder.
4. If it cannot be found, say so explicitly and ask the user to point to the file. Do not guess at a location.

---

## Step 2 — Trace every data source

1. List every database query the feature makes: table, columns selected, filters (`where` clauses), limits, and ordering. Note any joins/relations included.
2. If the handler calls a separate prompt-building or task-config layer, read that too and list every data section it assembles into the model prompt, the model ID used, and where the system prompt comes from.
3. Find where the feature is called from in the client or calling application. Confirm exactly what value is passed for each input field the handler expects. Note whether the call fires automatically on load/open, on a schedule (cron), or only on explicit user action.
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

Only if asked: save to `artefacts/product-docs/ai-feature-review/data-audits/{feature-slug}-ai-data-audit.md`, alongside the AI feature registry and module map. Respect `confirmBeforeSave`.
