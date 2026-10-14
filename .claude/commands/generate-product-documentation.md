# /generate-product-documentation — Product Documentation for Named Modules

Generate a PD — Product Documentation artefact for one module, several named modules, or every
module in the registry, using `templates/PD-Product-Documentation.md`. Each PD describes a module
strictly as it is implemented in `coderepo/` today. Rule 27 governs every PD this command produces.

**Two ways in, one process.** A PD can still be requested in plain words as usual ("document the
Orders module", "PD for all modules") and classified under Rule 1, or started directly with this
command. Either way, follow the steps below. The command only skips the classification step — the
module confirmation, rules, save paths, and sanity check are identical.

## Usage

```text
/generate-product-documentation {module name}[, {module name}...]
/generate-product-documentation all
```

- Module names are matched against `artefacts/module-registry/modules.md` — by name or slug, case-insensitive.
- `all` means every module in the registry.
- With no argument, list the registry's modules and ask which to document.

## Step 1 — Read the inputs (every run, never from memory)

1. `preferences.json` if it exists, otherwise the defaults in CLAUDE.md.
2. `templates/PD-Product-Documentation.md` — use the template exactly as it is on disk.
3. `artefacts/module-registry/modules.md` (fall back to `context/modules.md`).
4. `artefacts/role-registry/roles.md` (fall back to `context/roles.md`).

**Gates:**

- **No codebase** — stop. A PD documents what was built; with nothing in `coderepo/` there is nothing to document. Say so plainly.
- **No role registry** — run `/generate-role-registry` first, as Rule 27 requires, then continue. Do not accept typed-in roles instead.
- **No module registry** — offer `/generate-module-registry` or let the user type the module name(s); if typed, note in the sanity check that the names could not be verified.
- **More than one project in `coderepo/`** — ask which to use.

## Step 2 — Resolve and confirm the module list

- Match each requested name to a registry row. Correct obvious misspellings to the registry name and say so.
- A name with no registry match is not drafted — report it and ask whether it is a different module or genuinely missing from the registry.
- A registry module with no implementation in code gets no PD (Rule 27). Report it and suggest a registry correction or a CR instead.
- Respect `confirmBeforeGenerate`: list the resolved modules, the output path(s), and the role columns, then wait for confirmation. One confirmation covers every file in the run — do not ask again per file.

## Step 3 — Draft each PD from the code

For each module:

1. Work out where the module lives in this codebase by reading it. Never assume a folder layout.
2. Establish each default role's access from what the code actually enforces — default permission sets, server-side checks, and on-screen gating. Where screen and server disagree, document what a user actually experiences and record the disagreement in the sanity check.
3. Fill every template section: header, Overview (with `**Default roles:**` and `**Related modules:**`), App Flow, Features by Role, Module Connections, Notifications & Triggers, Known Limitations. No other sections.

**Role rules (Rule 27):**

- One Features by Role column per registry role, in registry order, each header written Display Name (`code_identifier`). Never pad, drop, or invent a column.
- Every cell is evidenced: View, Create, Edit, Delete combinations, `—` for no access, or `(placeholder — Dev to confirm)` where the code does not settle it.
- `**Default roles:**` lists only the registry roles that actually have access to this module.

**Writing rules (Rule 3):** the configured language, present tense, active voice, plain words, no emojis. No code references in the body — no file paths, table or field names, permission strings, or developer terms. The only code-level string allowed is a role's code identifier. Never invent behaviour; write "to be confirmed with Dev" where the code is unclear.

**Never in the PD:** a Sanity Check section or any sanity-check content (Rule 4). Do not read the module's PRD (Rule 21).

## Step 4 — Save

Respect `confirmBeforeSave` (the Step 2 confirmation counts for the whole run).

| Run | Save to |
| --- | --- |
| One module | `artefacts/product-documentation/{YYYY-MM-DD}-{module-slug}-PD.md` |
| Two or more modules | `artefacts/product-documentation/{YYYY-MM-DD}-modules/{YYYY-MM-DD}-{module-slug}-PD.md` |

Slugs come from the registry's Slug column. If a file already exists, ask whether to replace it or create a new version — never overwrite silently.

## Step 5 — Sanity check

Run the full Rule 4 sanity check for every PD, plus Rule 27's PD additions: every role column checked against the registry and the code, any registry role the module does not use, and any access enforced for a role the registry does not list.

- **One module** — show the sanity check in the chat response only.
- **Two or more modules** — show a summary in chat (cross-cutting findings and every ❌ blocker), and also save one common document beside the PDs: `{YYYY-MM-DD}-modules-PD-sanity-check.md`, with the cross-cutting findings first and then one section per module. It is a review record for the BA, never part of any PD.

If any ❌ items are found, offer a CLQ — Client Clarification Request, as Rule 4 requires.

## Running many modules

For more than a few modules, split the work across parallel subagents, a handful of modules each, all
working from one shared brief that carries the rules above. To keep a large run resilient:

- Subagents do not start subagents of their own.
- Each PD is written to disk as soon as it is drafted, so an interrupted run keeps its finished work.
- On a retry, skip any module whose file already exists.
- Each subagent returns its sanity checks in its final message for the common document; it never writes them into a PD.

After the run, check every file: all template sections present, one column per registry role, no
code references or emojis in the body.

## Rule 9

If the run surfaces a module that is missing from the registry and genuinely exists in code, propose
the registry addition after saving and wait for confirmation.
