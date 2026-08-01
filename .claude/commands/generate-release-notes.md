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
- **GitHub org/repo** — only if `integrations.github.enabled` and `integrations.github.useCli` are on in `preferences.json` (Rule 24). Take it from `integrations.github.repo`, or read the git remote when that is blank: `git remote get-url origin`. If the toggle is off, the project is not hosted on GitHub, or `gh` is not installed or authenticated, say so once and ask the user to paste the issue titles and descriptions — every later step runs identically on pasted content.

### 2. Fetch issues from GitHub

For each issue number, run:
```
gh issue view {N} --repo {org}/{repo} --json number,title,body,labels,milestone,url,state,assignees
```

From each issue, extract:
- `number`, `title`, `labels[]`, `url`, `state`
- Any link to the configured issue tracker present anywhere in the `body` (e.g. an `app.clickup.com/t/` URL for ClickUp, a browse URL for Jira) — this is that issue's tracker link

### 3. Issue tracker enrichment (optional — off by default, gracefully skipped)

Only if `integrations.issueTracker.enabled` is on in `preferences.json` (Rule 24) and the configured provider's tools are available in the session:
- For each issue where no tracker link was found in the body, search the configured tracker by keyword derived from the issue title (2–4 key terms), scoped to `integrations.issueTracker.workspace` when one is set
- Accept a match only if the item's name or content clearly relates to the issue — never link one speculatively
- Prefer items with active statuses (in progress, awaiting release) over completed or backlog items
- If no confident match is found, leave the cell blank

If the toggle is off, or the provider's tools are not available, skip this step entirely and leave the column blank.

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

Use this column structure:

```markdown
| # | Item | Description | GitHub Issues | {Tracker} | Video |
|---|---|---|---|---|---|
```

- Sequential row numbering from 1
- GitHub Issues: `#NNNNN` format; multiple issues in one row as `#NNNNN, #NNNNN`
- `{Tracker}`: name the column after the configured provider — `ClickUp Card`, `Jira Issue`, `Linear Issue`, `Work Item`. Cell format `[{Provider}](url)` if a link was found or matched; blank otherwise. **Omit this column entirely when `integrations.issueTracker.enabled` is off** — do not ship an empty column for a tracker the team does not use
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

Report the output filename and file size. If `npx md-to-pdf` is not available, mention `npm install -g md-to-pdf` and stop there — the saved Markdown is the deliverable, never withheld over a missing PDF tool.

Do not ask for separate confirmation before generating the PDF — it is part of the same operation.

## Output format reference

```markdown
# Pre-release Notes — {period} (Sprint {N}, N{release})

| # | Item | Description | GitHub Issues | {Tracker column — omitted when no tracker is enabled} | Video |
|---|---|---|---|---|---|
| 1 | Orders — Bulk CSV Export | Admins can now export the filtered orders list to CSV directly from the reports view. | #1234 | [{Provider}]({item-url}) | |
| 2 | Invoicing — Recurring Invoices | Adds recurring invoice schedules with monthly and quarterly frequencies. Existing one-off invoices are unchanged. | #1240, #1241 | | |
```

## Notes

- The `docs/` folder is not committed to git by default (Rule 14). This is intentional — release notes are internal working documents.
- If the user provides issue numbers for a different repo than the one in `coderepo/`, confirm the org/repo before fetching.
- Today's date is available in the system context as `currentDate`.
- If an issue is a parent/master issue (its body references sub-issues), describe it at the initiative level and note which sub-issues are delivered in this sprint.
