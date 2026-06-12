#!/usr/bin/env node
// ABAF (Baxter) PreToolUse guard.
// Enforces CLAUDE.md rules mechanically before a tool runs:
//   - templates/  is read-only (Rule 6)            -> deny Write/Edit
//   - coderepo/   is private read-only source       -> deny Write/Edit
//   - preferences.json must be edited only on request -> ask
//   - dangerous shell commands                      -> deny Bash
// Anything else is allowed. Reads the hook payload as JSON on stdin and
// emits a PreToolUse permission decision as JSON on stdout.

import { relative, isAbsolute, basename, resolve } from 'node:path';

function decide(permissionDecision, permissionDecisionReason) {
  process.stdout.write(
    JSON.stringify({
      hookSpecificOutput: {
        hookEventName: 'PreToolUse',
        permissionDecision,
        permissionDecisionReason,
      },
    }),
  );
  process.exit(0);
}

function allow() {
  // Emitting nothing and exiting 0 lets Claude Code's normal flow proceed.
  process.exit(0);
}

let raw = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', (chunk) => {
  raw += chunk;
});
process.stdin.on('end', () => {
  let data;
  try {
    data = JSON.parse(raw || '{}');
  } catch {
    // If we cannot parse the payload, do not block the user.
    allow();
  }

  const tool = data.tool_name || '';
  const input = data.tool_input || {};
  const projectDir = process.env.CLAUDE_PROJECT_DIR || process.cwd();

  // --- File-writing tools -------------------------------------------------
  if (tool === 'Write' || tool === 'Edit' || tool === 'MultiEdit') {
    const filePath = input.file_path || '';
    if (!filePath) allow();

    const abs = isAbsolute(filePath) ? filePath : resolve(projectDir, filePath);
    let rel = relative(projectDir, abs);
    // Normalise Windows-style separators just in case.
    rel = rel.split('\\').join('/');

    if (rel === 'templates' || rel.startsWith('templates/')) {
      decide(
        'deny',
        'templates/ is read-only (CLAUDE.md Rule 6). Never modify template files — write the output to artefacts/ instead.',
      );
    }

    if (rel === 'coderepo' || rel.startsWith('coderepo/')) {
      decide(
        'deny',
        'coderepo/ is your private, read-only source. Baxter reads it to sanity-check artefacts but must never write to it.',
      );
    }

    if (basename(abs) === 'preferences.json' && !rel.includes('/')) {
      decide(
        'ask',
        'About to edit preferences.json. Per CLAUDE.md, only change it when the user has explicitly asked. Confirm to proceed.',
      );
    }

    allow();
  }

  // --- Shell ---------------------------------------------------------------
  if (tool === 'Bash') {
    const cmd = String(input.command || '');

    // rm -rf / -fr (flags in any order/combination)
    if (/\brm\s+-\w*r\w*f\w*\b/.test(cmd) || /\brm\s+-\w*f\w*r\w*\b/.test(cmd)) {
      decide('deny', 'Blocked: "rm -rf" style recursive force-delete. Remove specific paths deliberately instead.');
    }

    // git push --force / -f / --force-with-lease
    if (/\bgit\s+push\b/.test(cmd) && /(--force\b|--force-with-lease\b|\s-f\b)/.test(cmd)) {
      decide('deny', 'Blocked: force push. Force-pushing can overwrite shared history — do this manually if truly intended.');
    }

    // git reset --hard
    if (/\bgit\s+reset\s+--hard\b/.test(cmd)) {
      decide('deny', 'Blocked: "git reset --hard" discards uncommitted work irreversibly. Run it yourself if you mean to.');
    }

    allow();
  }

  allow();
});
