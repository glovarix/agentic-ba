# /generate-role-registry — Generate Role Registry from Codebase

Scan the codebase to build a draft registry of the product's **default roles** — the roles built into
the application itself. Present it to the user for review before saving to
`artefacts/role-registry/roles.md` and `context/roles.md`.

## The codebase is the only source. There is no other one.

Every role in this registry must be evidenced in `coderepo/`. Not a BRD, not a permissions
spreadsheet, not an onboarding document, not an existing artefact, not the user's own description,
not a role that "obviously must exist". **If it is not in the code, it does not go in the registry.**

This is stricter than every other skill in this framework, deliberately — but not because module
names matter less. A wrong module name or grouping breaks the naming consistency the module registry
exists to enforce, and that consistency is the point of having a registry at all; it is simply
visible and correctable, because the slug is sitting in the filename. A role name that is wrong — or
a role that does not actually exist — silently corrupts every access statement in every PD, PRD, and
test case that uses it, and nothing downstream can catch it. The registry is only worth having if
every row is verifiable, so:

- **No codebase, no registry.** This skill does not run without code. It has no provisional mode and no fallback source.
- **Other documents cannot add a role.** A permissions matrix or a BRD naming a role the code does not implement is a discrepancy to report, never a row to write.
- **A registry with four certain roles beats one with eight where half are inferred.** Under-report and flag the gap; never pad.

**This constrains what the agent may invent, not what the user may correct.** The registry is the
user's file and they can edit any part of it — this reading of the codebase is fallible, and the
person who knows the product will spot a role that was missed, misnamed, or wrongly excluded. A user
correction is a pointer to something real, so take it seriously: go and find it in the code, and
record it properly. See Step 8.

**Default roles only.** A default role ships with the product: defined in code, seeded on install,
present in every deployment before anyone configures anything. A role a customer creates at runtime
in an admin screen is not a default role and never belongs here, however common it is in one tenant's
data. Step 4 makes this exclusion explicit.

**Why this exists:** Product Documentation (PD) states each feature's access per role, and those
columns must be the product's real roles, spelled the product's way. Without a registry, role names
get invented, guessed from job titles, or copied from one tenant's custom setup. See Rule 27.

**The Code Identifier column is consumed directly by every artefact.** A role is written
Display Name (`code_identifier`) the first time it appears in any artefact table or section — the
one code-level string permitted in an artefact body, because it is what makes a role claim checkable
against the source. A row with no Code Identifier therefore cannot be used as written: it can only
appear marked unverified. This is why Step 7 makes the column mandatory on every row, and why Step 8
marks a user-added role `(user-corrected — not located in code)` until its identifier is found.

---

## Step 1 — Read the codebase

Apply the standard codebase priority rule:

- Read every project directory present in `coderepo/`.
- If `coderepo/` contains more than one project and the user has not named which to use, ask before proceeding.
- **If `coderepo/` is empty or absent, stop.** Say: "There is no codebase in `coderepo/` to read roles from, and a role registry can only be built from code — a BRD or a permissions document cannot stand in for it, because an unverifiable role is worse than no registry at all. Add your project source code and run `/generate-role-registry` again." Then stop. Do not offer an alternative source, and do not draft a provisional registry.

---

## Step 2 — Read the existing registry, for reconciliation only

If `artefacts/role-registry/roles.md` exists, read it (falling back to `context/roles.md`). If neither
exists, start fresh.

**An existing row is not evidence.** It tells you what was true at the last run, not what is true now.
Every row must be re-evidenced against the code on every run:

- Still evidenced → keep, updating any detail that has changed.
- No longer found → do **not** keep it silently and do **not** silently drop it. Raise it in Step 8: the role may have been renamed, removed, or the code may have moved.
- Found under a new name → treat as a rename and follow Step 6's rename warning.

Also read `artefacts/module-registry/modules.md` (or `context/modules.md`) if either exists — for
consistent module spelling in the Notes column only. It cannot contribute a role.

---

## Step 3 — Identify candidate roles from the code

Work out where this codebase expresses its access model, then read that. Do not assume a framework, a
folder, or a file name — find it by reading. Roles are typically evidenced in more than one of:

