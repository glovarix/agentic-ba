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

**Power tools** — slash commands that automate multi-step workflows: scanning codebases, fetching GitHub issues, diffing branches, synthesising documents. You run these explicitly. See [Power tools — slash commands](#power-tools--slash-commands) below.

### Templated artefacts — just paste

| # | Say something like… | Artefact | Acronym |
| --- | --- | --- | --- |
| 0 | "Update the BRD based on what was built" | Retrospective BRD Update | — |
| 1 | "Write up the requirements for…" | Business Requirements Document | BRD |
| 2 | "Document the care plans module" | Product Documentation | PD |
| 3 | "Write an implementation plan for…" | Technical Implementation Plan | TIP |
| 4 | "I need test cases for…" | Test Cases | TC |
| 5 | "We need an AI feature to…" | AI Feature Spec | AI |
| 6 | "The login page returns 500…" | Bug Report | BR |
| 7 | "Add a print to PDF button to…" | Change Request | CR |
| 8 | "Draw a flowchart for…" / "Diagram the login flow" | Diagram | DIA |
| 9 | Offered automatically when the sanity check finds ❌ blockers | Client Clarification Request | CLQ |
| 10 | "Draw an ERD for the care plans module" | Entity Relationship Diagram | ERD |

Every templated artefact is produced from a template in `templates/` — that is what makes it a core skill.

The agent confirms the artefact type before writing anything. Respond with the number, the acronym, or "proceed".

---

## Power tools — slash commands

These commands go beyond generating a single document. Each one automates a multi-step workflow — fetching data, scanning files, diffing branches, synthesising output — and produces Markdown and PDF artefacts without manual assembly. Power tool outputs may have a defined structure, but that structure lives in the command file in `.claude/commands/` — never in `templates/`.

| Command | You provide | Output |
| --- | --- | --- |
| `/validate-release` | Release notes in `docs/` + two branch snapshots in `coderepo/branches/` + sprint number | `Sprint-{N}-{staging}-vs-{production}.md` + PDF in `artefacts/release-validation/` |
| `/generate-module-registry` | Nothing — just run it | `artefacts/modules/modules.md` — the module registry Baxter uses to verify all artefacts |
| `/generate-samples` | Nothing — just run it | Up to 3 JSON sample data records in `artefacts/sample-data/` |
| `/generate-test-plan [folder]` | A test suite folder with TC files | `{MODULE}_TEST_PLAN.md` + PDF in the same folder |
| `/generate-release-notes [sprint] [issues]` | Sprint number + GitHub issue numbers | Pre-release notes document + PDF in `docs/Pre-release Sprint {N}/` |
| `/compare-branches` | Two branch folders in `coderepo/branches/` | Technical diff and/or plain-English features summary — Markdown + PDF |
| `/generate-ai-feature-registry` | Nothing — just run it | `artefacts/product-docs/ai-feature-review/ai-features.md` + `context/ai-features.md` |
| `/ai-feature-data-audit [feature name]` | The AI feature name | Presented in the response — saved to `artefacts/product-docs/ai-feature-review/data-audits/` only if you ask |
| `/generate-ai-feature-dependency-map` | Nothing — just run it (or name a feature) | `artefacts/product-docs/ai-feature-review/ai-feature-module-map.csv` |

---

### `/generate-module-registry` — Build the module registry from the codebase

Scans `coderepo/` and existing artefacts, identifies named product modules from routes, pages, and navigation, and drafts a module table. Presents the draft for your review — edit any rows, then say **save**. Writes to `artefacts/modules/modules.md` as a Module Registry (MR).

The agent re-reads this file before generating any artefact, so edits are always picked up.

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

Reads every `*_TC*.md` file in the given test suite folder and synthesises a high-level test plan document — no manual drafting required. All content is derived from the actual test cases.

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

## AI Feature Review

Three power tools together document the AI feature set at a level of detail beyond a single PD artefact — run them in order for the fullest picture. Output lives under `artefacts/product-docs/ai-feature-review/` — distinct from `artefacts/ai-feature-requests/`, which is where new AI Feature Spec artefacts are saved.

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
| 2 | PD | Module or product area to document | Codebase, `artefacts/modules/modules.md`, linked BRDs and TIPs | Yes |
| 3 | TIP | Linked BRD (or paste its contents) | Codebase, `artefacts/modules/modules.md`, linked BRD | Yes — includes feasibility and data model |
| 4 | TC | Linked BRD or feature name | Linked BRD (FRs and ACs), codebase, `artefacts/modules/modules.md` | Yes |
| 5 | AI | Description of the AI capability | Linked BRD, codebase | Yes |
| 6 | BR | What happened, what you expected, how to reproduce | Codebase, `artefacts/modules/modules.md` | Yes — confirms it's a genuine bug |
| 7 | CR | Description of what to add or change | Codebase, `artefacts/modules/modules.md`, linked BRDs | Yes — checks feasibility and conflicts |
| 8 | ERD | Description of which tables to include + linked BRD, CR, or TIP | Codebase schema, `artefacts/modules/modules.md` | Yes — verifies table names, columns, and relationships |
| 9 | DIA | Description of the flow or system to diagram + linked CR or BRD | Linked artefact, codebase, `artefacts/modules/modules.md` | Yes — checks flows and states match the real codebase |
| 10 | CLQ | Generated from sanity check ❌ findings — no additional input needed | The artefact that triggered it | No — this is the output of the sanity check |

The sanity check is a full artefact verification — not name-checking. It covers seven dimensions:

1. **Names** — module names, field names, role names, route paths. Corrected against the codebase and `artefacts/modules/modules.md`.
2. **Technical feasibility** — can it actually be built given the current codebase, data model, and architecture?
3. **Logic consistency** — do requirements contradict each other or contradict existing functionality?
4. **Data model** — are new fields, tables, or relationships consistent with the existing schema? Missing migrations flagged.
5. **Roles & permissions** — are role-based rules consistent with how they are actually implemented?
6. **Gaps & edge cases** — missing scenarios that would cause problems in development or testing.
7. **UX challenges** — potential design and front-end issues flagged for the design team.

Does not apply to initial BRDs (written before the codebase exists).

---

## Folder structure

```text
agentic-ba/
├── coderepo/                    ← your project's source code (optional, gitignored)
├── context/                     ← free-form reference files (glossary, notes, modules.md copy)
├── templates/                   ← core skill templates, named {ACRONYM}-{Full-Form}.md (BR-Bug-Report, CR-Change-Request, AI-Feature-Spec, BRD-Business-Requirements-Document, PD-Product-Documentation, TIP-Technical-Implementation-Plan, TC-Test-Cases, DIA-Diagram, ERD-Entity-Relationship-Diagram, CLQ-Client-Clarification-Request — flat)
├── artefacts/
│   ├── bug-reports/             ← BRs
│   ├── change-requests/         ← CRs (grouped issues nest in a subfolder here)
│   ├── ai-feature-requests/     ← AI specs
│   ├── requirements/            ← BRDs
│   ├── product-docs/            ← PDs
│   ├── implementation-plans/    ← TIPs
│   ├── test-suites/{MODULE}/    ← test cases + {MODULE}_TEST_PLAN.md/.pdf
│   ├── diagrams/                ← DIAs and ERDs
│   ├── client-clarifications/   ← CLQs (client clarification requests)
│   ├── release-validation/      ← RVs — Sprint-{N}-staging-vs-production.md/.pdf
│   ├── modules/                 ← module registry (MR) — generated by /generate-module-registry
│   └── sample-data/             ← sample data records — generated by /generate-samples (beta)
├── CLAUDE.md                    ← agent instructions
└── README.md
```

---

## Adding your codebase (optional)

Only needed for post-development artefacts (TIP, TC, PD, BR, CR, AI). Not required for BRDs.

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
