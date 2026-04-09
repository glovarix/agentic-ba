# Agentic Business Analysis Framework and Harness

An agentic framework for managing the full SDLC in Markdown. Drop it into any project, point your AI agent at it, and paste in raw client requests — the agent handles the rest.

---

## Where does my code go?

**→ `coderepo/`**

Copy or symlink your project's source code into the `coderepo/` folder. The agent reads it to verify that every artefact uses real module names, field names, and routes — not invented ones.

```text
agentic-ba/
├── coderepo/        ← YOUR PROJECT'S SOURCE CODE GOES HERE
│   └── (your app, API, schema files…)
├── artefacts/       ← generated BRDs, TIPs, test cases, PRDs
├── templates/       ← SDLC artefact templates
├── .github/
│   └── ISSUE_TEMPLATE/   ← bug, change request, AI feature templates
└── CLAUDE.md        ← agent instructions
```

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

## How it works

You provide an unstructured client request — a message, email, Slack note, voice transcript. The agent:

1. Classifies the request (bug / change / AI feature / BRD / TIP / test cases / PRD)
2. Confirms the template with you
3. Generates the artefact using the matching template
4. Verifies all module names, fields, and roles against your code in `coderepo/`
5. Saves to the right folder in `artefacts/`

No forms to fill in. No commands to run. Just paste the request.

---

## Setup

### 1. Clone the repo

```bash
git clone https://github.com/binu-alexander/agentic-ba.git
cd agentic-ba
```

### 2. Add your codebase → `coderepo/`

```bash
cp -r /path/to/your/project coderepo/
```

### 3. Open in your AI agent

Open the folder in Claude Code, Cursor, VS Code + Copilot, or any AI coding tool. The agent reads `CLAUDE.md` automatically.

### 4. Paste a request

```
The care plan submit button is not responding after the user fills in all mandatory fields
```

The agent classifies it, suggests `Bug Report Isssue Template.md`, asks you to confirm, then generates the full artefact.

---

## Templates

### Issue templates (existing)
Used for day-to-day tracking — bugs, change requests, AI features.

| Template | When to use |
| --- | --- |
| `Bug Report Isssue Template.md` | Something is broken |
| `Change Request Issue Template.md` | New or changed behaviour |
| `AI New Feature Issue.md` | AI-powered capability |

### SDLC artefact templates (new)
Used for structured delivery — requirements through to test cases.

| Template | When to use |
| --- | --- |
| `BRD.md` | Business Requirements Document — what to build and why |
| `TIP.md` | Technical Implementation Plan — how to build it |
| `TC.md` | Test cases with numbered steps |
| `PRD.md` | Full Product Requirements Document |

---

## Output folders

| Artefact | Saved to |
| --- | --- |
| BRD | `artefacts/requirements/` |
| TIP | `artefacts/implementation/` |
| Test cases | `artefacts/test-suites/{MODULE}/` |
| PRD | `artefacts/prd/` |
| Bug reports | `artefacts/issues/bugs/` |
| Change requests | `artefacts/issues/changes/` |
| AI features | `artefacts/issues/ai-features/` |

---

## The harness

The harness is two things:

- **Templates** — the canonical structure for every artefact type
- **Codebase verification** — every artefact is checked against `coderepo/` before saving

`CLAUDE.md` wires them together.

---

## Compatibility

Works with Claude Code, Cursor, GitHub Copilot, and any AI tool that reads a `CLAUDE.md` or project instructions file.
