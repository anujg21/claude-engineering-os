# Hooks

Hooks are the deterministic layer. Instructions in CLAUDE.md are advisory: Claude reads
them and usually follows them. A hook runs as a shell command at a fixed lifecycle event
and applies regardless of what Claude decides. Anything that must happen every time,
with no exceptions, belongs here. Anything that requires judgement belongs in a skill.

## What is wired up

| Event | Script | Effect |
| --- | --- | --- |
| `SessionStart` | `session-context.sh` | Injects `docs/project/STATE.md`, git status, and open ADR count so a cold session knows where the work stands. |
| `PreToolUse(Bash)` | `guard-commands.sh` | Denies destructive commands, escalates production-touching ones to the human. |
| `PreToolUse(Write\|Edit)` | `block-secrets.sh` | Denies writes that contain credential material. |
| `PostToolUse(Write\|Edit)` | `format-file.sh` | Formats the file that was just written. Never blocks. |

Configuration lives in `.claude/settings.json`. Scripts share `lib.sh`, which reads the
hook's JSON payload using `jq` or `python3`, whichever is installed.

## Verdicts

`guard-commands.sh` and `block-secrets.sh` return one of two decisions:

- **deny** for commands with no legitimate autonomous use: recursive deletes of root or
  home, `DROP TABLE`, unscoped `DELETE`, `terraform destroy`, piping a download into a
  shell. Claude sees the reason and has to find another route.
- **escalate** for commands that may well be correct but where a human owns the call:
  force pushes, production datastore access, publishing, cloud resource deletion. The
  permission prompt goes to you with the reason attached.

The split matters. Denying everything risky trains Claude to work around the guard.
Escalating gives you the decision at the moment it is needed.

## Optional: a stop gate

To make verification non-negotiable rather than merely instructed, add a `Stop` hook that
blocks the turn from ending until checks pass:

```json
"Stop": [
  {
    "hooks": [
      { "type": "command", "command": "${CLAUDE_PROJECT_DIR}/scripts/verify.sh --quiet" }
    ]
  }
]
```

A non-zero exit blocks the stop and hands the output back to Claude, which then fixes the
failure and tries again. Claude Code overrides the hook after eight consecutive blocks so
a broken check cannot trap the session. This is off by default because a slow test suite
makes every turn slow. Turn it on for unattended runs.

## Adding a hook

Keep each script single-purpose, fast, and quiet on the happy path. Source `lib.sh` for
`json_get`, `deny`, and `escalate`. Test it by hand before wiring it up:

```bash
echo '{"tool_input":{"command":"terraform destroy"}}' | .claude/hooks/guard-commands.sh
```

The expected output is a JSON object with a `permissionDecision`. No output plus exit 0
means the hook had no opinion, which is the correct result for most calls.

## Tuning

The command patterns are conservative but generic. Adapt them to your stack: add your
deployment CLI, your migration tool, the names of your production contexts. A guard that
fires on ordinary work gets disabled, which is worse than no guard at all.