- **Role definitions in code** — enums, constants, union types, or literal sets naming the roles (e.g. a `Role` enum, a `ROLES` constant, a string-union type on a user record).
- **Seed, migration, or fixture files** — rows inserted into a roles/permissions table on install. This is the strongest possible evidence a role is *default*: it exists before any customer touches the system.
- **Auth and permission enforcement** — guards, middleware, decorators, policy files, route protection, and server-side authorisation checks that test for a named role.
- **Role-based branching in the UI** — conditional rendering, navigation filtering, and menu construction keyed to a role.
- **The role-management screen itself** — an admin screen listing roles usually distinguishes built-in roles from customer-created ones (often by an `is_default`/`is_system`/`editable` flag, or by blocking deletion). Read that distinction; it answers Step 4 directly.
- **Configuration and environment files** — a default-role setting, a bootstrap/superuser role, an installation default.

Collect every candidate before filtering anything — do not exclude while still reading, do it as a
separate pass (Step 4).

**Record the evidence as you go — where each role was found, and how strongly.** A role defined in an
enum, seeded on install, and enforced in middleware is certain. A role named once in a comment or a
single UI string is not, and Step 8 must say so. You cannot report evidence strength at the end
unless you tracked it here.

---

## Step 4 — Exclude non-roles

Strip out everything below before consolidating what is left. Say what got excluded and why — do not
silently drop items.

- **Customer-created custom roles.** Roles a tenant defines at runtime through an admin screen. They vary per deployment, so they are configuration data, not product structure. If the codebase supports custom roles at all, note that fact once in the saved file's header rather than listing any of them.
- **Permissions, scopes, and capabilities.** `can_edit_orders`, `orders:write`, `MANAGE_USERS` — these are what a role *has*, not a role. If the code defines hundreds of these, it is a permission catalogue and only the roles they group under belong here.
- **Job titles and staff types held as data.** A lookup table of professions, a "job title" free-text field, or a staff-type dropdown describes a person's occupation and grants nothing. Only include it if the code actually gates access on it.
- **Personas and audiences.** Anyone who never authenticates — a regulator reading a report, a family member receiving a notification — is not a role.
- **Groups, teams, departments, and organisational units.** A container users belong to, not an access level, unless the code demonstrably derives permissions from it.
- **Account states.** Active, suspended, pending, invited, locked, trial, archived. A lifecycle status on an account, not a role.
- **Non-human identities.** Service accounts, API clients, machine tokens, webhook callers, cron/system users, and integration identities. Note them in one line in the saved file if the product has them — a PD's role columns describe people.
- **Subscription tiers and plans.** Free/Pro/Enterprise gate features commercially, not by job function. Exclude unless the code genuinely treats a tier as a role.
- **Impersonation and support modes.** "Log in as user", support-view, and read-only debug modes are mechanisms, not roles. Note the mechanism if it exists; do not list it as a role.
- **Deprecated or dead roles.** A role still defined in code but no longer assignable or enforced anywhere. Do not silently drop it — list it in Step 8 and ask the user whether to keep it marked `(deprecated)` or remove it.

A commented-out enum member or a roadmap note is not a role. Note it separately as a candidate for
future addition; never write a row for it.

---

## Step 5 — Consolidate what's left

Work through these checks, in order, on the surviving candidate list:

1. **Same role, code name vs display name → one row.** `ORG_ADMIN` in the enum and "Organisation Administrator" on screen are one role. Keep the UI label as the Role name and the literal code value in Code Identifier — never two rows, and never a Role name you invented when the UI already names it.
2. **Same role spelled differently across layers → one row.** Casing, hyphenation, and pluralisation drift between an enum, a database value, and a UI string. Reconcile to one row and note the variants if they are likely to confuse.
3. **Distinct scopes of the same job → separate rows only if the code separates them.** If the system genuinely distinguishes an organisation-level administrator from a facility-level one with different identifiers and different checks, those are two roles. If it is one role whose reach is computed from the user's assignment, that is one role — record the variability in Scope.
4. **A hierarchy is not a merge signal.** A role that inherits another's permissions is still its own role. Record the inheritance in Notes; never collapse a hierarchy into its top role.
5. **Self-audit for asymmetric treatment.** Scan the list for two roles with the same shape of description and check they were resolved the same way. This is the easiest mistake to make and the easiest to miss unless checked as its own pass.
6. **Naming collisions → disambiguate, don't merge.** If two genuinely distinct roles want the same display name, rename one to be specific rather than merging concepts that don't overlap.
7. **Where layers of the code disagree, enforcement wins.** What the server actually checks beats what a UI string, a comment, or an unused constant implies.

