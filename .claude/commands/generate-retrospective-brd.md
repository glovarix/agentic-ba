# /generate-retrospective-brd — Generate a Retrospective BRD from a Codebase

Read a shipped codebase and write a client-facing Business Requirements Document (BRD) describing
who the product is for, why it exists, and what it does — derived entirely from the code that is
actually there. Present it for review, then save to `artefacts/brd/`.

**Usage:** `/generate-retrospective-brd [path]` — the path is optional. With no argument the skill
uses `coderepo/` under the standard codebase priority rule.

**This skill is standalone.** It needs no PRD, no CR, no module registry, and no BRD to already
exist. Every one of those is used when present and skipped without complaint when absent. A repo
path and nothing else is a complete, valid input.

**Do not confuse this with the Retrospective BRD Update (CLAUDE.md Rule 7).** Rule 7 takes an
*existing* BRD and reconciles it against what was built, incrementing its version. This skill
writes a *new* BRD from scratch for a product that was built without one. If the product already
has a BRD covering the same scope, stop and offer Rule 7 instead.

---

## Step 1 — Resolve the codebase

- If the user supplied a path argument, use it directly. If it does not exist or contains no source
  code, say so and stop.
- If no argument was supplied, apply the standard codebase priority rule: read every project
  directory present in `coderepo/`. If `coderepo/` holds more than one project and the user has not
  named which to use, ask before proceeding.
- If `coderepo/` is empty or absent and no path was given, tell the user: "No codebase found. Run
  `/generate-retrospective-brd [path]` with a repo path, or add your project source to `coderepo/`."
  Stop.

Confirm the resolved path back to the user in one line before reading further.

---

## Step 2 — Read the supporting material that already exists (optional, never blocking)

Check for each of these and use whatever is present. Do not generate any of them, and do not ask
the user to. Their absence is normal, not a gap:

| Source | What it gives you |
| --- | --- |
| `artefacts/modules/modules.md` (or `context/modules.md`) | Agreed module names and slugs — use these verbatim rather than re-deriving names |
| The repo's own `README`, `/docs`, or product-facing copy | Stated purpose, audience, and problem — the strongest available evidence for Section 3 |
| Existing BRDs in `artefacts/brd/` | Whether this scope is already covered (see the Rule 7 note above) |
| Existing PRDs in `artefacts/prd/` and PDs in `artefacts/product-docs/` | Module boundaries and role names already agreed with the team |

Re-read the module registry every time; never rely on a copy from earlier in the conversation.

---

## Step 3 — Identify the modules

Derive the module list from the codebase using the same discipline as
`.claude/commands/generate-module-registry.md` — read that file's Steps 4 to 7 and apply them here
rather than inventing a second, looser method:

- Collect candidates from top-level page folders, route groups, navigation labels, named feature
  areas, and settings/admin sections.
- Exclude non-modules: CRUD actions, aggregation screens and dashboards, reports, settings and
  permissions screens, imports/exports, integrations, APIs, standalone AI features, delivery
  channels, and anything infrastructure-level.
- Consolidate duplicates and collapse narrow siblings into their parent.
- Apply the naming standard — Title Case, nouns not verb phrases, reads naturally in a sentence a
  client would say out loud.

If `artefacts/modules/modules.md` exists, use its names and its boundaries as the answer and only
flag genuine differences you find in the code. Do not silently rename a registered module.

**Every module in a retrospective BRD is marked `Existing`** unless the user has told you that some
part is not yet built. If the codebase contains a module behind a feature flag that is off, or an
obviously incomplete area, mark it `Existing` and note the state in the Sanity Check — do not mark
it `New`, which in this template means "being built as part of this piece of work".

---

## Step 4 — Infer the roles and personas

Read the codebase for the real access model, then translate it into business language:

- Role and permission definitions, role enumerations, access-control checks, and any role seed or
  fixture data.
- Sign-up, invitation, and onboarding flows — these reveal who is expected to arrive and how.
- Navigation that is conditional on role — what each role actually sees is a better description of
  their job than the role name alone.
- Any separate client, portal, or app surface aimed at a distinct audience.

Write each role as **who they are and what they are trying to do** — never as a permission list.
"Ward manager — runs a unit day to day and needs to see staffing and incidents at a glance" is
correct. "Has read/write on schedules and read on incidents" is not; that detail belongs in a PRD.

Fold near-duplicate technical roles into one business role where the distinction is not meaningful
to a client, and say in the Sanity Check that you did. Where the code has a role you cannot explain
in business terms from the code alone, list it and mark it `(role name from the codebase — business
description to be confirmed)` rather than inventing a persona for it.

Roles are product-level by default. Only split them per module when a module genuinely serves an
audience that appears nowhere else in the product.

---

## Step 5 — Infer Who, Why, and What

**Who** — Step 4's roles, plus any non-user stakeholder the codebase evidences (a regulator-facing
export, a commissioner report, a finance integration each imply a stakeholder).

**Why** — this is the hardest section to derive from code and the easiest to fabricate. Use, in
order of preference: the repo's own README and product documentation; the domain language of the
data model; the workflows the product automates and what they replace. Write the current situation
and the objectives as what the product demonstrably achieves for its users.

**Never invent a business case, a metric, a target, or a commercial driver.** Where an objective's
success measure is not evidenced anywhere, write `(placeholder — client to confirm)` in the "How we
know it worked" column. A retrospective BRD with honest gaps is useful; one with a plausible
invented business case is worse than none.

**What** — per module, a one-sentence purpose and a flat list of features at capability level.

---

## Step 6 — Write features at capability level, not specification level

This is the rule the skill most easily breaks. For each module, list what a user can *do* and what
they *get* — one line each, no more.

