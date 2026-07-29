# Agentic Business Analysis  Framework

An agentic framework and harness for managing the full SDLC in Markdown. Drop it into any project, point your AI agent at it, and paste in raw client requests — the agent classifies the request, drafts the artefact, and runs multi-dimensional sanity checking against your codebase before you review a single word. Every artefact is saved to git — your single source of truth for requirements, plans, and decisions, version-controlled from day one.

---

## Quick start

1. Clone this repo
2. Add your codebase → `coderepo/` *(optional — only needed for post-dev artefacts)*
3. Open the folder in your AI agent — **VS Code + the Claude Code extension is recommended for beginners** (also works with the Claude Code CLI, Cursor, or GitHub Copilot)
4. Paste a raw request — email, Slack message, voice note, Google Doc excerpt
5. The agent classifies it, confirms the template, generates the artefact, and saves it

No forms. No commands. Just paste.

---

## Two ways to use Baxter

**Templated artefacts** — paste any raw request and Baxter classifies it, drafts it, and sanity-checks it against your codebase. No commands needed.

**Power skills** — slash commands that automate multi-step workflows: scanning codebases, fetching GitHub issues, diffing branches, synthesising documents. You run these explicitly. See [Power skills — slash commands](#power-skills--slash-commands) below.

### Templated artefacts — just paste

| # | Say something like… | Artefact | Acronym |
| --- | --- | --- | --- |
| 0 | "Update the BRD based on what was built" | Retrospective BRD Update | — |
| 1 | "Write up the requirements for…" | Business Requirements Document | BRD |
| 2 | "Consolidate the requirements for the care plans module" | Product Requirements Document | PRD |
| 3 | "Document the care plans module" | Product Documentation | PD |
| 4 | "Write an implementation plan for…" | Technical Implementation Plan | TIP |
| 5 | "I need test cases for…" | Test Cases | TC |
| 6 | "We need an AI feature to…" | AI Feature Spec | AI |
| 7 | "The login page returns 500…" | Bug Report | BR |
| 8 | "Add a print to PDF button to…" | Change Request | CR |
| 9 | "Draw a flowchart for…" / "Diagram the login flow" | Diagram | DIA |
| 10 | Offered automatically when the sanity check finds ❌ blockers | Client Clarification Request | CLQ |
| 11 | "Draw an ERD for the care plans module" | Entity Relationship Diagram | ERD |

Every templated artefact is produced from a template in `templates/` — that is what makes it a core skill.

The agent confirms the artefact type before writing anything. Respond with the number, the acronym, or "proceed".

---

## Power skills — slash commands

These commands go beyond generating a single document. Each one automates a multi-step workflow — fetching data, scanning files, diffing branches, synthesising output — and produces Markdown and PDF artefacts without manual assembly. Power skill outputs may have a defined structure, but that structure lives in the command file in `.claude/commands/` — never in `templates/`.

| Command | You provide | Output |
| --- | --- | --- |
| `/validate-release` | Release notes in `docs/` + two branch snapshots in `coderepo/branches/` + sprint number | `Sprint-{N}-{staging}-vs-{production}.md` + PDF in `artefacts/release-validation/` |
| `/generate-module-registry` | Nothing — just run it (optionally point it at other reference material too) | `artefacts/modules/modules.md` — the module registry Baxter uses to verify all artefacts |
| `/generate-samples` | Nothing — just run it | Up to 3 JSON sample data records in `artefacts/sample-data/` |
| `/generate-test-plan [folder]` | A test suite folder with TC files | `{MODULE}_TEST_PLAN.md` + PDF in the same folder |
| `/generate-release-notes [sprint] [issues]` | Sprint number + GitHub issue numbers | Pre-release notes document + PDF in `docs/Pre-release Sprint {N}/` |
| `/compare-branches` | Two branch folders in `coderepo/branches/` | Technical diff and/or plain-English features summary — Markdown + PDF |
| `/generate-ai-feature-registry` | Nothing — just run it | `artefacts/product-docs/ai-feature-review/ai-features.md` + `context/ai-features.md` |
| `/ai-feature-data-audit [feature name]` | The AI feature name | Presented in the response — saved to `artefacts/product-docs/ai-feature-review/data-audits/` only if you ask |
| `/generate-ai-feature-dependency-map` | Nothing — just run it (or name a feature) | `artefacts/product-docs/ai-feature-review/ai-feature-module-map.csv` |
| `/brainstorm-change [CR name or path]` | A CR in any state — saved, fully drafted but not yet saved, or still being discussed in the current session | A confirmed list of optional, non-blocking follow-on CR ideas — drafted and saved as normal, independent CRs on your confirmation |
| `/visualize-change [CR name, path, or "this"]` | A saved CR (or one being drafted in this session) | A single self-contained, clickable HTML prototype in `artefacts/prototypes/` |

---

### `/generate-module-registry` — Build the module registry from the codebase

Scans `coderepo/` and existing artefacts, identifies named product modules from routes, pages, and navigation, and drafts a module table — one row per module, with the plain-English name and the lowercase kebab-case slug used as its filename prefix in every artefact (`orders`, `billing-history`). Applies real taxonomy discipline while doing it: submodules, CRUD actions, dashboards/screens, settings and permissions, and standalone AI features are all folded into their parent module rather than listed separately. Presents the draft for your review — edit any rows, then say **save**. Writes to `artefacts/modules/modules.md` as a Module Registry (MR).

The agent re-reads this file before generating any artefact, so edits are always picked up.

**Have other reference material?** Point Baxter at additional sources — old notes, a spreadsheet, a prior registry export — and it reconciles them with the codebase into one consolidated table, merging duplicates and renaming for clarity rather than concatenating everything it finds. This is entirely optional; the codebase alone is always a complete, valid source on its own.

---

### `/generate-samples` — Generate sample data from the codebase *(beta)*

Reads `coderepo/` to identify the data model — schema files, migration files, seed data, or in-code data shapes — and generates realistic sample records ready to seed or test your app.

- **Output format:** Always JSON.
- **Record count:** Defaults to 1 record. Say "generate 2" or "generate 3" to request more (maximum 3).
- Every field name, table name, and lookup value is verified against the codebase before saving.
- Records are saved to `artefacts/sample-data/` as `sample-{app-slug}-{NN}-{slug}.json`.

> **Beta:** Sample data generation is still under active development. Output quality depends on the completeness of the codebase in `coderepo/`.

---

### `/generate-test-plan [folder]` — Generate a test plan from a test suite

A Test Case (TC) suite is a prerequisite for a Test Plan (TP), not the other way round — Baxter mentions this option once a test suite is saved, but never runs it automatically. Reads every `*_TC*.md` file in the given test suite folder and synthesises a high-level test plan document — no manual drafting required. All content is derived from the actual test cases.

```bash
/generate-test-plan artefacts/test-suites/SERVICES
# or omit the folder to pick from a list
/generate-test-plan
```

**What it produces:**

- A `{MODULE}_TEST_PLAN.md` file saved alongside the test cases, with 15 structured sections: introduction, objectives, scope, test approach (type breakdown table), environments, data prerequisites, roles under test, area coverage, full TC summary table, entry/exit criteria, risks, execution schedule, defect management, and revision history.
- A matching `{MODULE}_TEST_PLAN.pdf` generated immediately using `npx md-to-pdf` — no separate step required.

**How it works:**

1. Reads every TC file to extract: ID, title, priority, type, linked source, and precondition summary.
2. Infers area groupings, role requirements, data dependencies, and ordering risks from the TC content.
3. Presents the output filename and asks for confirmation before saving (respects `confirmBeforeSave` in `preferences.json`).
4. Checks for an existing `*_TEST_PLAN.md` — if found, offers to update (increment version) rather than overwrite.

---

### `/generate-release-notes [sprint] [issues]` — Generate pre-release notes from GitHub issues

Takes a sprint number and a list of GitHub issue numbers, fetches each issue, groups items by module area, extracts or looks up ClickUp card links, and produces a numbered pre-release notes table ready to share with QA and product leads.

```bash
/generate-release-notes 96 1234 1235 1236 1237
```

**What it produces:**

- A pre-release notes Markdown document saved to `docs/Pre-release Sprint {N}/` (folder is created if it does not exist).
- A matching PDF generated immediately — no separate step required.
- ClickUp cards are populated automatically where URLs are embedded in issue bodies or found via ClickUp search. If ClickUp is not connected, all other steps run normally and ClickUp cells are left blank.

---

### `/compare-branches` — Branch comparison

Place two branch snapshots as folders inside `coderepo/branches/` and run `/compare-branches`. Baxter asks which output you want, performs a deep code-level diff, and produces Markdown files and PDFs:

| Output | Audience | Contents |
| --- | --- | --- |
| `{branch-a}-vs-{branch-b}-diff.md` + `.pdf` | Developers / tech leads | Full technical diff: new files, removed files, and a file-by-file breakdown grouped by functional area |
| `{branch-a}-vs-{branch-b}-usecases.md` + `.pdf` | Product / QA / clinical leads | Plain-English features and use cases: what users can do in each environment, colour-coded status, known-issues section |

```bash
# Put your branch snapshots here
coderepo/branches/
├── my-app-production/    ← production branch export
└── my-app-staging/       ← staging branch export

# Then in Claude Code:
/compare-branches
# Baxter asks: 1 Technical | 2 Non-technical | 3 Both
```

Baxter saves the Markdown source and converts it to PDF using `pandoc` (if installed) or Chrome headless. No HTML files are saved to disk. If there are more than two branch folders, Baxter lists them and asks which two to compare. Files are never overwritten without your confirmation.

---

### `/validate-release` — Release Validation

A critical part of the release process. Point Baxter at your release notes and it compares the staging and production branch snapshots to confirm every release note item is present, identify any undocumented changes going to production, and surface database migrations.

**What you must provide (all three):**
- Release notes — a file in `docs/` (point Baxter at the path)
- Two branch snapshots — placed in `coderepo/branches/` as two folders before running (e.g. `my-app-staging/` and `my-app-production/`)
- Sprint number — required for the output filename

**What it produces:**

| Section | Contents |
| --- | --- |
| In the release notes — confirmed on staging | Each item confirmed present in staging, with GitHub issue numbers and evidence |
| NOT in the release notes — also going to production | Product-facing undocumented changes (visible to users/admins) and infrastructure changes |
| In production but removed or replaced | Items in production that staging has dropped or superseded |
| Database migrations in staging only | All DB migrations not yet applied to production |

Output is saved to `artefacts/release-validation/` as `Sprint-{N}-{staging}-vs-{production}.md` + `.pdf`. The sprint number is always part of the filename. User-provided release notes stay in `docs/` untouched.

---

### `/brainstorm-change [CR name or path]` — Second-opinion sweep on a CR

Pressure-test a Change Request in any state — still being discussed, fully drafted but not yet saved, or already saved — for the moments you're not fully sure it's complete, or want a deeper pass before it goes into a sprint.

```bash
/brainstorm-change 2026-07-22-duplicate-staff-leave-validation-CR
# or run it with no argument on a CR still live in the current conversation
```

**What it does:**

- Reads the CR plus the relevant code in `coderepo/` — the same depth as a full sanity check.
- Sweeps four angles: ripple effects in other modules, the same class of mistake recurring elsewhere in the app, alternative implementations already used nearby, and UX ideas grounded in existing patterns.
- Works through findings one at a time, proposing a recommended handling for each — you react, then it moves to the next.
- Anything you flag becomes a candidate for its own CR. Confirmed candidates are drafted and saved through the standard CR mechanism, as independent files — never merged into or bundled with the original CR.

**Not a second sanity check.** Catching blockers is the sanity check's job — already done for a saved or fully drafted CR. `/brainstorm-change` only surfaces optional, non-blocking ideas that are genuinely fine to pick up later.

---

### `/visualize-change [CR name, path, or "this"]` — Interactive CR prototype

Turns a Change Request into a single, self-contained, clickable HTML prototype that demonstrates its functionality, features, and logic — not a visual design deliverable.

```bash
/visualize-change 2026-07-22-duplicate-staff-leave-validation-CR
# or "this" for the CR being drafted in the current conversation
```

**What it does:**

- Only ever prototypes a real CR — saved, or actively being drafted in the current session. It is not a general "mock me up an idea" tool.
- Reads the CR (and every sub-CR, for a group folder) plus the real screens, terminology, and data shapes it touches in `coderepo/`, so the prototype is a faithful extension of the existing product — never a blue-sky mockup.
- Demonstrates every In Scope checklist item and every Acceptance Criterion as a triggerable interactive state, with new-in-this-CR states visually distinguished from the existing baseline.
- Ships as one HTML file with all libraries loaded via CDN — no build step, no separate assets.

**What it produces:** `artefacts/prototypes/{YYYY-MM-DD}-{feature-slug}-prototype.html` (or a `{feature-slug}/` subfolder for a group folder with several related prototypes). No PDF — the HTML file is the only deliverable.

---

## AI Feature Review

Three power skills together document the AI feature set at a level of detail beyond a single PD artefact — run them in order for the fullest picture. Output lives under `artefacts/product-docs/ai-feature-review/` — distinct from `artefacts/ai-feature-requests/`, which is where new AI Feature Spec artefacts are saved.

### `/generate-ai-feature-registry` — Every AI feature in the product

Scans `packages/api/src/routers/ai/` (and `helpers/`), the AI task files, and any AI Features admin settings screen. Drafts a registry — name, description, trigger type, code location, feature flag, status — and presents it for review before saving.

**What it produces:** `artefacts/product-docs/ai-feature-review/ai-features.md` + `context/ai-features.md` (identical copies).

### `/ai-feature-data-audit [feature name]` — What data feeds one AI feature

Traces every table, field, filter, and external input that feeds a given AI feature, then writes a plain-English explanation, trigger/dependency notes, and a QA testing guide.

```bash
/ai-feature-data-audit Care Plan Summary
```

**What it produces:** Presented in the response. Saved to `artefacts/product-docs/ai-feature-review/data-audits/{feature-slug}-ai-data-audit.md` only if you ask.

### `/generate-ai-feature-dependency-map` — Which modules each AI feature depends on

Reads the AI feature registry and the module registry, traces each feature's data back to the modules it depends on, and notes downstream impact if a dependency is disabled.

**What it produces:** `artefacts/product-docs/ai-feature-review/ai-feature-module-map.csv`.

---

## Duplicate check for Change Requests

Before drafting a new CR, Baxter searches `artefacts/change-requests/` in full — including group folders, `Archive/`, `BA-backlog/`, and `UnSorted/` — for a CR that already covers the same request. It matches first on the source link (a ClickUp or GitHub URL already saved in an existing CR's `Source Request URL` field), then on topic. This is a local file search only — no ClickUp or GitHub API calls are made to perform it.

If a match is found, Baxter reports the existing CR (and its sub-CRs, if any) instead of drafting a duplicate. If the new request adds scope the existing CR doesn't cover, it flags the difference and asks whether to update the existing CR instead of creating a new one.

---

## Backlog folder

`artefacts/change-requests/BA-backlog/` is a standing, unstructured holding area for change-request work that isn't finished yet — a plain list of candidate CRs to draft later, or a CR that's been drafted but not yet finalised with you or pushed to GitHub. Baxter always searches it as part of the duplicate check above. Once a CR is finalised and, where applicable, pushed, it moves out into its normal location — nothing finished stays parked in the backlog. A small internal utility command, `/file-for-later`, files things here directly — ask Baxter about it if you want to use it explicitly.

---

## Module and submodule tracking (CR and BR)

Every Change Request and Bug Report includes a `Module(s)` and `Submodule(s)` field, populated from `artefacts/modules/modules.md`. `Module(s)` lists the primary module(s) the request affects; `Submodule(s)` lists the specific feature area(s) within them, plus any additional module(s) Baxter judges are likely impacted as a dependency — marked `(suggested — dependency)` so they read as a suggestion, not confirmed scope.

If the request introduces a module that genuinely doesn't exist in the registry yet, Baxter marks it `(new module)` directly in the field, then offers to add it to `artefacts/modules/modules.md` once the artefact is finalised. If the registry itself is missing, Baxter stops and asks you to run `/generate-module-registry` or type the module(s) in manually rather than guessing.

**Title prefix.** Every CR and BR title is prefixed with its primary module name in square brackets — `[Care Plans] Print to PDF button on patient profile` — using the same module that populates the `Module(s)` field above.

---

## Grouped issues

When a request spans more than one distinct concern, Baxter splits it into a **group folder** — a master CR and one sub-CR per concern, all stored together.

```text
artefacts/change-requests/my-feature/
  2026-05-20-my-feature-CR.md                    ← master (lists sub-CRs)
  2026-05-20-my-feature-cr01-first-change-CR.md  ← CR-01
  2026-05-20-my-feature-cr02-second-change-CR.md ← CR-02
  2026-05-20-my-feature-BRD.md                   ← supporting BRD (optional)
```

The `cr{NN}` number in each sub-CR filename matches the checklist in the master. Supporting artefacts (BRD, TIP, DIA) for the group go in the same folder.

Baxter presents the proposed split before writing anything — reply with the number, the acronym, or "proceed".

---

## What each artefact needs

| # | Artefact | You must provide | Agent looks up | Sanity checked? |
| --- | --- | --- | --- | --- |
| 0 | Retrospective BRD Update | Name of the BRD to update + description of what was actually built (or point to the TIP/PD) | Existing BRD, linked TIP(s), PD, codebase | Yes — feasibility and logic |
| 1 | BRD | Raw text: problem description, goals, users — email, Slack, Google Doc, voice note | Nothing — written before the codebase exists | No |
| 2 | PRD | The module (or named group of modules) to consolidate requirements for | Every CR touching that module (joined together), any linked BRD, codebase to fill gaps no CR ever covered | Yes |
| 3 | PD | Module or product area to document | Codebase — how the module is actually implemented, after its CRs are built, `artefacts/modules/modules.md`, linked BRDs and TIPs | Yes |
| 4 | TIP | Linked BRD (or paste its contents) | Codebase, `artefacts/modules/modules.md`, linked BRD | Yes — includes feasibility and data model |
| 5 | TC | Linked BRD or feature name | PRD + PD for the feature's module — both generated automatically first if either is missing | Yes |
| 6 | AI | Description of the AI capability | Linked BRD, codebase | Yes |
| 7 | BR | What happened, what you expected, how to reproduce | Codebase, `artefacts/modules/modules.md` | Yes — confirms it's a genuine bug |
| 8 | CR | Description of what to add or change | Codebase, `artefacts/modules/modules.md`, linked BRDs | Yes — checks feasibility and conflicts |
| 9 | DIA | Description of the flow or system to diagram + linked CR or BRD | Linked artefact, codebase, `artefacts/modules/modules.md` | Yes — checks flows and states match the real codebase |
| 10 | CLQ | Generated from sanity check ❌ findings — no additional input needed | The artefact that triggered it | No — this is the output of the sanity check |
| 11 | ERD | Description of which tables to include + linked BRD, CR, or TIP | Codebase schema, `artefacts/modules/modules.md` | Yes — verifies table names, columns, and relationships |

The sanity check is a full artefact verification — not name-checking. It covers seven dimensions:

1. **Names** — module names, field names, role names, route paths. Corrected against the codebase and `artefacts/modules/modules.md`.
2. **Technical feasibility** — can it actually be built given the current codebase, data model, and architecture?
3. **Logic consistency** — do requirements contradict each other or contradict existing functionality?
4. **Data model** — are new fields, tables, or relationships consistent with the existing schema? Missing migrations flagged.
5. **Roles & permissions** — are role-based rules consistent with how they are actually implemented?
6. **Gaps & edge cases** — missing scenarios that would cause problems in development or testing.
7. **UX challenges** — potential design and front-end issues flagged for the design team.

Does not apply to initial BRDs (written before the codebase exists). A PRD gets the full sanity check like any other post-development artefact.

---

## Folder structure

```text
agentic-ba/
├── coderepo/                    ← your project's source code (optional, gitignored)
├── context/                     ← free-form reference files (glossary, notes, modules.md copy)
├── templates/                   ← core skill templates, named {ACRONYM}-{Full-Form}.md (BR-Bug-Report, CR-Change-Request, AI-Feature-Spec, BRD-Business-Requirements-Document, PRD-Product-Requirements-Document, PD-Product-Documentation, TIP-Technical-Implementation-Plan, TC-Test-Cases, DIA-Diagram, ERD-Entity-Relationship-Diagram, CLQ-Client-Clarification-Request — flat)
├── artefacts/
│   ├── bug-reports/             ← BRs
│   ├── change-requests/         ← CRs (grouped issues nest in a subfolder here)
│   ├── ai-feature-requests/     ← AI specs
│   ├── requirements/            ← BRDs and PRDs
│   ├── product-docs/            ← PDs
│   ├── implementation-plans/    ← TIPs
│   ├── test-suites/{MODULE}/    ← test cases + {MODULE}_TEST_PLAN.md/.pdf
│   ├── diagrams/                ← DIAs and ERDs
│   ├── client-clarifications/   ← CLQs (client clarification requests)
│   ├── release-validation/      ← RVs — Sprint-{N}-staging-vs-production.md/.pdf
│   ├── modules/                 ← module registry (MR) — generated by /generate-module-registry
│   ├── sample-data/             ← sample data records — generated by /generate-samples (beta)
│   └── prototypes/              ← interactive CR prototypes — generated by /visualize-change
├── CLAUDE.md                    ← agent instructions
└── README.md
```

---

## Adding your codebase (optional)

Only needed for post-development artefacts (TIP, TC, PD, PRD, BR, CR, AI). Not required for BRDs.

```bash
# Option A — copy your project in
cp -r /path/to/your/project coderepo/

# Option B — symlink (keeps one copy on disk)
ln -s /path/to/your/project coderepo/src

# Option C — clone a sub-repo into it
git clone https://github.com/your-org/your-project coderepo/
```

`coderepo/` is gitignored — your source code stays private. So is `artefacts/` — every BRD, CR, TC, sample data file, or other generated output stays on your machine and is never committed to git, regardless of filename.

---

## Context files

The `context/` folder is free-form — drop in whatever project-specific reference files your team needs. It ships empty. The agent does not read it automatically; reference the files by name in your request if you need the agent to use them.

## Module registry

Run `/generate-module-registry` to build a module registry (MR) from your codebase. It scans routes, pages, and navigation to produce a named module table, presents it for your review, and saves it to `artefacts/modules/modules.md` on confirmation.

Once saved, the agent reads `artefacts/modules/modules.md` before every artefact to verify module names. If the file does not exist, the agent will still work — it will flag any module names it could not verify.

## Sample data generation *(beta)*

Run `/generate-samples` to generate realistic sample data records from your connected codebase. The agent reads `coderepo/`, derives the data model, and produces ready-to-use records in `artefacts/sample-data/`.

Output is always JSON.

> Sample data generation is a beta feature. Results depend on the structure and completeness of your codebase in `coderepo/`.

---

## Client clarification requests

When the sanity check finds ❌ blockers — requirements that contradict the codebase, depend on functionality that does not exist, or contain logical conflicts — Baxter offers to draft a **Client Clarification Request (CLQ)**:

> "The sanity check found 2 blocker(s). Would you like me to draft a Client Clarification Request (CLQ) to send to the client?"

A CLQ is a plain-language email to the client with one section per blocker: context explaining the issue, and one precise question that must be answered before development can begin. It is saved to `artefacts/client-clarifications/`.

The CLQ is always opt-in — Baxter asks, never generates automatically.

---

## Product Requirements Documents (PRD) — consolidating a module's CRs

**PRD is a before-code artefact, like a BRD — just module-scoped instead of whole-product-scoped.** A BRD is written before code exists, from a raw client request. A PRD consolidates *requirements* — what should happen, sourced from CRs — not from reading what the code currently does. A PD is the mirror image: an after-code artefact documenting how a module is *actually implemented*, once those CRs are built.

**PRD = requirements, before implementation. PD = documentation, after implementation.**

**Audience is the fastest way to tell BRD and PRD apart.** A BRD is how you deal with clients and leadership — the business case, in language they sign off on, before any code exists. A PRD is team-facing: the team's consolidated, module-level requirements picture, assembled from CRs already written against the codebase. Going in front of a client or leadership for buy-in → BRD. Grounding TC generation or giving the team a current picture of one module → PRD. A BRD's scope (whole product, or several modules) is also what tells you which module(s) will eventually need their own PRD — once a module inside that scope starts accumulating CRs, that's the signal to generate one.

**A PRD's own sanity check does not re-verify each source CR — only the join.** Every CR joined into a PRD already passed its own sanity check when it was drafted. Consolidating them checks something different: module/field names across the whole set, contradictions or supersessions between CRs joined together (an older CR's behaviour overridden by a newer one), and gaps the joined set leaves open — not each CR's individual feasibility all over again.

CRs are the day-to-day, one-at-a-time asks. Once you're done adding Change Requests for a module for now, ask Baxter to consolidate them:

> "Consolidate the requirements for the Care Plans module."

Baxter joins every CR that has touched that module into one consolidated requirements document, and fills in any existing behaviour that no CR ever formally covered — so the PRD reflects the whole module, not just its CR-shaped pieces. (Baxter does check the codebase for that gap-filling step, but only to catch existing behaviour no CR ever wrote down — the PRD itself stays a requirements document, not an implementation record.) It sits between a BRD (whole product, or one or more modules, written before code exists) and a PD (documents the module from code, after its CRs are built):

**BRD → CR → PRD → PD → TC**

**PRDs are an internal working artefact only — never pushed to GitHub.** Unlike a CR, there is no Source URL field and no GitHub issue equivalent. They exist to keep a module's requirements consolidated and to ground Test Case generation.

**Test Cases always need both a PRD and a PD.** When you ask for test cases for a feature, Baxter checks whether both already exist for that module — generating whichever is missing automatically first, so TCs are never built from a mismatched pairing of one formal artefact and a raw codebase guess. Where the PRD (what should happen) and the PD (what currently happens) disagree on a requirement, Baxter never silently picks a side — it generates two distinct test cases: one asserting the PRD's required behaviour, and one asserting the PD's actual behaviour, with the latter flagged as a possible defect.

**PD never reads PRD as an input, even though both exist for the same module.** PD stays strictly codebase-derived — it describes the module exactly as implemented, so any drift from what was requested stays visible rather than getting smoothed over. The only connection is a cross-reference: PD's Linked Artefacts table gets a row pointing at the module's PRD, added for navigation once the document is otherwise finished — never used to decide what PD says.

---

## Retrospective BRD updates

BRDs are written before development. Once a feature ships, you can ask the agent to update the BRD to reflect what was actually built:

> "Update the BRD for care plan cloning based on what was built."

The agent will read the original BRD, compare it against the TIP and any description you provide, update changed requirements, move descoped items, and save a new version — leaving the original intact unless you confirm the overwrite.

---

## Compatibility

**New to this? Use VS Code + the Claude Code extension** — install [VS Code](https://code.visualstudio.com/), add the Claude Code extension from the marketplace, open the `agentic-ba` folder, and work with Baxter in a side panel. No terminal required. It's the easiest way to start.

Baxter also works out of the box with the Claude Code CLI, Cursor, and GitHub Copilot. Each tool picks up its own instruction file automatically — no configuration needed.

| Tool | Instruction file loaded automatically |
| --- | --- |
| VS Code + Claude Code extension (recommended) | `CLAUDE.md` |
| Claude Code (CLI) | `CLAUDE.md` |
| Cursor | `.cursor/rules/baxter.mdc` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Any agent following the [agents.md](https://agents.md) standard | `AGENTS.md` |

The instruction files are identical and kept in sync via a pre-commit hook. If you edit `CLAUDE.md`, the others update automatically on your next commit.

**One-time setup after cloning** (activates the sync hook):

```bash
git config core.hooksPath .githooks
```
