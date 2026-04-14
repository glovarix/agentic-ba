# Agentic Business Analysis Harness Framework (ABAHF)

An agentic framework and harness for managing the full SDLC in Markdown. Drop it into any project, point your AI agent at it, and paste in raw client requests — the agent classifies the request, drafts the artefact, and runs multi-dimensional sanity checking against your codebase before you review a single word. Every artefact is saved to git — your single source of truth for requirements, plans, and decisions, version-controlled from day one.

---

## Quick start

1. Clone this repo
2. Add your codebase → `coderepo/` *(optional — only needed for post-dev artefacts)*
3. Open the folder in Claude Code, Cursor, or any AI tool that reads `CLAUDE.md`
4. Paste a raw request — email, Slack message, voice note, Google Doc excerpt
5. The agent classifies it, confirms the template, generates the artefact, and saves it

No forms. No commands. Just paste.

---

## What can the agent generate?

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

The agent confirms the artefact type before writing anything. Respond with the number, the acronym, or "proceed".

---

## What each artefact needs

| # | Artefact | You must provide | Agent looks up | Sanity checked? |
| --- | --- | --- | --- | --- |
| 0 | Retrospective BRD Update | Name of the BRD to update + description of what was actually built (or point to the TIP/PD) | Existing BRD, linked TIP(s), PD, codebase | Yes — feasibility and logic |
| 1 | BRD | Raw text: problem description, goals, users — email, Slack, Google Doc, voice note | Nothing — written before the codebase exists | No |
| 2 | PD | Module or product area to document | Codebase, `context/modules.md`, linked BRDs and TIPs | Yes |
| 3 | TIP | Linked BRD (or paste its contents) | Codebase, `context/modules.md`, linked BRD | Yes — includes feasibility and data model |
| 4 | TC | Linked BRD or feature name | Linked BRD (FRs and ACs), codebase, `context/modules.md` | Yes |
| 5 | AI | Description of the AI capability | Linked BRD, codebase | Yes |
| 6 | BR | What happened, what you expected, how to reproduce | Codebase, `context/modules.md` | Yes — confirms it's a genuine bug |
| 7 | CR | Description of what to add or change | Codebase, `context/modules.md`, linked BRDs | Yes — checks feasibility and conflicts |
| 8 | DIA | Description of the flow or system to diagram + linked CR or BRD | Linked artefact, codebase, `context/modules.md` | Yes — checks flows and states match the real codebase |
| 9 | CLQ | Generated from sanity check ❌ findings — no additional input needed | The artefact that triggered it | No — this is the output of the sanity check |

The sanity check is a full artefact verification — not name-checking. It covers seven dimensions:

1. **Names** — module names, field names, role names, route paths. Corrected against the codebase and `context/modules.md`.
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
├── context/
│   ├── glossary.md              ← domain terms used across artefacts
│   └── modules.md               ← list of product modules for verification
├── templates/
│   ├── issues/                  ← BR, CR, AI
│   └── other/                   ← BRD, PD, TIP, TC, DIA, CLQ
├── artefacts/
│   ├── clarifications/          ← CLQs (client clarification requests)
│   ├── issues/
│   │   ├── bugs/                ← BRs
│   │   ├── changes/             ← CRs
│   │   └── ai-features/         ← AI specs
│   └── other/
│       ├── requirements/        ← BRDs
│       ├── product-docs/        ← PDs
│       ├── implementation/      ← TIPs
│       ├── test-suites/{MODULE}/← test cases
│       └── diagrams/            ← DIAs
├── CLAUDE.md                    ← agent instructions
└── README.md
```

---

## Sample artefacts

The `artefacts/` folder includes a set of sample artefacts generated for a **fictional Todo App** — they are not from a real project. They exist purely to show what Baxter produces before you write your first request.

| Sample artefact | Type | Location |
| --- | --- | --- |
| `sample-2026-04-10-todo-app-PD.md` | PD | `artefacts/other/product-docs/` |
| `sample-2026-04-10-due-date-reminders-BRD.md` | BRD | `artefacts/other/requirements/` |
| `sample-2026-04-10-due-date-reminders-TIP.md` | TIP | `artefacts/other/implementation/` |
| `sample-Auth_TC01–05_*.md` | TC | `artefacts/other/test-suites/Authentication/` |
| `sample-Tags_TC01–02_*.md` | TC | `artefacts/other/test-suites/Tags/` |
| `sample-Todos_TC01–06_*.md` | TC | `artefacts/other/test-suites/Todos/` |
| `sample-2026-04-10-duplicate-tag-returns-500-BR.md` | BR | `artefacts/issues/bugs/` |
| `sample-2026-04-10-bulk-delete-todos-CR.md` | CR | `artefacts/issues/changes/` |
| `sample-2026-04-10-auto-suggest-tags-AI.md` | AI | `artefacts/issues/ai-features/` |
| `sample-2026-04-10-todo-creation-flow-DIA.md` | DIA | `artefacts/other/diagrams/` |

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

`coderepo/` is gitignored — your source code stays private.

---

## Adding modules

Edit `context/modules.md` to list your product's modules. The agent uses this to verify module names and terminology in every artefact (except BRDs).

---

## Client clarification requests

When the sanity check finds ❌ blockers — requirements that contradict the codebase, depend on functionality that does not exist, or contain logical conflicts — Baxter offers to draft a **Client Clarification Request (CLQ)**:

> "The sanity check found 2 blocker(s). Would you like me to draft a Client Clarification Request (CLQ) to send to the client?"

A CLQ is a plain-language email to the client with one section per blocker: context explaining the issue, and one precise question that must be answered before development can begin. It is saved to `artefacts/clarifications/`.

The CLQ is always opt-in — Baxter asks, never generates automatically.

---

## Retrospective BRD updates

BRDs are written before development. Once a feature ships, you can ask the agent to update the BRD to reflect what was actually built:

> "Update the BRD for care plan cloning based on what was built."

The agent will read the original BRD, compare it against the TIP and any description you provide, update changed requirements, move descoped items, and save a new version — leaving the original intact unless you confirm the overwrite.

---

## Compatibility

Baxter works out of the box with Claude Code, Cursor, and GitHub Copilot. Each tool picks up its own instruction file automatically — no configuration needed.

| Tool | Instruction file loaded automatically |
| --- | --- |
| Claude Code | `CLAUDE.md` |
| Cursor | `.cursor/rules/baxter.mdc` |
| GitHub Copilot | `.github/copilot-instructions.md` |

All three files are identical and kept in sync via a pre-commit hook. If you edit `CLAUDE.md`, the other two update automatically on your next commit.

**One-time setup after cloning** (activates the sync hook):

```bash
git config core.hooksPath .githooks
```