---

## Step 6 — Apply the naming standard

- **The Role name is what the product calls it on screen.** If the UI says "Care Coordinator", the registry says Care Coordinator — not the enum member, not a tidier synonym, not a generic industry equivalent.
- Title Case with spaces (e.g. "Organisation Administrator"). Hyphenation belongs at the slug layer only.
- **Never abbreviate a role name the product spells out**, and never expand one it abbreviates.
- Where the code has no UI label for a role — a bootstrap or superuser role with no screen — derive a readable Title Case name from the code identifier and mark it in Notes as `(no UI label — name derived from code)`.
- **Code Identifier is copied verbatim, in backticks** — exact case, exact underscores, exact prefix (`ORG_ADMIN`, `super-admin`, `role.clinician`). This column is what makes every artefact's role name verifiable, so it is never tidied, normalised, or guessed. Every row has one; a row that cannot have one has no business existing.
- If a role is being renamed from what is in the current registry, check `artefacts/` for existing PDs, PRDs, CRs, or TCs referencing the old name — flag this to the user before saving, since a rename silently orphans references in already-written artefacts.

---

## Step 7 — Draft the role registry table

Build a draft table in this format:

| Role | Slug | Code Identifier | Scope | Who they are | Default access | Notes |
| --- | --- | --- | --- | --- | --- | --- |

Rules:

- One row per default role
- **Role** — Title Case display name, per Step 6
- **Slug** — lowercase kebab-case form, in backticks (e.g. `organisation-administrator`). Spaces become hyphens, `&` becomes `and`, all other punctuation is dropped
- **Code Identifier** — the literal value as it appears in code, in backticks. Mandatory on every row
- **Scope** — the boundary this role operates within, as evidenced in code (e.g. system-wide across all organisations, a single organisation, one facility or team, own records only). Derive the levels from this codebase; do not impose a fixed vocabulary
- **Who they are** — one sentence, plain English: the job this person does. Not a permission list
- **Default access** — one short phrase summarising their out-of-the-box reach (e.g. "Full administrative access within their organisation", "Read-only access to their own records"). Keep it to what the code actually grants by default
- **Notes** — inheritance, whether the role is assignable through the UI, whether its permissions are customisable per tenant, seed/migration evidence, `(deprecated)`, or `—` if none
- Sort rows by scope, broadest first, then alphabetically by Role — so the registry reads top-down as an access hierarchy

Directly below the table, add two short blocks when they apply:

- **Role hierarchy** — a few lines stating which roles inherit from which, if the codebase implements inheritance. Omit the block entirely if it does not.
- **Not default roles** — one line each for the categories found and excluded in Step 4 that a reader would otherwise expect to see (custom roles, service accounts, subscription tiers, impersonation modes). This keeps the exclusions visible in the artefact, not just in chat.

---

## Step 8 — Present for review

Show the draft table to the user, plus a short summary covering:

- **Evidence strength per role** — which are certain (defined, seeded, and enforced) and which rest on thinner evidence (named once, enforced nowhere).
- **What got excluded and why** — especially anything the user might expect to see: custom roles, service accounts, job titles held as data.
- **Anything in the previous registry no longer found in code** (Step 2).
- **Renames** affecting artefacts already written (Step 6).

Then say:

> "Here is the draft role registry, built from the codebase. Review each row — edit or remove any roles. When you are happy, say **save** and I will write it to `artefacts/role-registry/roles.md` and `context/roles.md`."

Wait for the user's response. **Apply every correction, removal, rename, and rewording the user
asks for.** This is their registry and this skill's reading of the codebase is fallible — a missed
role, a wrong scope, an access model expressed somewhere unusual are all normal, and the user is
the one who will notice. Never argue a user out of a correction, and never make them repeat it.

**When the user adds or corrects a role, go and verify it in the code — to complete the row, not to
gatekeep it.** The point of the check is to fill in the Code Identifier, scope, and evidence
accurately:

