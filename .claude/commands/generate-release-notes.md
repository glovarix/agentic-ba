Generate a pre-release notes document in the standard pre-release notes format from a list of GitHub issue numbers. This command is project-agnostic: it defines the structure (columns, numbering, save pattern) but takes every module name, label, and grouping from the connected project — never from hardcoded examples.

## Usage

```
/generate-release-notes [sprint-number] [issue-numbers]
```

- `sprint-number` — required. Ask if not provided.
- `issue-numbers` — one or more GitHub issue numbers, space- or comma-separated. Ask if not provided.

## What this command does

### 1. Resolve inputs

- **Sprint number** — required. If missing, ask before proceeding.
- **Issue numbers** — required. Accept as a list anywhere in the user's message. If missing, ask.
- **Release note number (N{X})** — check the sprint folder (`docs/Pre-release Sprint {N}/`) for existing files matching `*Pre-release Notes*.md`. Auto-increment from the highest N found. If the folder is empty or does not exist, default to N1. If the user supplies a number explicitly, use it.
- **GitHub org/repo** — read from the git remote: `git remote get-url origin`. Parse the org and repo name from the URL. If not available, check `.github/workflows/` for `repo:` references.

### 2. Fetch issues from GitHub

For each issue number, run:
```
gh issue view {N} --repo {org}/{repo} --json number,title,body,labels,milestone,url,state,assignees
```

From each issue, extract:
- `number`, `title`, `labels[]`, `url`, `state`
- Any `https://app.clickup.com/t/` URL present anywhere in the `body` — this is the ClickUp card URL for that issue

### 3. ClickUp enrichment (optional — gracefully skipped if unavailable)

If ClickUp MCP tools are available in the session:
- For each issue where no ClickUp URL was found in the body, search ClickUp by keyword derived from the issue title (2–4 key terms)
- Accept a match only if the card name or content clearly relates to the issue — never link a card speculatively
- Prefer cards with active statuses (in progress, awaiting pre-release) over completed or roadmap-backlog cards
- If no confident match is found, leave the ClickUp cell blank

If ClickUp MCP is not available, skip this step entirely and leave all ClickUp cells blank.

### 4. Derive release period label

Read today's date from the system context (`currentDate`).

| Day of month | Label |
|---|---|
| 1–10 | Early {Month} {Year} |
| 11–20 | Mid {Month} {Year} |
| 21–31 | Late {Month} {Year} |

### 5. Group and order issues

Group issues by module area. Read `artefacts/modules/modules.md` (or `context/modules.md`) where available and use its module names for the groups. Derive each issue's group from its GitHub labels and title. Within each group, order by issue number ascending.

Order the groups logically:

| Priority | Group |
|---|---|
| 1 | Core user-facing product areas (the modules users interact with daily) |
| 2 | Reporting and audit |
| 3 | Staff, admin, and scheduling areas |
| 4 | Compliance and data standards |
| 5 | Infrastructure and internal (no user-facing change) |

If an issue does not fit neatly into one group, use the label and issue title as the primary signal. When two issues clearly belong together (e.g. a parent and sub-issue covering the same feature), combine them into a single row with both issue numbers listed.

### 6. Derive item names and descriptions

**Item name:** Clean the GitHub issue title into a concise release-note title.
- Format: `{Module} — {Feature}` using an em dash (—)
- Remove redundant words (Frontend, Backend, Implementation, Module — these are implementation details, not feature names)
- Keep it to 6–10 words

**Description:** Write a 1–2 sentence plain-English summary derived from the issue's Summary or Problem & Context section.
- Follow Rule 3: UK English, active voice, present tense, no technical jargon, no code references
- Do not repeat the item name
- Focus on what the user or manager can now do, or what has changed

### 7. Build the release notes table

Use this exact column structure:

```markdown
| # | Item | Description | GitHub Issues | ClickUp Card | Video |
|---|---|---|---|---|---|
```

- Sequential row numbering from 1
- GitHub Issues: `#NNNNN` format; multiple issues in one row as `#NNNNN, #NNNNN`
- ClickUp Card: `[ClickUp](url)` if a URL was found or matched; blank otherwise
- Video: always blank — the user fills this in

### 8. Confirm and save

Respect `confirmBeforeSave` from `preferences.json`. If `true`, present the full table and proposed filename and ask for confirmation before writing.

**Save path:**
```
docs/Pre-release Sprint {N}/Pre-release Notes for {period} N{release}.md
```

Create the sprint folder if it does not exist before saving:
```bash
mkdir -p "docs/Pre-release Sprint {N}"
```

Never overwrite an existing file without confirmation.

### 9. Generate PDF

Immediately after saving, run:
```
npx md-to-pdf "{path-to-saved-file}"
```

Report the output filename and file size. If `npx md-to-pdf` is not available, tell the user to install it with `npm install -g md-to-pdf`.

Do not ask for separate confirmation before generating the PDF — it is part of the same operation.

## Output format reference

```markdown
# Pre-release Notes — {period} (Sprint {N}, N{release})

| # | Item | Description | GitHub Issues | ClickUp Card | Video |
|---|---|---|---|---|---|
| 1 | Orders — Bulk CSV Export | Admins can now export the filtered orders list to CSV directly from the reports view. | #1234 | [ClickUp](https://app.clickup.com/t/{card-id}) | |
| 2 | Invoicing — Recurring Invoices | Adds recurring invoice schedules with monthly and quarterly frequencies. Existing one-off invoices are unchanged. | #1240, #1241 | | |
```

## Notes

- The `docs/` folder is not committed to git by default (Rule 14). This is intentional — release notes are internal working documents.
- If the user provides issue numbers for a different repo than the one in `coderepo/`, confirm the org/repo before fetching.
- Today's date is available in the system context as `currentDate`.
- If an issue is a parent/master issue (its body references sub-issues), describe it at the initiative level and note which sub-issues are delivered in this sprint.
