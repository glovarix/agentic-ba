---
name: brainstorm
description: Deep second-opinion sweep on a Change Request — saved, drafted, or still being discussed in the current session — covering cross-module ripple effects, recurring patterns elsewhere in the app, alternative implementations, and UX ideas. Use only when the user explicitly types /brainstorm — never proactively.
disable-model-invocation: true
---

# /brainstorm — Deep-Dive Sweep on a CR

Pressure-test a Change Request — whether it's still being discussed in the current session, fully drafted but not yet saved, or already saved — for the moments the user isn't 100% sure a CR is complete, or wants a deeper pass before it goes into a sprint. This command has no corresponding Rule in `CLAUDE.md` — treat this file as the source of truth. It never changes the CR mechanism itself (Rules 1, 3, 4, 5, 6, 8, 9, 11 all stay exactly as they are); it only surfaces ideas that may become separate, independent CRs later.

What this surfaces is, by definition, things it's fine to miss in the current iteration — gaps, ripple effects, and ideas that are genuinely acceptable to leave for later, not blockers that mean the original CR is incomplete or unfit to ship. Never frame a finding as a reason to hold back or revise the CR being brainstormed against; it only ever produces separate, optional, independently-scheduled candidates.

Catching blockers and core implementation feasibility problems is Rule 4's job. For a saved (or fully drafted) CR, that check has already run — `/brainstorm` does not re-run or duplicate it, and assumes it already passed. For a CR still being discussed and not yet drafted, that check simply hasn't happened yet, so treat anything that looks like an actual blocker as a sign it belongs in the CR's own sanity check once drafted, not in this sweep — say so plainly rather than folding it into the candidate list either way.

**Usage:** `/brainstorm [CR name, path, or slug]` — or run it with no argument on a CR still live in the current conversation, drafted or not yet saved.

Any of these count as a valid target — resolve in this order:
1. **A CR still being discussed in this conversation** — even if it isn't a complete draft yet, use the scope and content as shaped so far.
2. **A CR fully drafted earlier in this conversation but not yet saved** — use that draft directly, no need to save it first.
3. **A saved CR** — named, pathed, or picked from a list. If no argument is given and neither of the above applies, list recent files under `artefacts/change-requests/` (recurse into group folders; ignore `.zip`, `.pdf`, `.csv`) and ask the user to pick one.

This tool is invoked by explicit user command only — never run it proactively, even though it is a documented, public power tool like the others in Rule 0.

**Output format:** the sweep itself is free-form, not templated — use headings and bullets as the content calls for, whatever reads best. It is not bound by Rule 3's 400-word CR limit; treat roughly double that (around 800 words) as a soft ceiling for the sweep's own analysis, not a hard template. This is separate from Step 8's confirmed candidates, which are full CRs and follow Rule 3's 400-word limit and the CR template exactly, unchanged.

---

## Step 1 — Locate the target CR

Resolve the target using the order in Usage above: an in-progress discussion in this conversation, a completed-but-unsaved draft in this conversation, or a saved file (from the argument or the user's pick from the list). If it is a saved sub-CR inside a Rule 8 group folder, also read the master CR and any sibling sub-CRs for context. Read any BRD, TIP, or DIA sitting alongside it in the same folder — Rule 8 places supporting artefacts there too.

---

## Step 2 — Read the module registry

Read `artefacts/modules/modules.md` (fallback `context/modules.md`) — the same mandatory re-read every other artefact already applies. Identify the module(s) the CR's own scope most directly belongs to: its "home module."

---

## Step 3 — Deep read of the home module in `coderepo/`

Apply the standard codebase priority rule: read every project directory in `coderepo/`; if more than one exists and the user hasn't said which, ask. Read the actual logic, data model, and role checks behind the CR's in-scope items — real code, not a name-matching pass. This is the same depth Rule 4's sanity check already demands; do not go shallower here just because this is a follow-on tool.

---

## Step 4 — The sweep: four angles, all grounded in real code

Work through all four angles below before moving to Step 5. Each one only contributes an item if there's real evidence for it — never pad the sweep to make every angle produce something.

**4a — Cross-module ripple effects.**
Walk the full module list from Step 2. For each module other than the home module, check — using real code, the same discipline `.claude/commands/generate-ai-feature-dependency-map.md` already applies when mapping AI features to modules — whether this CR's change plausibly touches, feeds, or is fed by it: a shared table, a shared workflow, a cross-facility or cross-role interaction, a reporting/export consumer, a notification trigger. Discard modules with no real connection.

**4b — Same pattern, elsewhere in the app.**
A CR often fixes one specific instance of a general mistake — a mislabelled button, a missing validation check, an inconsistent permission rule, a wrong default value. State the underlying pattern this CR's fix represents in one general sentence (not the specific instance), then search `coderepo/` for other places that same pattern recurs, independent of module boundaries. Use real evidence — an actual matching file/function — not a guess that "there are probably more." If the pattern is narrow enough that nothing else plausibly matches, say so and move on.

**4c — Alternative implementations.**
Is there a materially different way to solve the same underlying problem this CR addresses — one already used elsewhere in the codebase for a similar case? Look for an existing pattern, helper, or check nearby that solves the same class of problem differently (e.g. a sibling mutation in the same router that already does the check this CR is adding, but slightly differently) and consider whether that alternative approach is worth surfacing instead of or alongside the CR's chosen approach.

**4d — UX ideas beyond the CR's literal scope.**
Given what's already technically feasible in this codebase (existing UI components, existing warning/inline-indicator patterns used elsewhere), is there a better user experience for the problem this CR solves than what it currently proposes — e.g. a proactive inline warning instead of a blocking error, surfacing the conflicting data at the point of entry rather than only on submit? Ground this in patterns that already exist in the app, not invented UI.

Keep a short internal list per angle: what was found, and why it's real (file/function evidence, or the specific existing pattern it's an alternative to).

