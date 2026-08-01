# /generate-module-registry — Generate Module Registry from Codebase

Scan the codebase and any existing artefacts to build a draft module registry. Present it to the
user for review and editing before saving to `artefacts/module-registry/modules.md`.

**The codebase is always the primary source when it exists, and is always read.** When it does not exist yet, a BRD can seed a provisional registry instead — see Step 1b. Additional reference material —
a client workbook, a raw notes file, a prior registry export — is a bonus when it exists, never a
requirement. Every step below must produce a complete, correct registry from `coderepo/` alone;
supplementary sources only make the reconciliation richer when they happen to be available.

---

## Step 1 — Check codebase

Apply the standard codebase priority rule:

- Read every project directory present in `coderepo/`.
- If `coderepo/` contains more than one project and the user has not named which to use, ask before proceeding.
- If `coderepo/` is empty or absent, do **not** stop yet — check for a BRD first (see Step 1b). Only if there is no BRD either, tell the user: "No codebase found in `coderepo/`, and no BRD in `artefacts/business-requirements/`. Add your project source code, or write a BRD first, and try again." Then stop.

---

## Step 1b — No codebase? Derive the registry from a BRD instead

A product that has not been built yet still has a module list, if a BRD exists: `templates/BRD-Business-Requirements-Document.md` Section 4 (What) is one subsection per module, each with a purpose line, the roles who use it, and its features one line each.

When `coderepo/` is empty or absent and `artefacts/business-requirements/` contains a BRD:

- Use the most recent BRD covering the widest scope as the **primary source** for this run, and say so plainly before drafting.
- Every step below runs unchanged. In particular Step 5 (exclude non-modules) and Step 6 (consolidate) matter *more* here, not less: a BRD's feature lines routinely read as CRUD actions ("Edit an order"), screens, or dashboards, and those are not modules.
- **Mark the result provisional.** Every module derived this way carries `(provisional — from BRD, unverified against code)` in its Notes column, and the saved file carries the provisional header shown in Step 10.
- **Code always wins.** If `coderepo/` has any code at all — even a starter scaffold — that is the primary source and the BRD becomes a supplementary source under Step 3 instead. Never let a BRD-derived row overwrite a module verified against code.
- On a later run, once code exists, reconcile: Step 2 already reads the existing registry, so a provisional row that is now evidenced in code loses its marker, and one that is still not found is raised with the user rather than silently dropped — it may be built later, or may have been descoped.

**Tell the user what this does and does not buy them:** a provisional registry is enough to name modules consistently across early artefacts, and not evidence that any of it exists.

---

## Step 2 — Read existing module registry

If `artefacts/module-registry/modules.md` exists, read it and note any modules already listed — these are candidates to keep, update, or remove. If it does not exist, check `context/modules.md` as a fallback. If neither exists, start fresh.

---

## Step 3 — Check for supplementary sources (optional, do not block on this)

Check whether the user has already supplied or referenced any other reference material in this
conversation — a CSV, a spreadsheet/workbook, a notes file, an old registry export, meeting notes
in `context/meeting-notes/`. If something is already evident, use it. If nothing is evident, ask
once, briefly, and proceed either way:

> "Do you have any other reference material — a spreadsheet, client notes, a prior registry — you'd like me to reconcile in? If not, I'll build this from the codebase alone."

Do not chase this further than one ask. A "no" or no response at all means proceed with the
codebase and the existing registry only — that is a fully valid, complete path, not a degraded one.

**If a workbook (`.xlsx`) is supplied:** read every worksheet/tab, not just the first one. Module
information is often split across tabs (e.g. a prioritisation view and a detailed-analysis view of
the same modules) and both must be read before reconciling.

---

## Step 4 — Identify candidate modules

Collect every candidate name from every source available (codebase always; supplementary sources
only if Step 3 produced any). Read everything before filtering anything — do not exclude while
still reading, do it as a separate pass (Step 5).

**From the codebase, look for:**

- Top-level page folders or route groups — directories that map to distinct product areas (e.g. `pages/orders/`, `routes/invoicing/`)
- Navigation items — menu labels and sidebar entries that name distinct sections of the product
- Named feature areas — groups of related screens, workflows, or data managed together
- Settings or admin sections — distinct configuration areas (e.g. User Management, Notifications, Organisation Settings)
- Any existing BRD, TIP, CR, and PD artefacts in `artefacts/` for module names already in use

