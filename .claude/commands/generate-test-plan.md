Generate a high-level test plan document and matching PDF from an existing test suite folder.

## Usage

```
/generate-test-plan [path-to-test-suite-folder]
```

- If a path is provided, use it as the test suite folder.
- If no path is provided, look for test suite folders under `artefacts/other/test-suites/` and ask the user to pick one.
- The folder must contain at least one file matching the pattern `*_TC*.md`. **If no TC files are found, stop immediately and tell the user to generate test cases first using the TC template before running this command.**

## What this command does

1. **Gate check (mandatory — run before anything else)** — count the `*_TC*.md` files in the resolved folder. If the count is zero, stop immediately and respond: "No test case files found in `[folder]`. Generate test cases first (say 'I need test cases for…'), then run `/generate-test-plan` again." Do not continue to step 2.

2. **Discover test cases** — read every `*_TC*.md` file in the target folder. Extract from each file:
   - ID (from the `**ID:**` frontmatter line)
   - Title (from the `# Test Case:` heading, stripping the prefix)
   - Priority (from the `**Priority:**` line)
   - Type (from the `**Type:**` line)
   - Linked BRD or source reference (from the `**Linked BRD:**` line)
   - Preconditions (summarise the Preconditions section in a few words)
   - Test area — infer from the ID sequence and precondition patterns; group consecutive IDs that share the same context into a named area

3. **Derive test plan content** — synthesise the following from the test case data:
   - Feature name and description: infer from the module prefix (e.g. `SERVICES_TC01` → Services feature) and the preconditions / step content
   - Test objectives: one bullet per area, describing what that area verifies
   - Scope: in-scope (one line per area), out-of-scope (anything not covered by the TCs)
   - Type breakdown: count Happy Path / Negative / Role-Based / Edge Case across all TCs
   - Area coverage table: area name, TC range, count, high-priority TCs
   - Full TC summary table: ID, title, area, type, priority — all TCs in one table
   - Risks: identify data setup complexity, role-switching requirements, ordering dependencies, and any edge-case preconditions that imply fragile test data

4. **Apply writing standards** — follow all rules from CLAUDE.md Rule 3:
   - UK English, present tense, active voice, no emojis, no code references in the body
   - Every section must serve a distinct purpose; no repetition
   - Placeholder text for fields that require human input: `(placeholder — [Role] to confirm)`

5. **Confirm before saving** — if `confirmBeforeSave` is `true` in `preferences.json`, announce the output filename and ask for confirmation before writing any file.

6. **Save the test plan** — write the document as `{MODULE}_TEST_PLAN.md` in the same folder as the test cases, where `{MODULE}` is the prefix shared by the TC files (e.g. `SERVICES`). Never overwrite an existing file without confirmation.

7. **Generate the PDF** — run the following command to produce a matching PDF in the same folder:
   ```
   npx md-to-pdf {path-to-test-plan.md}
   ```
   Report the file size on completion. If `npx md-to-pdf` is not available, state this clearly and suggest the user installs it with `npm install -g md-to-pdf`.

## Output document structure

The test plan must include all of the following sections in this order. Do not omit any section; write `(placeholder — [Role] to confirm)` if content cannot be derived from the test cases.

1. **Document Information** — version (1.0), date (today), status (DRAFT), prepared by (placeholder), reviewed by (placeholder)
2. **Introduction** — 2–4 sentences describing the feature under test and the purpose of this plan; infer from TC preconditions and area names
3. **Test Objectives** — one bullet per area stating what is being verified
4. **Scope** — GFM task list for in-scope items (one per area); separate GFM task list for explicit out-of-scope exclusions
5. **Test Approach** — table of test types (Happy Path / Negative / Role-Based / Edge Case) with count and one-line purpose; note any ordering dependencies between areas
6. **Test Environments** — table of environments (Staging primary, Demo smoke, Production excluded); data prerequisites as a GFM task list derived from the unique preconditions across all TCs
7. **User Roles Under Test** — table of roles, internal names, and which areas they cover; derived from the role mentioned in each TC's Preconditions section
8. **Test Area Coverage** — table with area number, description, TC range, TC count, and list of High priority TC IDs
9. **Test Case Summary** — full table: ID | Title | Area | Type | Priority — one row per TC, all TCs included
10. **Entry Criteria** — GFM task list: feature deployed to Staging, data prerequisites confirmed, test accounts available, source document accepted
11. **Exit Criteria** — GFM task list: all TCs executed, all High priority TCs passing or with accepted blockers, all failures have defect links, sign-off obtained
12. **Dependencies and Risks** — table: Risk | Impact (High/Medium/Low) | Mitigation — derive from complex preconditions, role-switching needs, ordering dependencies, and boundary data requirements
13. **Execution Schedule** — table: Phase | Activity | Target date (placeholder) | Owner (placeholder)
14. **Defect Management** — standard paragraph listing required defect fields: title, TC ID, steps to reproduce, expected result, actual result, environment, severity (P1–P4)
15. **Document Revision History** — table with version 1.0, today's date, author (placeholder), summary

## Notes

- If the folder contains a `*_TEST_PLAN.md` file already, read it first and offer to update it (increment version) rather than overwriting.
- Do not invent test case content — only synthesise from what the TC files actually contain.
- The PDF is always generated immediately after the markdown is saved; do not ask for separate confirmation for the PDF step.
- Today's date is available in the system context as `currentDate`.
