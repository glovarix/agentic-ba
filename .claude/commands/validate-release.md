# /validate-release — Release Validation Skill

Compare what is on staging against production: confirm every release note item is present in staging, identify anything going to production that is not in the release notes, and surface undocumented changes. This is a critical part of the release process — run it fully and without shortcuts every time, exactly as defined in **Rule 15 of `CLAUDE.md`**.

---

## Step 1 — Gather the three mandatory inputs

All three must come from the user. Ask for any that are missing before doing anything else:

1. **Release notes file** — typically in `docs/`. Ask for the path if not given.
2. **Two branch snapshots** — directories inside `coderepo/branches/` (e.g. `my-app-staging/` and `my-app-production/`). If the folder is missing or contains fewer than two branches, stop and ask the user to add them. If more than two exist, ask which pair to compare.
3. **Sprint number** — required for the output filename. Ask if not provided.

---

## Step 2 — Run the validation

Follow Rule 15 in `CLAUDE.md` step by step:

1. Read the release notes.
2. Run a recursive brief diff: `diff -rq --brief {production-branch} {staging-branch}`.
3. For each release note item, confirm it is present in staging and absent from production, noting the key staging-only files as evidence.
4. Look up GitHub issues for each item with the `gh` CLI against the org found in the codebase's `.github/workflows/` files.
5. Identify all staging-only changes NOT in the release notes and categorise them as product-facing or infrastructure.
6. List database migrations present in staging only.

---

## Step 3 — Output

Generate the four-section report defined in Rule 15:

1. In the release notes — confirmed on staging
2. NOT in the release notes — also going to production (product-facing | infrastructure)
3. In production but removed or replaced in staging
4. Database migrations in staging only

Save to `artefacts/release-validation/` as `Sprint-{N}-{staging-slug}-vs-{production-slug}.md`, then generate the PDF immediately with `npx md-to-pdf` — no separate confirmation for the PDF.

**Rules:** GitHub issue numbers appear as plain numbers only (e.g. `#1234`), never hyperlinks. Release notes stay in `docs/` — never move them. Sprint number is mandatory in the filename.
