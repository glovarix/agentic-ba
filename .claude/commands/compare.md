# /compare — Branch Comparison Skill

Compare two branches stored as folders inside `coderepo/branches/`. Saves Markdown files and generates PDFs from them. No HTML files are saved to disk.

---

## Step 1 — Choose output type

Before doing any analysis, ask the user:

> "Which comparison would you like?
> **1** — Technical (detailed code-level diff for developers)
> **2** — Non-technical (plain-English features & use cases for product, QA, or clinical leads)
> **3** — Both"

Accept the number, or plain text like "both", "technical", "non-technical", "all". Store as OUTPUT_MODE (`technical` | `non-technical` | `both`).

---

## Step 2 — Discover branches

List the immediate subdirectories of `coderepo/branches/`. Ignore `.DS_Store` and any non-directory entries.

- If the folder does not exist or contains fewer than 2 subdirectories, stop and tell the user: "No branches found in `coderepo/branches/`. Add at least two branch folders there and try again."
- If there are exactly 2 subdirectories, use them as BRANCH_A and BRANCH_B automatically. Tell the user which two you are comparing before proceeding.
- If there are 3 or more subdirectories, list them and ask the user to pick two by name or number. Wait for their reply before continuing.

---

## Step 3 — Inventory differences

With BRANCH_A and BRANCH_B identified:

1. Build a sorted file list for each branch (all files, relative paths, ignoring `.DS_Store`).
2. Identify:
   - Files only in BRANCH_A (removed in B)
   - Files only in BRANCH_B (new in B)
   - Files in both — run a binary diff; collect only those that differ in content.
3. For every file that differs, run a line-level diff and read the output. Group findings by functional area as you go.

Work through diffs systematically across these areas (adapt to what actually exists):

- Package files and dependencies (`package.json`, workspace files, lock files)
- Environment and configuration (env schemas, feature flags, tooling config)
- API / back-end routers and handlers
- Data layer (queries, schema, migrations implied by code)
- Front-end pages and components — group by product module
- Shared utilities and hooks
- CSS / styling
- Developer tooling (linting, scripts, CI)

For each diff, capture: what the change is in plain language, which branch has which behaviour, and whether the change is user-visible.

---

## Step 4 — Write Markdown files

### Technical Markdown (skip if OUTPUT_MODE is `non-technical`)

Write a Markdown file to `{BRANCH_A}-vs-{BRANCH_B}-diff.md` in the project root.

Structure:

```text
# {BRANCH_A} vs {BRANCH_B} — Differences Analysis
Generated: {today's date}

## Summary
4-stat summary: files differing | new in B | removed in B | functional areas

## A. New files in {BRANCH_B} only
Table: # | Area | What is new

## B. Files removed in {BRANCH_B}
Table: # | File | Reason

## C. Changed files — by functional area
One ### heading per area.
Table per area: Item | {BRANCH_A} | {BRANCH_B}

## Key observations
Numbered list of the most significant findings.
```

### Non-technical Markdown (skip if OUTPUT_MODE is `technical`)

Write a Markdown file to `{BRANCH_A}-vs-{BRANCH_B}-usecases.md` in the project root.

Rules for this document:

- No file paths, no code references, no technical terms (no "component", "hook", "router", "schema", "query", "API", "migration", "boolean", "regex", etc.)
- Every row answers: "What can a user do here, and is it available in A, B, or both?"
- If behaviour differs, describe each clearly and briefly in plain English
- Use module names from `context/modules.md` as section headings where they match
- Include a "Known Issues" section for any debug artifacts or ❌ findings

Structure:

```text
# {BRANCH_A} vs {BRANCH_B} — Features & Use Cases
Plain-English overview | Generated: {today's date}

Legend: Branch A only | Branch B only | Both (different) | Caution

## {Module name}
Table: Feature | What the user can do | {BRANCH_A} | {BRANCH_B} | Notes

## Known Issues (if any)
Table: Issue | What happens | {BRANCH_A} | {BRANCH_B} | Action required

Pre-merge checklist (bullet list of any items that must be resolved before merging)
```

Status values in tables: Available | Not available | {BRANCH_B} only | {BRANCH_A} only | Different | Caution

---

## Step 5 — Generate PDFs

For each Markdown file produced, convert it to PDF.

**Check for tools in this order:**

1. `which pandoc` — if found, run:

   ```bash
   pandoc "{input.md}" -o "{output.pdf}" \
     --pdf-engine=xelatex \
     -V geometry:margin=2cm \
     -V fontsize=11pt
   ```

2. If pandoc is not available, check for Chrome at `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`, then `which chromium`, then `which google-chrome`.

   If Chrome is found, build a minimal styled HTML wrapper around the Markdown content (rendered to HTML), write it to a temp file in `/tmp/`, generate the PDF, then delete the temp file:

   ```bash
   # Generate PDF
   "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
     --headless=new --disable-gpu --no-sandbox \
     --print-to-pdf="{output.pdf}" \
     --print-to-pdf-no-header --no-pdf-header-footer \
     "file:///tmp/{temp}.html"

   # Clean up temp file
   rm "/tmp/{temp}.html"
   ```

   Styling for the Chrome HTML wrapper: system-ui font, 10.5pt body, dark navy section headings, alternating table rows, coloured status badges (green/red/amber/blue/grey), no emojis.

3. If neither tool is available, tell the user: "Could not find pandoc or Chrome for PDF generation. Open `{filename}.md` in a Markdown viewer and print to PDF manually."

PDFs are saved to the project root alongside the Markdown files.

Never overwrite existing files without asking the user first.

---

## Step 6 — Report to user

After all files are written, tell the user:

- The Markdown and PDF filenames produced
- A one-sentence summary of the most significant difference found
- Whether any known issues or debug artifacts were found that need resolving before a merge

Do not repeat the full analysis in chat — the files contain it.

---

## Notes

- Always read `context/modules.md` before writing the non-technical document to use correct module names.
- Filename slugs: use the exact folder names from `coderepo/branches/`, preserving hyphens.
- Today's date comes from the `currentDate` value in memory context, or run `date +%Y-%m-%d` if not available.
