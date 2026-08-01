---
title: "An Introduction to the Agentic BA"
---

# An Introduction to the Agentic BA

### Turn raw client messages into verified, version-controlled business-analysis artefacts.

The Agentic BA (also called **Baxter**) is not an app you log into. It is a folder of templates and instructions that your AI coding agent reads. You point the agent at it, paste in a raw request — an email, a Slack snippet, a voice note — and the agent classifies the request, drafts the right artefact, checks it against your real codebase, and saves it to git. There is nothing to install beyond your editor: no accounts, no database, no vendor lock-in.

**Who it is for:** business analysts, product managers, tech leads, and QA engineers who want consistent requirements, plans, test cases, and documentation without writing them from a blank page each time.

**What you get:** Business Requirements Documents (BRD), Product Requirements Documents (PRD), Product Documentation (PD), Technical Implementation Plans (TIP), Test Cases (TC), Bug Reports (BR), Change Requests (CR), AI Feature Specs (AI), Diagrams (DIA), Entity Relationship Diagrams (ERD), and Client Clarification Requests (CLQ) — each from a proven template, each grounded in your actual product.

---

## Getting started in six steps

**1. Download the framework.**
Clone or download the repository and open the folder in your editor:

```bash
git clone https://github.com/glovarix/agentic-ba.git
```

It has a deliberate folder structure — `templates/`, `artefacts/`, `coderepo/`, and `context/` — explained in full on **www.thedatadrivenlife.com**. The agent reads `CLAUDE.md` automatically, so Baxter is active the moment you open the folder.

**2. Install VS Code.**
Download it from https://code.visualstudio.com/. It is free and the easiest place to start because it gives you the agent in a side panel — no terminal required.

**3. Connect an AI agent.**
Add the **Claude Code extension** from the VS Code marketplace (recommended), or use a **paid GitHub Copilot** plan. Baxter also works with the Claude Code CLI and Cursor. Each tool loads its own instruction file automatically — no configuration needed.

**4. Find the `coderepo/` folder.**
Inside the project you will see an empty `coderepo/` directory. This is where your own product's source code goes. It is gitignored, so your code is never committed or pushed — it stays private on your machine.

**5. Add your codebase.**
Copy, clone, or symlink your project's source into `coderepo/`:

```bash
git clone https://github.com/your-org/your-project coderepo/
# or:  cp -r /path/to/your/project coderepo/
```

This is the step that makes Baxter accurate. The agent reads `coderepo/` to **sanity-check** every artefact against reality — real module names, fields, routes, roles, and data model — before you read a single word. *(This is optional for BRDs, which are written before code exists.)*

**6. Start working — just paste.**
Ask questions about your code, or paste a raw change request, bug report, or feature idea. You never fill in a form or name a template:

> "The login page returns a 500 when the user submits without a password."

Baxter classifies it ("This looks like a Bug Report — confirm?"), drafts it from the correct template, sanity-checks it, and asks before saving to the right folder.

---

## How a request becomes an artefact

1. **Classify** — Baxter reads your message and recommends an artefact type. You confirm with a number, the acronym, or "proceed".
2. **Read the codebase** — for everything except a new BRD, it reads `coderepo/` first.
3. **Draft** — it fills the matching template completely, in plain UK English, with no code jargon in the body.
4. **Sanity-check** — it reviews the draft across seven dimensions: names, technical feasibility, logic consistency, data model, roles and permissions, gaps and edge cases, and UX. Findings are reported *after* the draft as verified, corrected, or blocker.
5. **Save on your sign-off** — nothing is written until you approve. Git records every version, with your name in the revision history.

If the sanity check finds blockers, Baxter offers to draft a **Client Clarification Request** — a plain-language email with one precise question per blocker — to send back to the client before development begins.

---

## What you can ask for

Plain language triggers each artefact type — no commands required:

| Say something like… | You get |
| --- | --- |
| "Write up the BRD for recurring invoices" | Business Requirements Document |
| "Consolidate the requirements for the billing module" | Product Requirements Document |
| "Document the billing module" | Product Documentation |
| "Write an implementation plan for bulk import" | Technical Implementation Plan |
| "Generate test cases for the login module" | Test Cases |
| "The reports page returns a 500 on empty input" | Bug Report |
| "Add a bulk export option to the orders list" | Change Request |
| "We need AI to auto-suggest categories" | AI Feature Spec |
| "Diagram the checkout flow" / "Draw an ERD for orders" | Diagram / Entity Relationship Diagram |