Correct:

- Shift scheduling — build a rota for a period, assign staff to shifts, and publish it to the team.
- Absence recording — record planned and unplanned absence against a staff member, and see it
  reflected on the rota.

Wrong — these belong in a PRD or a CR, not a BRD:

- Field-by-field descriptions of any form or screen.
- Business rules, validation, conditional logic, state machines, or edge cases.
- Acceptance criteria of any kind.
- Table names, field names, route paths, permission strings, component names, framework names, or
  any other code-level detail. Rule 3's "no code references and no developer terminology in the
  artefact body" applies to this artefact in full.

**Test each line before you keep it:** if it needs a second sentence to be understood, or it names
something only a developer would recognise, it is a PRD item — cut it back to the capability, or
drop it. A module with eight honest one-line features is a better BRD section than one with thirty
half-specifications.

---

## Step 7 — Draft the BRD

Use `templates/BRD-Business-Requirements-Document.md` exactly. Fill every section. Where information
genuinely cannot be derived from the codebase, write `To be confirmed with [Role] before [next
phase].` rather than leaving a section blank or inventing content.

**The document must say on its face that it is retrospective (mandatory).** A reader who opens the
file cold must not mistake it for a BRD written before the build — the two carry very different
weight, and the difference decides how much of the document can be trusted without the client
confirming it. Mark it in all four places:

- **Title:** `# Business Requirements Document (BRD) — Retrospective`
- **Header block:** a `> **Type:**` line directly under Status — `Retrospective — written after the product was built, derived from the codebase`
- **Artefact ID:** `{YYYY-MM-DD}-{product-slug}-retrospective-BRD`
- **A callout immediately below the standard template callout,** stating that the document was
  produced by reading the codebase, that every module is therefore marked `Existing`, and that
  Section 3 (Why) is the section the code can least prove — directing the reader to the Sanity
  Check before the document goes in front of a client.

The filename carries the same marker — see Step 10.

Section-specific notes for a retrospective run:

| Section | How to fill it retrospectively |
| --- | --- |
| Scope | In scope = the modules documented here. Out of scope = product areas deliberately excluded from this document, and why. Remove the Descoped subsection — nothing has been descoped on a first retrospective pass. |
| Assumptions | Every inference you made about intent that the code supports but does not prove. Be explicit — this is where a retrospective BRD earns its trust. |
| Constraints | Only business, regulatory, or compliance constraints the codebase clearly evidences. Leave it thin rather than padding it with technical limits. |
| Open Questions | Every "Why" you could not answer from the code. Expect several on a first pass. |
| Linked Documents | One row per module, filled from what exists in `artefacts/prd/` and `artefacts/product-docs/`, or "Not yet written". |
| Revision History | Version 1.0, today's date, summary: "Initial retrospective version, derived from the codebase." |

Apply Rule 3 writing standards throughout: UK English by default (`language` in `preferences.json`),
present tense, active voice, plain language, no emojis, `##` for section headings.

---

## Step 8 — Sanity check

Run the Rule 4 sanity check, adapted for this artefact. A retrospective BRD is derived from the
codebase rather than checked against it afterwards, so the check is about **evidence quality**, not
feasibility. Report it after the draft, never inside it, using the standard markers:

- ✅ Module names verified against `artefacts/modules/modules.md`
- ✅ Roles derived from the codebase's own access model
- ⚠️ Roles folded together, renamed, or given a business description the code only implies
- ⚠️ Modules found in the code but not in the registry, or registered but not found in the code
- ❌ A section that could not be written from evidence and is carrying a placeholder the client must fill
- ℹ️ Areas that look incomplete, unused, or behind a disabled flag, and anything worth confirming

State plainly how much of Section 3 (Why) is evidenced versus inferred. If most of it is inferred,
say so in one sentence — the user needs to know how much of the business case is real before they
put the document in front of a client.

The Rule 4 CLQ offer applies: if the check produces one or more ❌ items, ask whether to draft a
Client Clarification Request.

---

## Step 9 — Present for review

Show the full draft, then the sanity check, then say:

> "This is a retrospective BRD derived from `{path}` — {N} modules, {N} roles. Review it and tell me
> what to change. When you are happy, say **save** and I will write it to
> `artefacts/brd/{YYYY-MM-DD}-{product-slug}-retrospective-BRD.md`."

Accept edits in any form and apply every one before saving.

---

## Step 10 — Save

Respect `confirmBeforeSave` in `preferences.json`. Save to:

```
artefacts/brd/{YYYY-MM-DD}-{product-slug}-retrospective-BRD.md
```

`{product-slug}` is the lowercase kebab-case name of the product or the codebase directory. The
`retrospective` segment is **mandatory** — it is what distinguishes this file from a BRD written
before the build when both sit in the same folder, and it must match the Artefact ID set in Step 7.
Never overwrite an existing file — if one exists, ask whether to replace it or create a new version.

Confirm with a clickable link to the saved file.

**If a new module was found that is not in `artefacts/modules/modules.md`,** apply Rule 9 — propose
the registry addition once the BRD is saved, and wait for confirmation before writing to the
registry.

---

## Notes

- Nothing in this document may be invented. Every module, role, feature, and objective must trace
  back to something in the codebase or in supporting material the user supplied. When there is no
  evidence, use a placeholder and flag it — never fill the gap with a plausible guess.
- The output is client-facing. If a line would confuse someone who has never seen the code, rewrite
  it or remove it.
- This skill does not read or write PRDs, CRs, or PDs. It only reads them in Step 2 as optional
  corroboration for module and role names.
- Today's date comes from the `currentDate` value in memory context, or run `date +%Y-%m-%d` if not
  available.