---

## Step 5 — Interactive sweep, one item at a time

Run the sweep the same way `edge-360` runs its edge-case sweep — deliberately different in feel from the core CR flow's single confirm-and-save:

1. **One item at a time.** Raise a single item, then stop and wait. Do not batch multiple items into one message.
2. **Propose an answer.** For every item, give a recommended handling — the user is reacting to a proposal, not filling a blank.
3. **Look before asking.** If `coderepo/` already shows how the case is handled, say so and move straight to the next item rather than asking.
4. **Cover the sweep, then stop repeating it.** Don't re-raise an angle or connection that plainly doesn't apply.
5. **Don't act until confirmed.** Nothing gets drafted until the sweep is done and the user has reacted to every item.

Draw the sweep items from Step 4's four angles, plus Rule 17's own BA scenario categories applied to this CR's scope (mandatory-field gaps, format/boundary validation, length/character limits, dropdown/select requirements, list/search/empty states, destructive-action permission gaps) — use this repo's own established taxonomy rather than importing edge-360's engineering-flavoured categories (concurrency, timeouts) wholesale; translate only where a real BA-level equivalent exists.

Skip items that are really just implementation details of the CR's own build (e.g. how a query should be scoped) rather than a genuine separate ripple effect, recurrence, alternative, or UX idea — those aren't candidate-CR material, so don't raise them as sweep items at all.

For each item, the user's reaction is one of: agree with the proposed handling (no CR needed), flag it as needing its own CR, or wave it off as not a concern.

---

## Step 6 — Track candidates

Every item the user flags as needing its own CR goes onto a running candidate list: one-line title, home module, and rationale. Items waved off are dropped, not carried forward.

---

## Step 7 — Final candidate list

Once every item in the sweep has been through Step 5, present the full candidate list together and ask which of them (if any) to draft as real CRs now.

---

## Step 8 — Draft confirmed candidates using the existing CR mechanism

For each confirmed candidate, hand off to the standard CR flow exactly as `CLAUDE.md` already defines — do not re-implement any of it here:

- Rule 1 classification, Rule 3 writing standards (400-word limit included), `templates/CR-Change-Request.md`.
- Rule 4 sanity check against `coderepo/`.
- Rule 5 save path and filename: `artefacts/change-requests/{YYYY-MM-DD}-{slug}-CR.md`.
- Rule 9 module registry sync if the candidate touches a module not yet listed.
- Rule 11 ClickUp Source URL population if ClickUp MCP is available.

Each confirmed candidate is saved as its own **independent, standalone CR file** — reference the original CR by name in its Problem & Context section for traceability. Never merge a candidate into the original CR's scope, and never restructure the original into a Rule 8 group folder to hold it alongside the candidates. These are optional, separately-scheduled follow-ons, not sprint-bundled sub-issues — the original CR file is never touched or moved.

---

## Notes

- Does not modify the CR it is run against.
- Does not touch `CLAUDE.md`, `templates/`, `README.md`, `QUICKSTART.md`, or `website/`.
- `disable-model-invocation: true` means this only ever runs when the user explicitly types `/brainstorm` — never triggered proactively based on conversation content.
