# /generate-ai-feature-dependency-map — AI Feature Module Dependency Map

For every AI feature, map which product modules it depends on to function — the AI-feature equivalent of `artefacts/modules/module-dependency-map.csv`'s "Depends On to Function" column, scoped to AI features. Codebase-only — no GitHub or client-documentation lookup required, so it is cheap to run for the whole registry at once.

**Recommended order:** run `/generate-ai-feature-registry` first (feature list), then `/ai-feature-data-audit` on any feature needing a deep data-source read, then this command to map features to modules. This command reuses the registry's feature list and the audit's data-tracing approach rather than repeating discovery from scratch.

---

## Step 1 — Check codebase

Apply the standard codebase priority rule: read every project directory in `coderepo/`; if more than one exists and the user has not said which to use, ask. If `coderepo/` is empty or absent, state this and stop.

---

## Step 2 — Resolve the feature list

- If `artefacts/product-docs/ai-feature-review/ai-features.md` exists (from `/generate-ai-feature-registry`), use its rows as the feature list.
- If it does not exist, run that command's Step 3 discovery first, or ask the user to run `/generate-ai-feature-registry`.
- If the user named specific feature(s) only, scope this run to those.

---

## Step 3 — Read the module registry

Read `artefacts/modules/modules.md` (fallback `context/modules.md`). This is the authoritative list of module names — every dependency named in this map must match a module listed here. If a data source doesn't map cleanly to any listed module, flag it rather than inventing a module name.

---

## Step 4 — Trace each feature's dependencies

For each AI feature, using the same tracing approach as `/ai-feature-data-audit`:

1. Read the router (`packages/api/src/routers/ai/`, or `packages/api/src/routers/helpers/` if not there) and any task file it calls (`packages/ai/src/runTasks/`).
2. List every table/entity queried and map each one back to the module that owns it (per the module registry — e.g. care plan tables → "Care Plans", patient demographic tables → "Profile"). A feature commonly depends on more than one module.
3. Note any external system used (AI gateway model, a Bedrock agent, a Typesense index, an external pipeline) separately from module dependencies — these are infrastructure, not product modules, so keep them in their own column.
4. Determine downstream impact: if one of the dependent modules were disabled or a dependent feature flag turned off, what happens to this AI feature — does it fail outright, degrade (less context, weaker output), or is it unaffected?

---

## Step 5 — Draft the table

| AI Feature | Depends On (Modules) | External Systems Used | Downstream Impact if a Dependency Is Disabled | Feature Flag | Status |
| --- | --- | --- | --- | --- | --- |

Rules:
- One row per feature, title case, suffixed `[AI]`
- Depends On (Modules): every module name exactly as it appears in the module registry, separated by `; `
- External Systems Used: AI gateway/model, Bedrock agent, Typesense index, external pipeline — or `—` if none
- Downstream Impact: one sentence, plain English, what actually happens to the feature if a dependency goes away
- Sort rows alphabetically by AI Feature

---

## Step 6 — Present for review

Show the draft table before writing anything. Wait for confirmation or edits — accept inline corrections, additions, removals.

---

## Step 7 — Save

Respect `confirmBeforeSave`. Save to `artefacts/product-docs/ai-feature-review/ai-feature-module-map.csv`. If the file already exists, ask whether to replace it or update only the rows for features audited this run.

Confirm to the user: "AI feature module dependency map saved to `artefacts/product-docs/ai-feature-review/ai-feature-module-map.csv` — {N} features."

---

## Notes

- Do not invent a module dependency that isn't evidenced by an actual query or call in the code.
- If a feature depends on data outside any listed module (e.g. raw user/auth data used by every feature), note it once rather than repeating it as a dependency for every row — or ask the user whether it's worth listing at all.
- This file is distinct from `artefacts/product-docs/ai-feature-review/ai-feature-dependency-map.csv`, which cross-references client documentation and GitHub issues rather than module structure — do not conflate or overwrite one with the other.