**From a supplementary source, if supplied:** every named row, column value, or sheet section that
could plausibly be a module — including messy, duplicated, or inconsistently-cased raw text. Don't
pre-filter here; a raw CSV export commonly contains kebab-case slugs, plural/singular variants, and
CRUD-prefixed phrases ("Edit Daily Records") alongside genuine module names. Also watch for stray
data artefacts — section-header text fused into a cell, or a note-to-self left in a workbook row —
these are not candidates at all, discard them on sight rather than trying to classify them.

---

## Step 5 — Exclude non-modules

Strip out anything in the categories below before attempting to consolidate what's left. This pass
matters just as much on a codebase-only run as it does with extra sources — page-folder structure
alone routinely produces one "page" per CRUD action or per sub-view, and those still aren't modules.

- **CRUD actions** on a module's data (create, edit, delete, activate/deactivate, confirm/decline) — describes an operation on a module, not a module.
- **Workflows, screens, pages** that exist only to navigate to or aggregate other modules. Test: if this "module" were removed, would any information be lost that isn't already captured elsewhere? If no, it's a screen, not a module.
- **Dashboards** — same aggregation test as above.
- **Reports, as standalone entries** — an export/print/log format of an existing module, not a new one.
- **Settings and configuration screens** — fold into whatever administration/configuration module already exists (or should exist), never left standalone.
- **Permissions and roles** — always folded into administration/configuration. Never a standalone module, regardless of how a source names it.
- **Notifications-as-a-log** — if a source frames one entry as "the log of" or "distinct from" another entry, that phrasing is itself a signal they're one concept at two views, not two modules.
- **Imports / exports** — an operation, not a module.
- **Integrations** — a data source or channel feeding an existing module, not a new business capability.
- **APIs** — never a business module.
- **AI features, as standalone entries** — fold every AI capability into whatever module it augments (an AI auto-categorisation feature belongs in the module whose records it categorises; an AI summarisation feature belongs in the module whose content it summarises). If an AI item has no clear single parent and no current shipped scope (e.g. an open-ended proof-of-concept), exclude it outright — don't force-fit it into an arbitrary parent.
- **Mobile apps / delivery channels** — a client/platform for existing modules, not a new capability.
- **Other operational or implementation-level items** — anything technical, infrastructure-level, or UI-layout-only (e.g. "Layout", "Shared", "Utils", "Auth middleware", "Database layer").

List what got excluded and why — don't silently drop items. If something looks like a genuine
future capability with no current module to fold into (a roadmap item, a "not yet built" note),
don't invent a module for it either — note it separately as a candidate for future addition.

---

## Step 6 — Consolidate what's left

Work through these checks, in order, on the surviving candidate list:

1. **Identical description, different name → one module.** If two candidates describe the same thing in different words, merge them and pick the clearer, more business-facing name.
2. **Explicit nesting in a source → collapse to the parent.** If any source's own structure (indentation, a "sub-module" column, explicit prose) shows one item as part of another, trust that structure rather than re-deriving hierarchy from scratch.
3. **Same concept at different scopes (organisation-level vs. individual-record-level) → usually one module.** Merge unless the two scopes genuinely have independent data models and audiences (a directory/list is structurally different from an individual record within it — those stay separate).
4. **A cluster of narrowly-scoped siblings under one named parent → collapse to the parent.**
5. **Self-audit for asymmetric treatment.** Before finalising, scan the merged list for any two entries that share the same shape of description (e.g. two "historical X records" rows) and check they were resolved the same way. This is the easiest category of mistake to make and the easiest to miss unless checked for explicitly as its own pass.
6. **Naming collisions → rename, don't force a merge.** If two genuinely distinct modules want the same name, that's a naming problem, not a scoping problem — rename one rather than merging concepts that don't actually overlap.
7. **When sources disagree on scope or direction, prefer the most current/authoritative signal** — typically the live codebase, or the most recently supplied material — over an older registry entry kept only for stability's own sake. Use judgement, not frequency: don't pick a name just because it appears in more sources.

---

## Step 7 — Apply the naming standard

- Title Case with spaces for the display name (e.g. "Orders," "Risk Management") — not literal hyphens. Hyphenation belongs at the filename/slug layer only (`billing-history`), consistent with how this project already generates artefact filenames.
- Nouns, not verb phrases ("Invoices," not "Manage Invoice").
- One word whenever possible; two words only where one would be ambiguous or too generic; three words only if truly necessary.
- A name must read naturally in a sentence a client would say out loud, and work as a document prefix (e.g. `Orders-PRD`, `Billing-TC-01`).
- If a module is being renamed from what's in the current registry, check `artefacts/` for existing CRs, BRDs, or other artefacts that reference the old name — flag this to the user before saving, since a rename can silently orphan references in already-written artefacts.

