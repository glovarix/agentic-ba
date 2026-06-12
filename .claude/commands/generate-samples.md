# /generate-samples — Generate Sample Data from Codebase

Produce up to 3 realistic, self-contained sample data records derived entirely from the real codebase — no data invented, no values hardcoded. Run exactly as defined in **Rule 12 of `CLAUDE.md`**.

---

## Step 1 — Resolve the record count

Default to 1 record. If the user explicitly requested more (e.g. "generate 2" or "generate 3"), honour that number up to a maximum of 3. Do not ask unprompted — generating sample records is token-intensive and 1 is sufficient for most purposes.

---

## Step 2 — Read the codebase

Apply the standard codebase priority rule (Rule 4): read every project directory in `coderepo/`; if more than one project exists and the user has not named which to use, ask. If `coderepo/` is empty or absent, state this and stop.

Look for: database schema or migration files, seed or fixture files, data shapes defined in application code, lookup tables and enumeration values referenced by the data model.

If the codebase contains no persistent data model (e.g. a UI-only demo with no state), state this and ask the user to provide a schema or data model before proceeding.

---

## Step 3 — Generate the records

Output format is always JSON (`.json`). Never generate SQL output regardless of codebase type or any request.

Each record must:

- Represent a distinct, realistic scenario or persona — different names, statuses, and contexts
- Cover a meaningful spread of the data model — related entities, varied field states, representative lookup values
- Use only table names, column names, type IDs, and lookup values verified in the codebase — never invented
- Be immediately droppable into the app with no changes beyond clearly marked environment placeholders (e.g. UUIDs, connection strings)
- Include a header comment block: what the record represents, how to use it, and any lookup values or status codes relied upon

**Sanity check (mandatory):** Before saving, verify every table name, column name, field name, and lookup value against the codebase. Flag anything that could not be verified.

---

## Step 4 — Save

Respect `confirmBeforeSave`. Save to `artefacts/sample-data/` using the pattern:

```text
sample-{app-slug}-{NN}-{slug}.json
```

| Segment | Convention |
| --- | --- |
| `sample-` | Always present — ensures the file is committed under the default `commitArtefacts: false` setting |
| `{app-slug}` | Lowercase kebab-case name of the codebase directory in `coderepo/` |
| `{NN}` | Zero-padded sequence number — 01, 02, 03 |
| `{slug}` | Short description of the record's scenario or persona |
