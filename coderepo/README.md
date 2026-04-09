# coderepo/

**Put your project's source code here.**

This folder is the codebase reference that the AI agent reads when verifying artefacts. When writing a BRD, TIP, or test case, the agent checks module names, field names, route paths, and role names against the real code in this folder — and flags anything that does not match before saving.

## How to populate it

**Option A — Copy your project in:**

```bash
cp -r /path/to/your/project/* coderepo/
```

**Option B — Symlink it (keeps one copy):**

```bash
ln -s /path/to/your/project coderepo/src
```

**Option C — Clone a sub-repo into it:**

```bash
git clone https://github.com/your-org/your-project coderepo/
```

## What goes here

- Source code (any language)
- Database schema files
- API route definitions
- Config files that define module names or field names

## What does NOT go here

- Build artefacts (`node_modules/`, `dist/`, `.next/`, etc.)
- Secrets or `.env` files
- Large binary assets

## Is it gitignored?

Yes — `coderepo/` is in `.gitignore` by default. Your source code stays private and is not committed to the agentic-ba repository.

If you are working on a public project and want to include the codebase, remove `coderepo/` from `.gitignore`.

## If you have no codebase yet

Leave this folder empty. The agent will still generate artefacts — it will note in the sanity check that no codebase was available to verify against, and will flag any names that should be confirmed when code is written.
