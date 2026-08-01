# /visualize-change — Interactive CR Prototype

This command has no corresponding Rule in `CLAUDE.md` — treat this file as the source of truth.

**Usage:** `/visualize-change [CR name, path, or "this" for the CR being drafted in this session]`

Covers both a brand-new feature CR and an incremental change to something that already exists — Step 2 below determines which case applies and adjusts accordingly.

Produces a single, self-contained, clickable HTML prototype that demonstrates the functionality, features, and logic of a Change Request — not a visual design deliverable.

**Scope gate (mandatory):** this tool only ever prototypes a real CR. It is not a general "mock me up an idea" tool. If the user's request is not tied to an existing saved CR or a CR actively being drafted in this session, do not build anything — ask them to point to the CR (or draft/save one first via the normal CR flow) before invoking this command.

---

## Step 1 — Resolve the source CR

1. If a saved CR name or path is given, read it from `artefacts/change-requests/`.
2. If the user means the CR currently being drafted in this chat session, use that draft directly.
3. If the CR is a group folder (master CR + sub-CRs, Rule 8), read the master and every sub-CR to understand the full scope before building anything.
4. **Mandatory gate:** if the source CR exists only in the chat session and has not been saved as an artefact yet, stop and prompt the user to save the CR first (per Rule 5). An unsaved CR means the prototype has no artefact to link back to and becomes orphaned. Proceed with the prototype only once the CR is saved, or the user explicitly confirms they want a standalone prototype anyway.

---

## Step 2 — Ground the prototype in the real product (mandatory — not blue-sky)

**This is never a from-scratch mockup.** A CR almost always modifies or extends something that already exists and works in `coderepo/`. Prototyping in isolation — inventing a plausible-looking screen without checking what's actually there — produces something that looks like a different product and misleads the reviewer.

1. Apply the standard codebase priority rule (Rule 4): read every project directory in `coderepo/`; if more than one exists and the user has not said which to use, ask.
2. **Identify the module(s) the CR belongs to first**, against `artefacts/module-registry/modules.md` (Rule: always re-read before acting) and the matching area of `coderepo/`. This is the anchor for everything else — it determines which real screens, field names, data shapes, and personas the prototype must be faithful to. For a group folder (master CR + sub-CRs, Rule 8) or any CR spanning several modules, identify every module touched before building anything, so the prototype reads as one coherent flow through the real product rather than disconnected fragments.
3. For a large CR or group folder, the prototype must still be functional end-to-end and still grounded in the real modules identified above — it does not need to reuse the app's actual frontend stack — whatever the real product is built in, the prototype is always Alpine/Vue per Step 3 but its flow, feature set, data points, and personas must match what those real modules actually contain. A technology mismatch is fine; a product mismatch is not.
4. Identify the existing feature, screen, or flow the CR touches, and read its real implementation — current UI structure, field names, states, wording, and data shapes. If the feature is genuinely new (no existing equivalent in `coderepo/`), say so explicitly before proceeding — this is the only case where more creative latitude is appropriate for the new screen's *content*.
5. **Even a genuinely new feature must never float free of the app.** Read the real navigation, layout shell, and the nearest existing parent screen (e.g. the encounter dashboard, the profile page, the module it will be launched from) and embed the new feature inside that real context — real header, real entry point, real surrounding chrome. A prototype that opens on a blank page unconnected to anything in `coderepo/` fails this step, even if every control inside it is faithful to the CR. The prototype always depicts one CR living inside the one app found in `coderepo/` — never a generic or standalone product.
6. Build the prototype as a faithful extension of that existing reality: reuse the real screen layout, terminology, and states as the baseline, then layer in only what the CR adds or changes. New states the CR introduces should be visually distinguishable from the existing baseline (e.g. a "new in this CR" marker or note), so a reviewer can see at a glance what's already live versus what's being proposed.
7. From the CR's User Story, In Scope Checklist, and Acceptance Criteria, identify every distinct interactive behaviour, state, rule, and edge case that needs to be shown working — not just static screens.
8. Cross-check field, role, and module names against `artefacts/module-registry/modules.md` so the prototype uses real product terminology.
9. Do not invent functionality beyond what the CR describes and what the existing code already supports. Where the CR is ambiguous, make the simplest reasonable assumption and record it as an HTML comment at the top of the file.

---

## Step 3 — Build the single HTML file

- One self-contained `.html` file. All JS/CSS libraries load via CDN `<script>`/`<link>` tags inside that same file — no separate assets, no build step, no bundler.
- Use **Alpine.js** (CDN) by default for interactivity. Escalate to **Vue 3** (CDN, no build step) only if the CR's state or logic genuinely needs it. Never React or another heavy framework.
- UI is clean, compact, and modern, but intentionally bare-minimum — system font stack, simple spacing and colour, no design system. This is not a high-fidelity design exercise: the goal is that every rule, state, and flow in the CR is clickable and observable, nothing more.
- Demonstrate every In Scope checklist item and every Acceptance Criterion as a triggerable interactive state — not just the happy path.

---

## Step 4 — Save

1. Default save path: `artefacts/change-visualisations/`.
2. If the source CR is a group folder (Rule 8), or the prototype is large enough to reasonably cover several related CRs, ask the user whether to use a single subfolder — `artefacts/change-visualisations/{feature-slug}/` — for all related prototype files, instead of separate top-level files. Wait for confirmation before choosing.
3. Filename pattern: `{YYYY-MM-DD}-{feature-slug}-prototype.html`.
4. Respect `confirmBeforeSave` — confirm the filename and path before writing.

---

## Step 5 — Hand back

Report the saved file as a clickable markdown link. Do not generate a PDF or any other export — the HTML file is the only deliverable.
