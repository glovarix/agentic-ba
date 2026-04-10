# Bulk Delete Todos

## Summary

Users with large todo lists have no way to delete multiple todos at once. Removing items one by one is slow and frustrating, particularly when clearing completed or archived todos after a sprint or project close-out. This change adds a bulk delete action that allows members to select multiple todos and delete them in a single operation.

## Problem & Context

The current `DELETE /api/todos/:id` endpoint deletes a single todo per request. There is no multi-select or batch operation in the API or frontend. Users who complete a project and want to archive or remove a set of todos must delete them one at a time, which is a friction point reported repeatedly by power users.

## User Story

As a member, I want to select multiple todos and delete them in one action so that I can clear my list quickly without repeating the same operation for every item.

## In Scope Checklist

- [ ] New endpoint: `DELETE /api/todos` accepting an array of todo IDs in the request body
- [ ] Ownership check: only delete todos owned by the authenticated user — silently skip any IDs that do not belong to the user
- [ ] Frontend: multi-select mode on the todo list with a "Delete selected" button
- [ ] Frontend: confirmation prompt before bulk delete executes
- [ ] Response: return count of deleted todos

## Out of Scope

- Bulk status change (e.g. bulk complete, bulk archive) — separate CR
- Admin bulk delete across all users — not in this request
- Undo / restore after bulk delete

## Design & Media

(placeholder — Figma link to be added by Design team)

## Acceptance Criteria (QA Team)

- [ ] `DELETE /api/todos` with `{ "ids": ["id1", "id2"] }` deletes all matching todos owned by the authenticated user and returns `{ "deleted": 2 }`
- [ ] IDs that do not belong to the authenticated user are ignored — no 403, no partial failure
- [ ] IDs that do not exist are ignored — no 404
- [ ] At least one valid owned ID must be present — returns 400 if `ids` array is empty or missing
- [ ] Frontend shows a confirmation dialog before executing bulk delete
- [ ] After deletion, the todo list refreshes and removed items are no longer visible

## Technical Notes (Dev Team)

- Use `Todo.deleteMany({ _id: { $in: ids }, owner: req.user._id })` — ownership scoping is built into the query, not a separate check
- Validate that `ids` is a non-empty array of valid MongoDB ObjectId strings before executing — return 400 otherwise
- The existing `authenticate` middleware in `backend/middleware/auth.js` covers authentication — no additional auth logic required

## Final Working Loom URL

(placeholder)

## Source Request URL

(placeholder — Slack / ClickUp / email link)
