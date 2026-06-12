# /generate-module-registry — Generate Module Registry from Codebase

Scan the codebase and any existing artefacts to build a draft module registry. Present it to the user for review and editing before saving to `artefacts/modules/modules.md`.

---

## Step 1 — Check codebase

Apply the standard codebase priority rule:

- Read every project directory present in `coderepo/`.
- If `coderepo/` contains more than one project and the user has not named which to use, ask before proceeding.
- If `coderepo/` is empty or absent, tell the user: "No codebase found in `coderepo/`. Add your project source code there and try again." Stop.

---

## Step 2 — Read existing module registry

If `artefacts/modules/modules.md` exists, read it and note any modules already listed — these are candidates to keep, update, or remove. If it does not exist, check `context/modules.md` as a fallback. If neither exists, start fresh.

---

## Step 3 — Identify modules

Read the codebase and collect candidate modules. Look for:

- **Top-level page folders or route groups** — directories that map to distinct product areas (e.g. `pages/care-plans/`, `routes/invoicing/`)
- **Navigation items** — menu labels and sidebar entries that name distinct sections of the product
- **Named feature areas** — groups of related screens, workflows, or data managed together
- **Settings or admin sections** — distinct configuration areas (e.g. User Management, Notifications, Organisation Settings)

Also read any existing BRD, TIP, CR, and PD artefacts in `artefacts/` for module names already in use.

**Do not include:**

- Generic UI sections with no product meaning (e.g. "Layout", "Shared", "Utils")
- Sub-sections of a module that are not independently named product areas
- Technical infrastructure (e.g. "Auth middleware", "Database layer")

---

## Step 4 — Draft the module registry table

Build a draft table in this format:

| Module | Description | Owner | Notes |
| --- | --- | --- | --- |

Rules:

- One row per module
- Title case for the module name
- Description: one sentence, plain English — what the module does for the user
- Owner: the team or role responsible, or `TBC` if unknown
- Notes: status, version, key dependencies, or `—` if none
- Sort rows alphabetically by Module

---

## Step 5 — Present for review

Show the draft table to the user. Say:

> "Here is the draft module registry based on the codebase. Review each row — edit, add, or remove any modules. When you are happy, say **save** and I will write it to `artefacts/modules/modules.md`."

Wait for the user's response. Accept edits in any form — inline corrections, additions, deletions, or "remove row X". Apply every change before saving.

If the user says "save" with no further edits, proceed to Step 6.

---

## Step 6 — Save

Use `templates/MR.md` as the canonical structure. Write the agreed content to **both** of the following files, keeping the header block and "How to add a module" section from the template exactly as-is in each. Replace only the table rows with the agreed content.

1. `artefacts/modules/modules.md` — the versioned artefact, committed to git with the rest of the project's artefacts.
2. `context/modules.md` — the working reference copy in the context folder, available for the team to consult at any time without opening artefacts.

Both files must be identical after saving. If either already exists, overwrite it.

Confirm to the user: "Module registry saved to `artefacts/modules/modules.md` and `context/modules.md` — {N} modules."

---

## Notes

- If a module already exists in the registry under a different name, flag the conflict to the user before overwriting.
- Do not invent module names that are not evidenced by the codebase or existing artefacts.
- Today's date comes from the `currentDate` value in memory context, or run `date +%Y-%m-%d` if not available.
