# /generate-module-registry — Generate Module Registry from Codebase

Scan the codebase to build a draft module registry. Present it to the user for review and editing
before saving to `artefacts/module-registry/modules.md`.

## The codebase is the only source. There is no other one.

Every module in this registry must be evidenced in `coderepo/`. Not a BRD, not a spreadsheet or
workbook, not a prior registry export, not meeting notes, not an existing artefact, not the user's
description of the product. **If it is not in the code, it does not go in the registry.**

There is no provisional mode and no fallback source. A module list that was never verified against an
implementation is a guess wearing the authority of a registry — and because the Slug column is the
filename prefix for every PRD, PD, CR, and TC, a wrong row propagates into artefact names that are
awkward to correct later. So:

- **No codebase, no registry.** This skill does not run without code.
- **No external source may introduce a module.** A document naming a module the code does not implement is a discrepancy to report, never a row to write.
- **A registry with fewer certain modules beats one padded with plausible ones.** Under-report and flag the gap.

**This constrains what the agent may invent, not what the user may correct.** The registry is the
user's file and they can edit any part of it — this reading of the codebase is fallible, and the
person who knows the product will spot a module that was missed, misnamed, or wrongly merged. A user
correction is a pointer to something real: go and find it in the code, and record it properly. See
Step 8.

---

## Step 1 — Check codebase

Apply the standard codebase priority rule:

- Read every project directory present in `coderepo/`.
- If `coderepo/` contains more than one project and the user has not named which to use, ask before proceeding.
- **If `coderepo/` is empty or absent, stop.** Tell the user: "There is no codebase in `coderepo/` to read modules from, and a module registry can only be built from code — a BRD cannot stand in for it, because modules named before anything is built are a plan, not a registry. Add your project source code and run `/generate-module-registry` again." Then stop. Do not offer an alternative source, and do not draft a provisional registry.

---

## Step 2 — Read the existing registry, for reconciliation only

If `artefacts/module-registry/modules.md` exists, read it (falling back to `context/modules.md`). If
neither exists, start fresh.

**An existing row is not evidence.** It tells you what was true at the last run, not what is true
now. Every row must be re-evidenced against the code on every run:

- Still evidenced → keep, updating any detail that has changed.
- No longer found → do **not** keep it silently and do **not** silently drop it. Raise it in Step 8: the module may have been renamed, removed, or the code may have moved.
- Found under a new name → treat as a rename and follow Step 6's rename warning.

---

## Step 3 — Identify candidate modules

Collect every candidate name from the codebase. Read everything before filtering anything — do not
exclude while still reading, do it as a separate pass (Step 4).

**From the codebase, look for:**

- Top-level page folders or route groups — directories that map to distinct product areas (e.g. `pages/orders/`, `routes/invoicing/`)
- Navigation items — menu labels and sidebar entries that name distinct sections of the product
- Named feature areas — groups of related screens, workflows, or data managed together
- Settings or admin sections — distinct configuration areas (e.g. User Management, Notifications, Organisation Settings)

**Existing artefacts in `artefacts/` — for spelling, not for candidates.** A BRD, TIP, CR, or PD may
already name a module the code also has, and matching its spelling avoids a needless rename. That is
the only use: an artefact can never put a module on the candidate list. If one names a module the
codebase does not implement, that is a discrepancy to report in Step 8 — usually a module that was
never built, or one since removed — not a row to write.

---

## Step 4 — Exclude non-modules

Strip out anything in the categories below before attempting to consolidate what's left. Page-folder
structure alone routinely produces one "page" per CRUD action or per sub-view, and those aren't
modules.

- **CRUD actions** on a module's data (create, edit, delete, activate/deactivate, confirm/decline) — describes an operation on a module, not a module.
- **Workflows, screens, pages** that exist only to navigate to or aggregate other modules. Test: if this "module" were removed, would any information be lost that isn't already captured elsewhere? If no, it's a screen, not a module.
- **Dashboards** — same aggregation test as above.
- **Reports, as standalone entries** — an export/print/log format of an existing module, not a new one.
- **Settings and configuration screens** — fold into whatever administration/configuration module already exists (or should exist), never left standalone.
- **Permissions and roles** — always folded into administration/configuration. Never a standalone module, however the code names it. The product's roles are a separate artefact entirely: `/generate-role-registry`.
- **Notifications-as-a-log** — where the code treats one entry as "the log of" another, that is one concept at two views, not two modules.
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

## Step 5 — Consolidate what's left

Work through these checks, in order, on the surviving candidate list:

1. **Identical description, different name → one module.** If two candidates describe the same thing in different words, merge them and pick the clearer, more business-facing name.
2. **Explicit nesting in the code → collapse to the parent.** Where the codebase's own structure — nested routes, a parent folder, a foreign key to an owning entity — shows one item as part of another, trust that structure rather than re-deriving hierarchy from scratch.
3. **Same concept at different scopes (organisation-level vs. individual-record-level) → usually one module.** Merge unless the two scopes genuinely have independent data models and audiences (a directory/list is structurally different from an individual record within it — those stay separate).
4. **A cluster of narrowly-scoped siblings under one named parent → collapse to the parent.**
5. **Self-audit for asymmetric treatment.** Before finalising, scan the merged list for any two entries that share the same shape of description (e.g. two "historical X records" rows) and check they were resolved the same way. This is the easiest category of mistake to make and the easiest to miss unless checked for explicitly as its own pass.
6. **Naming collisions → rename, don't force a merge.** If two genuinely distinct modules want the same name, that's a naming problem, not a scoping problem — rename one rather than merging concepts that don't actually overlap.
7. **Where layers of the code disagree on scope or direction, prefer the most current signal** — what the application actually routes, renders, and persists today — over an older registry entry kept only for stability's own sake, or a stale name surviving in a comment or a dead constant.