- **Found it** — you missed it, or it was named differently than expected. Add it with its real Code Identifier and say where it turned up, so the correction is anchored.
- **Cannot find it** — keep the user's row, and say once what you searched so they can point you at the right place: "Added {role} as you described. I could not locate it in the codebase — I looked at {where}. If you can point me at the file or screen, I'll fill in its code identifier." Mark the row `(user-corrected — not located in code)` in Notes until it is confirmed.

That marker is the whole mechanism: the user's judgement wins immediately, and the row's provenance
stays visible instead of being quietly blended in with the rows read from code. Never silently drop a
role the user asked for, and never silently present an unlocated one as code-verified.

If the user says "save" with no further edits, proceed to Step 9.

---

## Step 9 — Save

Use the canonical structure below — power skill output structure lives in this command file, not in
`templates/`. Write the agreed content to **both** files, keeping the header block and "How to add a
role" section exactly as shown. Replace only the table rows and the two optional blocks.

```markdown
# Role Registry

> The authoritative list of **default roles** built into this product.
> Run `/generate-role-registry` to populate this file from your codebase.
> All artefacts must use role names exactly as listed here.
> The agent reads this file before generating any Product Documentation (PD), and before writing any
> role-based access statement in any other artefact.
>
> **Every row is evidenced in the codebase.** This registry is built from code alone — no BRD,
> permissions matrix, or manual addition may introduce a role that the code does not implement.
> Custom roles created by a customer at runtime are deliberately excluded: this registry describes
> the product, not one deployment's configuration.
>
> The Code Identifier column is the literal value used in the codebase — it is what makes a role
> name in any artefact verifiable.

---

| Role | Slug | Code Identifier | Scope | Who they are | Default access | Notes |
| --- | --- | --- | --- | --- | --- | --- |

---

## Role hierarchy

{Which roles inherit from which. Omit this section entirely if the codebase implements no inheritance.}

---

## Not default roles

{One line each for what was found and excluded — custom roles, service accounts, subscription tiers,
impersonation modes. Omit this section entirely if nothing was excluded.}

---

## How to add a role

Edit this file freely — it is generated from the codebase, but a generated reading can be wrong, and
your correction wins. Add roles that exist in the product and were missed, fix names and scopes, and
remove anything misread.

Add roles that exist in the codebase. If a row cannot be traced to code yet, mark it
`(user-corrected — not located in code)` in Notes so its provenance stays visible. Re-run
`/generate-role-registry` after any change to the product's access model.

1. Add a row to the table above — default roles only, not customer-created ones
2. Use the product's own on-screen name for the role, in title case
3. Slug: lowercase kebab-case version of the role name (`&` becomes `and`, spaces become hyphens)
4. Copy the Code Identifier verbatim from the codebase — exact case and punctuation
5. Scope: the boundary the role operates within, as the codebase defines it
6. Keep "Who they are" to one sentence — the job this person does, not a permission list
7. Use Notes for inheritance, deprecation, or `—` if none
```

1. `artefacts/role-registry/roles.md` — the versioned artefact, alongside every other generated artefact.
2. `context/roles.md` — the working reference copy, available to the team without opening artefacts.

Both files must be identical after saving. If either already exists, overwrite it.

Confirm to the user: "Role registry saved to `artefacts/role-registry/roles.md` and `context/roles.md` — {N} default roles."

---

## Notes

- **Never invent a role to fill a gap.** If the access model is unclear, say so and list what could not be determined.
- **Never promote a customer's custom role into the registry** because it appeared in seed data for one tenant, in a demo account, or in a client's spreadsheet.
- **Never let another document introduce a role.** If a BRD, a permissions matrix, or an existing artefact names a role the code does not implement, report the discrepancy — it is usually either a role that was never built or one that has been removed — and leave it out. This applies to documents, not to the user: a person correcting the registry is always applied (Step 8).
- If a role already exists in the registry under a different name, flag the conflict to the user before overwriting.
- Re-run this skill whenever the product's access model changes — a new role, a renamed role, or a role that stops being enforced.
- Today's date comes from the `currentDate` value in memory context, or run `date +%Y-%m-%d` if not available.
