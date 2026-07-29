---
name: file-for-later
description: File raw notes, a brainstormed idea, or an in-progress/unfinished Change Request into artefacts/change-requests/BA-backlog/ for later — either as a plain backlog list of candidate CRs or as a parked CR draft. Use only when the user explicitly types /file-for-later — never proactively.
disable-model-invocation: true
---

# /file-for-later — File Something to the CR Backlog

`artefacts/change-requests/BA-backlog/` already exists as a standing, unstructured holding area for unfinished change-request work (Rule 20 in `CLAUDE.md`). This command is the explicit, repeatable way to invoke that filing behaviour on demand, instead of doing it ad hoc each time — nothing about Rule 20 itself changes; this just gives it a name.

**Usage:** `/file-for-later [raw notes, a topic, or "this"]` — or paste raw text directly after the command: meeting notes, a brainstorm dump, a client call transcript, a half-formed feature ask. Use `"this"` (or no argument) to park a CR that's already being discussed or fully drafted in the current conversation but isn't ready to finalise yet.

Work out which of the two modes below applies before doing anything else. If it's genuinely unclear, ask.

---

## Mode A — Backlog list (raw notes or ideas, nothing drafted yet)

**Trigger:** the input describes one or more untested, unscoped ideas — a meeting recap, a Slack thread, a list of "we should also…" items — with no full CR drafted yet.

1. If the input reads like verbatim source material worth preserving as-is (call notes, a transcript, a long client message), offer to save it unedited to `context/meeting-notes/{YYYY-MM-DD}-{slug}.md` before continuing — `context/` is free-form, private, and never published (Rule 14). Skip this offer for a short one-line ask; it isn't worth a separate file.
2. Pull every distinct candidate topic out of the input. Set aside anything that actually reads as a bug — flag it in your response as "raised as a bug — file as a BR when ready" rather than adding it to the CR backlog list; `BA-backlog/` is CR-scoped.
3. Run the Rule 19 dedup check on every candidate — grep `artefacts/change-requests/` in full, including `BA-backlog/`, `Archive/`, `UnSorted/`, and epic folders. Sort the results into: new, already covered (cite the existing file), and partially covered (state the delta).
4. Present the sorted list to the user before saving anything, consistent with `confirmBeforeGenerate`.
5. On confirmation, save the list as plain markdown to `artefacts/change-requests/BA-backlog/{YYYY-MM-DD}-{slug}-cr-backlog.md`. No template — group it however reads clearest (e.g. new candidates / already covered / pending decisions), matching the style of an existing backlog list in that folder if one exists.

## Mode B — Park a drafted CR (not ready to finalise or push)

**Trigger:** the user has a specific CR already drafted — live in this conversation, pasted in full, or referenced by `"this"` — and wants it saved without finalising it in the normal location yet.

1. Resolve the target the same way `/brainstorm-change` and `/visualize-change` do: a CR still being discussed in this conversation, a completed-but-unsaved draft from this conversation, or an existing saved CR the user wants moved into the backlog.
2. Parking a CR does not skip Rule 4's sanity check — run it if it hasn't already run in this conversation.
3. Confirm with the user before saving, consistent with `confirmBeforeSave`.
4. Save using the standard CR filename pattern (Rule 5, Rule 8) inside `artefacts/change-requests/BA-backlog/` — a single file, or a feature subfolder for a group folder per Rule 8.
5. Tell the user it now lives in the backlog until it's finalised and, if applicable, pushed to GitHub — at which point it moves to its normal home in `artefacts/change-requests/` (Rule 20). Nothing about the CR itself is marked as draft inside the file — the folder location is the only signal.

---

This command never bypasses Rule 19 (duplicate check) or Rule 4 (sanity check) — filing something for later is not a shortcut around verification, only a deferral of finalisation.
