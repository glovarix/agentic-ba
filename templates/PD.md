# Product Documentation (PD)

> **Status:** DRAFT | IN REVIEW | PUBLISHED
> **Artefact ID:** `{YYYY-MM-DD}-{product-name}-PD`
> **Product:** {Product Name}
> **Version documented:** {e.g. v2.4}
> **Author:** Claude (AI) — **Verified by:** {Product Owner / Tech Lead}
> **Date:** {YYYY-MM-DD}

---

## 1. Product Overview

{3–5 sentences describing the product as it exists today — what it does, who uses it, and the problem it solves. Written for a new team member or stakeholder.}

---

## 2. App Flow

{One Mermaid diagram showing how the entire application fits together — modules, key user journeys, and how data flows between them. Update this whenever a major module is added or changed.}

```mermaid
flowchart LR
    subgraph Auth
        Login --> Session
    end
    subgraph {Module A}
        A1[{Screen or action}] --> A2[{Screen or action}]
    end
    subgraph {Module B}
        B1[{Screen or action}] --> B2[{Screen or action}]
    end
    Session --> A1
    Session --> B1
    A2 --> B1
```

---

## 3. Modules

{One subsection per module. Add or remove subsections as needed. Cross-reference `context/modules.md` for the authoritative module list.}

### 3.{N} {Module Name}

**What it does:** {What this module does and who uses it.}

**Who has access:** {e.g. Care Worker, Manager, Administrator}

**Key capabilities:**

- {What users can do — e.g. "Create and edit care plans"}
- {What users can do — e.g. "View a history of all changes"}

**Linked artefacts:**

| Type | Description    | Path                                                   |
|------|----------------|--------------------------------------------------------|
| BRD  | {Feature name} | [Requirements document](../requirements/{filename}.md) |
| TIP  | {Feature name} | [Implementation plan](../implementation/{filename}.md) |

---

## 4. User Roles

{Describe each role and what they can do across the product.}

| Role   | Who they are         | What they can do                        |
|--------|----------------------|-----------------------------------------|
| {Role} | {Who this person is} | {What they can create, view, or change} |

---

## 5. Key Workflows

{Describe the most important things a user does from start to finish. One subsection per workflow.}

### 5.{N} {Workflow Name}

**Who does this:** {Role}

1. {Step 1}
2. {Step 2}
3. {Step 3}

---

## 6. Integrations

{List any other systems this product connects to. Leave blank if none.}

| System   | What it does                            |
|----------|-----------------------------------------|
| {System} | {What data is sent or received and why} |

---

## 7. Known Limitations

{Intentional constraints or gaps users should know about. Not bugs — raise those as a BR.}

- {Limitation 1}
- {Limitation 2}

---

## 8. Linked Artefacts

| Type | Feature / Module | Path | Status |
|------|------------------|------|--------|
| BRD  |                  |      |        |
| TIP  |                  |      |        |
| TC   |                  |      |        |
