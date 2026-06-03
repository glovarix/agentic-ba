---
title: "Getting Started with Baxter"
---

# Getting Started with Baxter

### Your code + Claude + the agentic-ba framework

**The idea:** agentic-ba (Baxter) is a folder of templates and instructions. Your AI agent reads it, reads *your* code, and writes verified business-analysis artefacts straight into git. There is nothing to install beyond your editor — no accounts, no database, no vendor lock-in.

---

## 1. Set up the easiest agent — VS Code + Claude Code extension

**Recommended for beginners.**

- Install **VS Code** — https://code.visualstudio.com/
- Add the **Claude Code extension** from the marketplace

This gives you a familiar editor with Claude in a side panel — **no terminal required**, which is why it is the best place to start. (It also works with the Claude Code CLI, Cursor, or GitHub Copilot if you prefer.)

---

## 2. Get the harness

Clone or download `agentic-ba` and open the folder in VS Code:

```bash
git clone https://github.com/glovarix/agentic-ba.git
```

Open the Claude Code panel. It automatically reads `CLAUDE.md`, so Baxter is active with zero configuration.

Optional one-time step to keep the instruction files in sync:

```bash
git config core.hooksPath .githooks
```

---

## 3. Add your code

Copy or symlink your project's source into the `coderepo/` folder:

```bash
cp -r /path/to/your/project coderepo/
```

This is the most important step. `coderepo/` is what Baxter reads to **sanity-check** every artefact against reality — real module names, fields, routes, and data model. Everything in `coderepo/` is gitignored, so your code is never committed or pushed.

---

## 4. Build the module registry (recommended)

In the Claude panel, run:

```
/generate-modules
```

Baxter scans your codebase, drafts a table of your product modules, and presents it for review. Edit any rows, then say **save**. From then on, every artefact is verified against those real module names.

---

## 5. Paste a raw request — that is the whole workflow

You never fill in a form or name a template. Just paste what you actually received:

> "The login page returns a 500 when the user submits without a password"

Baxter then:

1. **Classifies** it — "This looks like a Bug Report — confirm? BR / 6 / proceed"
2. **Reads `coderepo/`** and drafts the artefact from the correct template
3. **Sanity-checks** it — feasibility, logic, data model, roles, naming, edge cases, and UX — reporting findings *after* the draft (verified / corrected / blocker)
4. **Asks before saving** to the correct folder (e.g. `artefacts/bugs/`)
5. You review, approve, and commit — your name goes in the revision history

---

## What you can ask for

Plain language triggers each artefact type — no commands needed:

| Artefact | Say something like |
| --- | --- |
| Business Requirements (BRD) | "Write up the BRD for recurring invoices" |
| Product Documentation (PD) | "Document the billing module" |
| Implementation Plan (TIP) | "Write an implementation plan for the bulk import feature" |
| Test Cases (TC) | "Generate test cases for the authentication module" |
| Bug Report (BR) | "The reports page returns a 500 on empty input" |
| Change Request (CR) | "Add a bulk export option to the orders list" |
| AI Feature (AI) | "We need AI to auto-suggest categories from the description" |
| Diagram (DIA) | "Diagram the checkout flow from cart to confirmation" |
| Entity Relationship Diagram (ERD) | "Draw an ERD for the orders and customers tables" |

Plus commands: `/generate-modules`, `/generate-samples`, `/generate-test-plan`, `/compare`.

---

## Two things worth knowing

- **BRDs are the exception.** They are written *before* code exists, so Baxter skips the codebase check for those.
- **Nothing is saved without your sign-off.** Baxter generates, you verify, and git records everything.

---

**One-line version:** Install VS Code + the Claude Code extension → open the `agentic-ba` folder → drop your code into `coderepo/` → paste a raw request → review and approve.

Full guide: https://www.thedatadrivenlife.com/getting-started/
