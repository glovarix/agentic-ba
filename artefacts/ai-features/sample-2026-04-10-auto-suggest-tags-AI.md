# AI Tag Suggestion from Todo Title

## Summary

When a user creates or edits a todo, the app analyses the todo `title` and suggests relevant tags from the user's existing tag library. Suggestions appear inline beneath the title field as clickable chips. The user can accept, ignore, or dismiss them. This reduces the manual effort of tagging and improves consistency across a user's todo list over time.

## Problem & Context

Users with established tag libraries (e.g. "Work", "Urgent", "Home", "Finance") frequently forget to tag new todos, or apply tags inconsistently. This makes filtering and reporting unreliable. An AI suggestion layer — operating purely on the todo title and the user's existing tags — can surface the right tags at the moment of creation without requiring the user to think about it.

## User Story

As a member, I want the app to suggest tags when I type a todo title so that my todos are consistently tagged without extra effort.

## In Scope Checklist

- [ ] Suggest up to 3 tags from the user's existing tag library based on the todo `title`
- [ ] Suggestions appear below the title input after the user pauses typing (500ms debounce)
- [ ] Each suggestion is a clickable chip — clicking it adds the tag to the todo
- [ ] User can dismiss all suggestions without applying any
- [ ] Suggestions are generated server-side via a call to an LLM API
- [ ] No suggestion is saved automatically — user action required

## Out of Scope

- Creating new tags via suggestion (only existing user tags are surfaced)
- Suggestions based on `description` field (title only in v1)
- Learning from user acceptance/rejection history (v2)
- Suggestions for todos being edited (create flow only in v1)

## Input Data

| Data point       | Source              | Passed per call |
|------------------|---------------------|-----------------|
| `title`          | Todo form input     | Always          |
| User's tag list  | `GET /api/tags`     | Full list (name + `_id`) |

Tag list is fetched once when the form loads and cached client-side for the session. It is not re-fetched per keystroke.

## Prompt(s)

(placeholder — link to prompt management system or paste prompt here before dev begins)

Indicative prompt structure:
```
You are a tagging assistant. Given a todo title and a list of available tags, return up to 3 tag names from the list that are relevant to the title. Return only tag names from the provided list. Return a JSON array of strings. Return an empty array if no tags are relevant.

Tags: {comma-separated list of user tag names}
Todo title: "{title}"
```

## Models and Fallback Models

| Role    | Model                          |
|---------|--------------------------------|
| Primary | `claude-haiku-4-5-20251001` (fast, low cost for short classification tasks) |
| Fallback | Return empty suggestions silently — do not block todo creation |

## Execution Settings

- **Max tokens:** 50 (tag names only — no prose)
- **Temperature:** 0 (deterministic output)
- **Timeout:** 2 seconds — if exceeded, return no suggestions silently
- **Trigger:** Client-side, 500ms after the user stops typing in the title field

## Grounding Data

None — suggestions are drawn entirely from the user's own tag library. No external knowledge base required.

## Design & Media for App Integration

(placeholder — Figma link to be added by Design team before FE implementation begins)

- Suggestions render as coloured chips below the title input, using the tag's `colour` field
- Dismissed suggestions do not reappear during the same form session

## Integration Plan

1. Add `POST /api/tags/suggest` endpoint — accepts `{ title, tags: [{ _id, name }] }`, returns `{ suggestions: [{ _id, name, colour }] }`
2. Endpoint calls LLM, maps returned names back to tag objects, returns matched tags
3. Frontend calls endpoint on debounced title change, renders suggestion chips
4. Clicking a chip appends the tag `_id` to the todo form's `tags` array

## Acceptance Criteria (AI QA Team)

- [ ] Typing "Buy groceries and milk" with tags ["Shopping", "Home", "Work"] returns ["Shopping", "Home"]
- [ ] Typing a title with no relevant tags returns an empty array — no chips displayed
- [ ] LLM timeout or error returns empty array — todo creation is unaffected
- [ ] Suggestions never include tags not in the user's tag library
- [ ] No more than 3 suggestions are returned per call
- [ ] Accepted suggestion appears in the todo's `tags` field on save

## Video Walkthrough

(placeholder)
