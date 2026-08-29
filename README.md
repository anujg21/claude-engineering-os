# claude-engineering-os

A repository template that gives Claude Code a working method: phases that produce
documents, standards that load only when relevant, reviews done by an agent that did not
write the code, and hooks that stop or prompt on the dangerous commands.

Technology-agnostic. Works for a new project or an existing one.

## Why

Claude starts every session with no memory and a context window that gets worse as it
fills. Without structure it solves the wrong problem well, drops constraints nobody wrote
down, and says work is done without checking.

## Install

Inside Claude Code:

```
/plugin marketplace add anujg21/claude-engineering-os
/plugin install engineering-os@claude-engineering-os
```

Then, in whichever repository you want to use it on:

```
/adopt
```

`/adopt` reads the project, writes a `verify.sh` that runs your real commands, points the
rules at your actual directories, and appends to your `CLAUDE.md` rather than replacing it.
Add `--check` to see what it would do without writing anything.

Not sure what to run next? `/guide` asks a couple of questions about what you are trying
to do and points you at the one command that fits.

That is the whole install. The plugin is per-developer and updates when this repo does,
which also means its hook scripts run on your machine and change when the repo changes.
That is the normal Claude Code plugin model, but it is a trust decision worth making
knowingly. Pin a tag, or use the committed install below, if you would rather review
changes before they run.

### If the config should live in the repo instead

So that teammates get it from a clone without installing anything:

```bash
git clone https://github.com/anujg21/claude-engineering-os ~/engineering-os
cd my-project
~/engineering-os/install.sh          # copies the files, touches nothing you wrote
claude
```

Then run `/adopt` to fill in the parts a copy cannot work out. `install.sh --uninstall`
reverses it.

## The flow

```
/guide       not sure which of these fits, ask it and it points you at one
/discovery   idea to brief and requirements
/architecture  shape it, write the ADRs, get it reviewed      <- you approve
/design      contract, data, failure modes, per feature
/plan        ordered tasks, each with a check
/implement   one task at a time, verified
/review      fresh context reads the diff
/security-review  if it touches auth, secrets, input, or user data
/production-readiness  GO or NO-GO with evidence              <- you approve
/release     prepares, then stops and asks                    <- you approve
/operate     when it breaks
```

Skip what you do not need. A one-line fix goes straight to `/implement` and `/review`.

## What is in here

```
.claude-plugin/  plugin and marketplace manifests
skills/          15 procedures, loaded when invoked
agents/          4 read-only reviewers
hooks/           session context, command guard, secret guard, formatter
.claude/rules/   standards, most load only when you touch matching files
templates/       11 document templates, plus the project settings file
docs/            lifecycle, principles, ADRs, the guide
scripts/         verify.sh, new-adr.sh, setup.sh
CLAUDE.md        the standing rules a project gets, under 120 lines
install.sh
```

`skills/`, `agents/`, and `hooks/` sit at the root because that is where the plugin loader
looks for them. In a project they land under `.claude/`, which is what `install.sh` and
`/adopt` do.

## Next

- [docs/GUIDE.md](docs/GUIDE.md) how to actually use it, with two worked examples.
- [docs/engineering/lifecycle.md](docs/engineering/lifecycle.md) every phase in detail.
- [docs/engineering/system-design.md](docs/engineering/system-design.md) why it is built
  this way, and what was left out.
