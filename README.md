# Agentic Business Analysis Framework & Harness

An agentic framework for managing the full SDLC in Markdown. Drop it into any project, point your AI agent at it, and paste in raw client requests — the agent handles the rest.

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

The sanity check is a full review — not just spellings and field names. The agent checks technical feasibility, logic consistency, data model implications, role and permission logic, and flags missing edge cases.

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
│   └── other/                   ← BRD, PRD, PD, TIP, TC, DIA
├── artefacts/
│   ├── issues/
│   │   ├── bugs/                ← BRs
│   │   ├── changes/             ← CRs
│   │   └── ai-features/         ← AI specs
│   └── other/
│       ├── requirements/        ← BRDs
│       ├── product-docs/        ← PDs
│       ├── prd/                 ← PRDs
│       ├── implementation/      ← TIPs
│       ├── test-suites/{MODULE}/← test cases
│       └── diagrams/            ← DIAs
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

`coderepo/` is gitignored — your source code stays private.

---

## Adding modules

Edit `context/modules.md` to list your product's modules. The agent uses this to verify module names and terminology in every artefact (except BRDs).

---

## Retrospective BRD updates

BRDs are written before development. Once a feature ships, you can ask the agent to update the BRD to reflect what was actually built:

> "Update the BRD for care plan cloning based on what was built."

The agent will read the original BRD, compare it against the TIP and any description you provide, update changed requirements, move descoped items, and save a new version — leaving the original intact unless you confirm the overwrite.

---

## Compatibility

Works with Claude Code, Cursor, GitHub Copilot, and any AI tool that reads a `CLAUDE.md` or project instructions file.