---

## Step 8 — Draft the module registry table

Build a draft table in this format:

| Module | Slug | Description | Owner | Notes |
| --- | --- | --- | --- | --- |

Rules:

- One row per module
- Title case for the module name
- Slug: the lowercase kebab-case form of the module name, in backticks (e.g. `orders`, `billing-history`) — this is the literal filename prefix every artefact type uses (`{date}-{slug}-CR.md`, `{slug}-TC-01.md`, etc.), so it must be generated and shown explicitly here, not left implicit in the naming standard. Spaces become hyphens, `&` becomes `and`, all other punctuation is dropped.
- Description: one sentence, plain English — what the module does for the user
- Owner: the team or role responsible, or `TBC` if unknown
- Notes: status, version, key dependencies, or `—` if none. When a row consolidates more than one prior name, or renames an existing module, say so briefly in Notes (e.g. "Consolidates Reporting Hub, Reporting Log" or "Renamed from Manage Invoice") so the provenance is visible in the artefact itself, not just in chat.
- Sort rows alphabetically by Module

---

## Step 9 — Present for review

Show the draft table to the user. If Step 6 or Step 7 made any non-trivial merges, renames, or
exclusions (i.e. this wasn't just a first-ever, single-source pass with nothing to reconcile),
also show a short summary — a compact list of what got merged or renamed and why, and what got
excluded and why. Keep this proportionate to how much reconciliation actually happened; a
routine incremental run with no real conflicts doesn't need a full write-up, but any run that
merged, renamed, or dropped something the user might reasonably question does.

Say:

> "Here is the draft module registry based on {the codebase / the codebase and the reference material you provided}. Review each row — edit, add, or remove any modules. When you are happy, say **save** and I will write it to `artefacts/module-registry/modules.md`."

Wait for the user's response. Accept edits in any form — inline corrections, additions, deletions, or "remove row X". Apply every change before saving.

If the user says "save" with no further edits, proceed to Step 10.

---

## Step 10 — Save

Use the canonical structure below — power skill output structure lives in this command file, not in `templates/`. Write the agreed content to **both** of the following files, keeping the header block and "How to add a module" section exactly as shown. Replace only the table rows with the agreed content.

```markdown
# Module Registry

> The authoritative list of product modules for this project.
> Run `/generate-module-registry` to populate this file from your codebase.
> All artefacts must use module names exactly as listed here.
> The agent reads this file before generating any artefact (except BRDs).
> If this registry was derived from a BRD rather than from code (see Step 1b), state that here:
> **Provisional — derived from {BRD filename}, not yet verified against a codebase.** Re-run
> `/generate-module-registry` once code exists to reconcile it.
>
> The Slug column is the lowercase kebab-case form used as the filename prefix for every
> artefact (PRD, PD, CR, TC, etc.) — e.g. `orders` → `2026-07-29-orders-CR.md`.

---

| Module | Slug | Description | Owner | Notes |
| --- | --- | --- | --- | --- |

---

## How to add a module

1. Add a row to the table above
2. Use title case for the module name
3. Slug: lowercase kebab-case version of the module name, used as the filename prefix for every artefact (`&` becomes `and`, spaces become hyphens)
4. Keep the description to one sentence — what the module does for the user
5. Set Owner to the team or role responsible, or `TBC` if unknown
6. Use Notes for status, dependencies, or links to BRDs — or `—` if none
```

1. `artefacts/module-registry/modules.md` — the versioned artefact, committed to git with the rest of the project's artefacts.
2. `context/modules.md` — the working reference copy in the context folder, available for the team to consult at any time without opening artefacts.

Both files must be identical after saving. If either already exists, overwrite it.

Confirm to the user: "Module registry saved to `artefacts/module-registry/modules.md` and `context/modules.md` — {N} modules."

---

## Notes

- If a module already exists in the registry under a different name, flag the conflict to the user before overwriting.
- Do not invent module names that are not evidenced by the codebase or existing artefacts (or, when supplied, other reference material) — never guess to fill a gap.
- When sources disagree, resolve it with architectural judgement (Step 6.7) and say so in the review summary (Step 9) — never silently pick one and hide the conflict.
- This process works identically whether one source (the codebase) or several are available. Do not treat a codebase-only run as incomplete, and do not lower the bar on exclusion/consolidation discipline (Steps 5–7) just because there's only one source to reconcile.
- Today's date comes from the `currentDate` value in memory context, or run `date +%Y-%m-%d` if not available.
