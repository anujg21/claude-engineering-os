# Hooks

Hooks are the deterministic layer. Instructions in CLAUDE.md are advisory: Claude reads
them and usually follows them. A hook runs as a shell command at a fixed lifecycle event
and applies regardless of what Claude decides. Anything that must happen every time, with
no exceptions, belongs here. Anything that requires judgement belongs in a skill.

## What is wired up

| Event | Script | Effect | Plugin | install.sh |
| --- | --- | --- | --- | --- |
| `SessionStart` | `session-context.sh` | Injects `docs/project/STATE.md`, git status, and open ADR count so a cold session knows where the work stands. | yes | yes |
| `PreToolUse(Bash)` | `guard-commands.sh` | Denies destructive commands, prompts on production-touching ones. | yes | yes |
| `PreToolUse(Write\|Edit\|MultiEdit)` | `block-secrets.sh` | Denies writes that contain credential material. | yes | yes |
| `PostToolUse(Write\|Edit)` | `format-file.sh` | Formats the file that was just written. Never blocks. | **no** | yes |

The formatter is deliberately absent from the plugin. A plugin is installed once and
applies to every repository you open, and silently reformatting files in a project that
never chose a formatter is worse than not formatting at all. It is wired only by
`templates/project-settings.json`, which lands in `.claude/settings.json` when you use
`install.sh` or `/adopt`, so the project opts in.

Plugin configuration is `hooks/hooks.json`; project configuration is
`.claude/settings.json`. Scripts share `lib.sh`, which reads the hook's JSON payload using
`jq` or `python3`, whichever is installed.

## Verdicts

`guard-commands.sh` and `block-secrets.sh` return one of two decisions:

- **deny** for commands with no legitimate autonomous use: recursive deletes of root or
  home, `DROP TABLE`, unscoped `DELETE`, `terraform destroy`, piping a download into an
  interpreter. Claude sees the reason and has to find another route.
- **ask** for commands that may well be correct but where a human owns the call: force
  pushes, production datastore access, publishing, cloud resource deletion, removing
  Docker volumes. The permission prompt goes to you with the reason attached.

The split matters. Denying everything risky trains Claude to work around the guard.
Prompting gives you the decision at the moment it is needed.

Valid `permissionDecision` values are `allow`, `deny`, `ask`, and `defer`. Anything else
fails schema validation, and a rejected decision is discarded, which means the command
runs as though the hook never spoke. If you add a verdict, use one of those four.

## What these are not

They are pattern matchers over command text and file content. They will miss tooling they
do not know by name, and anyone who wants to get around them can. Specifically:

- `guard-commands.sh` normalizes case, line continuations, and whitespace before matching,
  but it cannot resolve variables, aliases, or a script that wraps the real command.
- `block-secrets.sh` covers common credential shapes. It cannot see content written by
  Bash redirection (`cat > .env`, `printf >> config.py`, `sed -i`), because that is a
  Bash call, not a Write. Keep a real secret scanner in your pipeline.
- Neither replaces permission rules. `Read` deny rules in `.claude/settings.json` stop the
  Read tool; they do not stop `cat .env` through Bash.

Treat all of it as defense in depth. The approval gates in CLAUDE.md are the actual rule.

## `format-file.sh` runs a repo-local script

If `scripts/format.sh` exists and is executable in the project, this hook runs it after
every write, with no permission prompt, because hooks are not tool calls. That is
convenient in your own repository and a hazard in someone else's: cloning an untrusted
repo and opening Claude Code in it is enough to execute that file.

If you review pull requests from outside your organization, either drop the `PostToolUse`
entry from `.claude/settings.json` or check what `scripts/format.sh` contains first.

## Optional: a stop gate

To make verification non-negotiable rather than merely instructed, add a `Stop` hook that
blocks the turn from ending until checks pass:

```json
"Stop": [
  {
    "hooks": [
      { "type": "command", "command": "${CLAUDE_PROJECT_DIR}/scripts/verify.sh --hook" }
    ]
  }
]
```

The `--hook` flag matters: a Stop hook only blocks on exit code 2, and `verify.sh` exits 1
on ordinary failure. Without it the gate reports an error and lets the turn end anyway.

A block hands the output back to Claude, which then fixes the failure and tries again.
Claude Code overrides the hook after eight consecutive blocks so a broken check cannot
trap the session. This is off by default because a slow test suite makes every turn slow.
Turn it on for unattended runs.

## Adding a hook

Keep each script single-purpose, fast, and quiet on the happy path. Source `lib.sh` for
`json_get`, `deny`, and `escalate`. Test it by hand before wiring it up:

```bash
echo '{"tool_input":{"command":"terraform destroy"}}' | hooks/guard-commands.sh
```

The expected output is a JSON object with a `permissionDecision`. No output plus exit 0
means the hook had no opinion, which is the correct result for most calls.

## Tuning

The command patterns are conservative but generic. Adapt them to your stack: add your
deployment CLI, your migration tool, the names of your production contexts. A guard that
fires on ordinary work gets disabled, which is worse than no guard at all.
