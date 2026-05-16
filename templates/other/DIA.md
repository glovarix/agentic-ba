# Diagram: {Title}

> **Status:** DRAFT | IN REVIEW | APPROVED
> **Artefact ID:** `{YYYY-MM-DD}-{title-slug}-DIA`
> **Type:** Flowchart / Sequence / ER / State / User Journey
> **Linked artefact:** [{CRT or BRD filename}](../issues/changes/{filename}.md)
> **Author:** Claude (AI) — **Verified by:** {Name / Role}
> **Date:** {YYYY-MM-DD}

---

## Purpose

{1–2 sentences: what this diagram shows, why it was created, and who the intended audience is.}

---

## Diagram

```mermaid
%% Replace with the appropriate diagram type.
%% Common types: flowchart LR, sequenceDiagram, erDiagram, stateDiagram-v2, journey

flowchart LR
    A[{Start — e.g. User logs in}] --> B{Decision point}
    B -- Yes --> C[{Outcome A}]
    B -- No --> D[{Outcome B}]
    C --> E[{End state}]
    D --> E
```

---

## Key

{Explain any non-obvious symbols, colours, or groupings used in the diagram. Delete this section if the diagram is self-explanatory.}

- {Symbol or shape} — {what it represents}
- {Arrow style} — {what it means}

---

## Notes & Assumptions

- {Any decisions made in drawing the diagram that the reader should know about}
- {Any flows or states that are out of scope for this diagram}

---

## Revision History

| Version | Date         | Author      | Summary         |
|---------|--------------|-------------|-----------------|
| 1.0     | {YYYY-MM-DD} | Claude (AI) | Initial diagram |