---

## Step 6 — Apply the naming standard

- Title Case with spaces for the display name (e.g. "Orders," "Risk Management") — not literal hyphens. Hyphenation belongs at the filename/slug layer only (`billing-history`), consistent with how this project already generates artefact filenames.
- Nouns, not verb phrases ("Invoices," not "Manage Invoice").
- One word whenever possible; two words only where one would be ambiguous or too generic; three words only if truly necessary.
- A name must read naturally in a sentence a client would say out loud, and work as a document prefix (e.g. `Orders-PRD`, `Billing-TC-01`).
- If a module is being renamed from what's in the current registry, check `artefacts/` for existing CRs, BRDs, or other artefacts that reference the old name — flag this to the user before saving, since a rename can silently orphan references in already-written artefacts.

---

## Step 7 — Draft the module registry table

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

## Step 8 — Present for review

Show the draft table to the user, plus a short summary covering:

- **What got merged or renamed and why**, where Step 5 or Step 6 made a non-trivial call.
- **What got excluded and why** (Step 4) — especially anything the user might expect to see.
- **Anything in the previous registry no longer found in code** (Step 2).
- **Any module named in an existing artefact that the code does not implement** (Step 3).
- **Renames** affecting artefacts already written (Step 6).

Keep this proportionate to how much reconciliation actually happened; a routine incremental run with
no real conflicts doesn't need a full write-up, but any run that merged, renamed, or dropped
something the user might reasonably question does.

Then say:

> "Here is the draft module registry, built from the codebase. Review each row — edit, add, or remove any modules. When you are happy, say **save** and I will write it to `artefacts/module-registry/modules.md`."

Wait for the user's response. **Apply every correction, removal, rename, and rewording the user asks
for.** This is their registry and this skill's reading of the codebase is fallible — a missed module,
a wrong merge, a product area expressed somewhere unusual are all normal, and the user is the one who
will notice. Never argue a user out of a correction, and never make them repeat it.

**When the user adds or corrects a module, go and verify it in the code — to complete the row, not to
gatekeep it:**

- **Found it** — you missed it, or it was named differently than expected. Add it and say where it turned up, so the correction is anchored.
- **Cannot find it** — keep the user's row, and say once what you searched so they can point you at the right place: "Added {module} as you described. I could not locate it in the codebase — I looked at {where}. If you can point me at it, I'll confirm." Mark the row `(user-corrected — not located in code)` in Notes until it is confirmed.

That marker is the whole mechanism: the user's judgement wins immediately, and the row's provenance
stays visible instead of being quietly blended in with the rows read from code.

If the user says "save" with no further edits, proceed to Step 9.

---

## Step 9 — Save

Use the canonical structure below — power skill output structure lives in this command file, not in `templates/`. Write the agreed content to **both** of the following files, keeping the header block and "How to add a module" section exactly as shown. Replace only the table rows with the agreed content.

```markdown
# Module Registry

> The authoritative list of product modules for this project.
> Run `/generate-module-registry` to populate this file from your codebase.
> All artefacts must use module names exactly as listed here.
> The agent reads this file before generating any artefact (except BRDs).
>
> **Every row is evidenced in the codebase.** This registry is built from code alone — no BRD,
> spreadsheet, or other document may introduce a module the code does not implement.
>
> The Slug column is the lowercase kebab-case form used as the filename prefix for every
> artefact (PRD, PD, CR, TC, etc.) — e.g. `orders` → `2026-07-29-orders-CR.md`.

---

| Module | Slug | Description | Owner | Notes |
| --- | --- | --- | --- | --- |

---

## How to add a module

Edit this file freely — it is generated from the codebase, but a generated reading can be wrong, and
your correction wins. Add modules that exist in the product and were missed, fix names, and remove
anything misread. If a row cannot be traced to code yet, mark it `(user-corrected — not located in
code)` in Notes so its provenance stays visible.

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
- **Never invent a module name that is not evidenced in the codebase** — never guess to fill a gap.
- **Never let another document introduce a module.** If a BRD, a spreadsheet, or an existing artefact names a module the code does not implement, report the discrepancy — usually a module that was never built or one since removed — and leave it out. This applies to documents, not to the user: a person correcting the registry is always applied (Step 8).
- Where layers of the code disagree, resolve it with architectural judgement (Step 5.7) and say so in the review summary (Step 8) — never silently pick one and hide the conflict.
- Do not lower the bar on exclusion/consolidation discipline (Steps 4–6) because the codebase is the only source. It always was the only source that mattered.
- Today's date comes from the `currentDate` value in memory context, or run `date +%Y-%m-%d` if not available.
