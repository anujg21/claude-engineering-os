# Project state

Last updated: 2026-08-29

Replace this content the moment a real project starts. Right now it describes the system
itself, which is the only honest thing it can say.

## Now

Phase: not started, for any consuming project.
Active plan: none.
Working on: nothing. This repository is the engineering operating system, not a project.

Install it with the plugin commands in README.md, then run `/adopt` in the repository you
want to use it on.

## Done

| Date | What | Evidence |
| --- | --- | --- |
| 2026-08-29 | Added a `/guide` skill: reads `docs/project/STATE.md`, interviews the user in one short round, and routes them to the right skill instead of leaving them to read the lifecycle doc. Wired into `CLAUDE.md`'s routing table, `README.md`, `docs/GUIDE.md`, and `/adopt`'s final report. | `skills/guide/SKILL.md` |
| 2026-08-20 | Fixed every blocking finding from the internal review pass: the `escalate` verdict, uninstall data loss, secret-scanner recall, and the `rm -rf` deny gaps. | Commit history |
| 2026-08-20 | Packaged as a Claude Code plugin: two-command install, `/adopt` performs the setup instead of describing it, `install.sh` for the committed path. | `claude plugin details engineering-os` reports 14 skills, 4 agents, 2 hook events |
| 2026-08-19 | System scaffolded: 14 skills, 4 reviewer agents, 6 path-scoped rule sets, 4 hooks, 11 templates, lifecycle documentation. | This repository |

## Next

1. Use it on a real codebase and record what breaks. Nothing here has survived contact
   with a project yet.
2. Decide whether the reviewer agents should run in CI on human pull requests.
3. Revisit the `deny` and `ask` pattern lists once real usage shows what they miss and
   what they trip on wrongly.

## Blocked

| What | Blocked on | Since | Owner |
| --- | --- | --- | --- |
| Nothing | | | |

## Decisions

| ADR | Decision | Date |
| --- | --- | --- |
| [0001](../decisions/0001-record-architecture-decisions.md) | Record architecture decisions as ADRs | 2026-08-19 |

## Assumptions

| Assumption | What breaks if wrong | How to confirm |
| --- | --- | --- |
| `jq` or `python3` is on the machine | The hooks fall back to matching raw JSON, which is coarser | `./scripts/setup.sh` reports which one it found |
| Plugin `agents/` must sit at the repo root | The agents load as zero, silently, while validation still passes | `claude plugin details engineering-os` shows Agents (4) |

## Risks and open items

| Item | Impact | Owner | Decision |
| --- | --- | --- | --- |
| The hooks match command text, so they miss tooling they do not know by name and can be evaded deliberately | A destructive command could pass the guard | Adopter | Documented as a backstop in `hooks/README.md`; the approval gates in CLAUDE.md are the real control |
| `block-secrets.sh` cannot see files written through Bash redirection | A credential written by `cat > .env` is not caught | Adopter | Keep a real secret scanner in the pipeline |
| `Read` deny rules do not bind Bash, so `cat .env` still works | Secrets readable despite the deny list | Adopter | Documented in `hooks/README.md` |
| The shipped `verify.sh` auto-detects and will guess wrong on unusual setups | Every "done" claim depends on this script | Adopter | `/adopt` replaces it with the project's real commands |
| Nothing here has been used on a real project yet | Unknown | Owner | Adopt it somewhere and find out |
