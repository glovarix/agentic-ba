# Product Documentation (PD)

> **Status:** DRAFT | REVIEWED 
> **Product:** {Product Name} | **Version:** {v2.4} | **Date:** {YYYY-MM-DD}

---

## Overview

{What it does, who uses it, problem solved. 2–3 sentences max.}

**Default roles:** [Pulled from codebase role registry — each as Display Name (`code_identifier`)]  
**Related modules:** [Pulled from module registry — names and groupings exactly as the registry has them]

---

## App Flow

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

## Features by Role

Column headers are the role registry's roles, each written Display Name (`code_identifier`). Use one column per role the product actually has — not five.

| Feature | What it does | {Role 1} (`{role_1_code}`) | {Role 2} (`{role_2_code}`) | {Role 3} (`{role_3_code}`) | Notes |
|---------|-------------|---------|---------|---------|-------|
| {Feature A} | {Specific capability} | View | Create/Edit | — | {E.g. "User edits own records only"} |
| {Feature B} | {Specific capability} | Create | Create/Edit | View | {E.g. "Requires approval"} |
| {Feature C} | {Specific capability} | View | View/Edit | Create/Edit | {E.g. "Auto-syncs to linked module"} |

---

## Module Connections

**Outbound to:**
- {Related Module Name}: Sends {what data or payload} when {trigger event} — {impact or dependency}
- {Related Module Name}: Triggers {action} when {trigger event} — {validation or requirement}

**Inbound from:**
- {Related Module Name}: Receives {what data or payload} when {trigger event} — {how it's used or consumed}
- {Related Module Name}: Syncs {what data or payload} continuously — {real-time or batch sync}

---

## Notifications & Triggers

- **{Event name}** (triggered by {role or user action}): Notifies {recipient role} via {in-app / email / SMS / webhook} — {what message conveys}
- **{Event name}** (triggered by {role or user action}): Notifies {recipient role} via {in-app / email / SMS / webhook} — {what message conveys}
- **{Event name}** (triggered by {role or user action}): Notifies {recipient role} via {in-app / email / SMS / webhook} — {what message conveys}

---

## Known Limitations

- {Constraint — e.g. "Bulk imports limited to 1,000 records per file"}
- {Constraint — e.g. "Offline sync not supported; requires active connection"}
- {Constraint — e.g. "Manual approval required for all deletions; no undo"}
- {Constraint — e.g. "Data exports limited to last 90 days"}