Separate from the templated artefacts above, twelve **power skills** run as slash commands: `/validate-release` (full release validation against release notes), `/generate-module-registry` (build a registry of your product's modules), `/generate-retrospective-brd` (a client-facing BRD inferred from an existing codebase), `/generate-samples` (realistic sample data from your schema), `/generate-test-plan` (a test plan document and PDF from a test suite), `/generate-release-notes` (pre-release notes from GitHub issues), `/compare-branches` (a technical or plain-English diff between two branches), `/generate-ai-feature-registry` (a registry of every AI feature in the product), `/ai-feature-data-audit` (what data feeds one AI feature, plus a QA guide), `/generate-ai-feature-dependency-map` (which modules each AI feature depends on), `/brainstorm-change` (a second-opinion sweep on a Change Request in any state — saved, drafted, or still being discussed — for ripple effects, recurring patterns, alternative approaches, and UX ideas), and `/visualize-change` (a clickable HTML prototype of a Change Request, grounded in the real product). Their output structure lives in `.claude/commands/` — never in `templates/`.

---

## A few things worth knowing

- **BRDs are the exception.** They are written *before* code exists, so Baxter skips the codebase check for those.
- **PRDs join a module's CRs into one picture — before code, like a BRD.** A PRD consolidates *requirements* (what should happen, from CRs) — not what the code currently does. A PD is the opposite: it documents how a module is *actually implemented*, after those CRs are built. PRD = requirements, before implementation. PD = documentation, after implementation. PRDs stay local and are never pushed to GitHub. Test Cases always draw from a PRD and a PD together; Baxter generates whichever is missing automatically before writing the tests — and where the two disagree on a requirement, it generates two labelled test cases rather than quietly picking one.
- **BRD vs PRD, the fast way to tell them apart: audience.** A BRD is client/leadership-facing — the business case, before any code exists. A PRD is team-facing — internal, module-level, consolidated detail assembled from CRs. A BRD's scope tells you which module(s) will eventually need their own PRD, once that module starts accumulating CRs.
- **A BRD is deliberately non-technical: Who, Why, What.** The roles who use the product, the business case, and each module with its high-level features listed one line each — nothing more. No functional requirements, no acceptance criteria, no rules, nothing technical. That depth belongs in the module's PRD and its CRs, which is exactly why the two documents never overlap. If a product was built without a BRD, `/generate-retrospective-brd [path]` writes one from the codebase — clearly marked retrospective, so it is never mistaken for a BRD written before the build.
- **Any codebase, any stack — and every integration is optional.** Baxter assumes nothing about your language, framework, folder layout, repository host, or issue tracker; it reads your codebase to work out where things live. GitHub (via the `gh` CLI), ClickUp, and PDF tooling are all optional — without them, a skill notes what it skipped and produces the artefact anyway. No core artefact depends on any of them.
- **Nothing is saved without your sign-off.** Baxter generates, you verify, and git keeps the history.
- **Change Requests are checked for duplicates first.** Before drafting a new CR, Baxter searches your saved CRs for one that already covers the same request — matching by source link, then by topic — so you never end up with two CRs for the same ask.
- **Every CR and BR names its module(s) and submodule(s).** Baxter pulls these from your module registry and flags any likely dependent modules as suggestions. A genuinely new module gets marked `(new module)` right in the artefact, and Baxter offers to add it to the registry once the artefact is finalised. The title itself is prefixed with the primary module name, e.g. `[Orders] Print to PDF button on the customer profile`.
- **There's a backlog folder for unfinished CR work.** `artefacts/change-requests/BA-backlog/` holds candidate CR ideas not yet drafted and drafts not yet finalised or pushed. Nothing sits there once it's actually done.

**In one line:** Install VS Code + the Claude Code extension → open the `agentic-ba` folder → drop your code into `coderepo/` → paste a raw request → review and approve.

Full guide and folder-structure walkthrough: **https://www.thedatadrivenlife.com/getting-started/**
