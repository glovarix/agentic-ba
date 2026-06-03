# coderepo

This folder holds the codebase(s) the agent reads when generating artefacts.

## Using your own codebase

Drop your codebase into this folder (e.g. `coderepo/my-project/`). Git will ignore it automatically — your code will never be committed or pushed.

Do not add a `.gitignore` exception for your codebase. This is intentional.

## What is and is not committed

Nothing inside `coderepo/` is committed except this README. Everything you add here is ignored by `.gitignore`.

If you accidentally add a real codebase and are unsure whether it has been staged, run `git status` before committing.
