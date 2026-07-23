# /generate-ai-feature-registry — Generate AI Feature Registry from Codebase

Scan the codebase to build a draft registry of every AI feature in the product. Present it to the user for review and editing before saving. This is the AI-feature equivalent of `/generate-module-registry` — same read-draft-confirm-save flow, scoped to AI features only.

**Note:** `artefacts/product-docs/ai-feature-review/ai-feature-dependency-map.csv` is a separate, manual three-way cross-reference (client documentation, GitHub issue, and code implementation per feature) — not an audit, and not produced by this command. Do not overwrite it.

---

## Step 1 — Check codebase

Apply the standard codebase priority rule:

- Read every project directory present in `coderepo/`.
- If `coderepo/` contains more than one project and the user has not named which to use, ask before proceeding.
- If `coderepo/` is empty or absent, tell the user: "No codebase found in `coderepo/`. Add your project source code there and try again." Stop.

---

## Step 2 — Read existing AI feature registry

If `artefacts/product-docs/ai-feature-review/ai-features.md` exists, read it and note any features already listed — these are candidates to keep, update, or remove. If it does not exist, check `context/ai-features.md` as a fallback. If neither exists, start fresh.

---

## Step 3 — Identify AI features

Look in these locations — an AI feature can be defined in any of them:

- `packages/api/src/routers/ai/` — the primary location for AI feature routers
- `packages/api/src/routers/helpers/` — some AI features live here instead (e.g. an AI summary triggered from a background job rather than a direct user action); check for files that call into an AI task or model
- `packages/ai/src/runTasks/` and `packages/ai/src/tasks.ts` — the underlying task definitions each router calls
- Any feature-flag settings UI (e.g. an AI Features admin settings screen) — this is often the most complete list of named, user-facing AI features and their flag constants

For each feature found, capture:

- **Name** — the user-facing feature name (from the settings UI or router/task naming)
- **Trigger type** — user-initiated (a button/action) or automatic (a cron, background job, or record-count threshold)
- **Code location** — the router file and, if separate, the task file
- **Feature flag** — the constant gating it, or "always on" / "not flagged" if none
- **Status** — Implemented, Planned, or Off — based on whether it is wired into a router and called from an app, or only scaffolded

**Do not include:**

- Generic AI infrastructure with no user-facing feature attached (e.g. a shared gateway client, telemetry wrapper, or prompt-injection utility)
- Task config or usage-metrics plumbing that supports features already listed elsewhere in the registry

---

## Step 4 — Draft the registry table

Build a draft table in this format:

| AI Feature | Description | Trigger Type | Code Location | Feature Flag | Status |
| --- | --- | --- | --- | --- | --- |

Rules:

- One row per feature
- Title case for the feature name, suffixed with `[AI]`
- Description: one sentence, plain English — what the feature does for the user, no code references
- Code Location: router file path, and task file path if separate
- Feature Flag: the constant name, or "Always on" / "Not flagged"
- Status: `Implemented`, `Planned`, or `Off`
- Sort rows alphabetically by AI Feature

---

## Step 5 — Present for review

Show the draft table to the user. Say:

> "Here is the draft AI feature registry based on the codebase. Review each row — edit, add, or remove any features. When you are happy, say **save** and I will write it to `artefacts/product-docs/ai-feature-review/ai-features.md`."

Wait for the user's response. Accept edits in any form — inline corrections, additions, deletions, or "remove row X". Apply every change before saving.

If the user says "save" with no further edits, proceed to Step 6.

---

## Step 6 — Save

Write the agreed content to **both** of the following files, keeping the header block and "How to add a feature" section exactly as shown. Replace only the table rows with the agreed content.

```markdown
# AI Feature Registry

> The authoritative list of AI features for this project.
> Run `/generate-ai-feature-registry` to populate this file from your codebase.
> For what data feeds any single feature in the code, run `/ai-feature-data-audit [feature name]`. For a three-way cross-reference against GitHub issues and client documentation, see `ai-feature-dependency-map.csv` (maintained separately).

---

| AI Feature | Description | Trigger Type | Code Location | Feature Flag | Status |
| --- | --- | --- | --- | --- | --- |

---

## How to add a feature

1. Add a row to the table above
2. Use title case for the feature name, suffixed with `[AI]`
3. Keep the description to one sentence — what the feature does for the user
4. Set Code Location to the router file (and task file, if separate)
5. Set Feature Flag to the gating constant, or "Always on" / "Not flagged"
6. Set Status to `Implemented`, `Planned`, or `Off`
```

1. `artefacts/product-docs/ai-feature-review/ai-features.md` — the versioned artefact copy
2. `context/ai-features.md` — the working reference copy, available to the team without opening artefacts

Both files must be identical after saving. If either already exists, overwrite it.

Confirm to the user: "AI feature registry saved to `artefacts/product-docs/ai-feature-review/ai-features.md` and `context/ai-features.md` — {N} features."

---

## Notes

- If a feature already exists in the registry under a different name, flag the conflict to the user before overwriting.
- Do not invent features not evidenced by the codebase.
- Today's date comes from the `currentDate` value in memory context, or run `date +%Y-%m-%d` if not available.
