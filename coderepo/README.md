# coderepo

This folder holds the codebase(s) the agent reads when generating artefacts.

## Default learning codebase

**`todo-react/`** is the bundled example codebase. It is the only directory committed to this repository. Use it to learn and test the agentic-ba system.

Source: https://github.com/binu-alexander/todo-react

## Using your own codebase

Drop your codebase into this folder (e.g. `coderepo/my-project/`). Git will ignore it automatically — your code will never be committed or pushed.

Do not add a `.gitignore` exception for your codebase. This is intentional.

## What is and is not committed

| Directory | Committed? |
| --- | --- |
| `todo-react/` | Yes — bundled example |
| Anything else | No — ignored by `.gitignore` |

If you accidentally add a real codebase and are unsure whether it has been staged, run `git status` before committing.
