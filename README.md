# herdr-overwatch

**Your agents, their tickets and their pull requests, in one place.**

Four [herdr](https://herdr.dev) plugins that are each useful on their own and
better together: pick up a ticket, start an agent on it, see where every agent
got to, merge its pull request, and move on to the next, without leaving
herdr.

| Plugin | What it's for |
| --- | --- |
| [herdr-linear](#herdr-linear) | Your Linear issues and projects. Start an issue in a fresh worktree with one key. |
| [herdr-github](#herdr-github) | Your pull requests, their checks and reviews. Merge with one key. |
| [herdr-recap](#herdr-recap) | Every agent: where it got to, written while you were away, and whose move it is. |
| [herdr-snooze](#herdr-snooze) | Hide an agent until a time you pick. It comes back by itself. |

## Install

Each one is an ordinary herdr plugin. Install the ones you want:

```sh
herdr plugin install mrolafsson/herdr-linear
herdr plugin install mrolafsson/herdr-github
herdr plugin install mrolafsson/herdr-recap
herdr plugin install mrolafsson/herdr-snooze
```

The build step compiles each with Go if you have it, or downloads the release
binary for your platform and checks its SHA-256.

Bind them to keys in `~/.config/herdr/config.toml`:

```toml
[[keys.command]]
key = "prefix+alt+l"
type = "plugin_action"
command = "herdr-linear.open"

[[keys.command]]
key = "prefix+alt+g"
type = "plugin_action"
command = "herdr-github.open"

[[keys.command]]
key = "prefix+alt+r"
type = "plugin_action"
command = "herdr-recap.open"

[[keys.command]]
key = "prefix+shift+z"
type = "plugin_action"
command = "herdr-snooze.agent"
```

On macOS, `alt` needs Option to send Alt in your terminal (Ghostty:
`macos-option-as-alt = true`).

Then `herdr server reload-config`, and **start a new herdr client** (detach
and run `herdr` again): a client that was already open keeps the key
bindings it started with.

### Or all at once

`install.sh` does the above in one go: it runs `herdr plugin install` for each,
adds the keys, and reloads the config.

```sh
git clone https://github.com/mrolafsson/herdr-overwatch
sh herdr-overwatch/install.sh
```

`sh install.sh recap github` installs just those, and `--yes` skips herdr's
confirmation before each build. It also binds `prefix+alt+p` (GitHub: this
agent's pull request) and `prefix+alt+z` (Snooze: every agent). A plugin
that's already installed is skipped, a key or action you've already bound is
left alone, and `config.toml` is backed up before it's changed
(`--no-keys` leaves it alone entirely).

### Uninstall

```sh
herdr plugin uninstall herdr-linear
herdr plugin uninstall herdr-github
herdr plugin uninstall herdr-recap
herdr plugin uninstall herdr-snooze
```

Then remove their `[[keys.command]]` blocks from `config.toml` and
`herdr server reload-config`. Or `sh herdr-overwatch/uninstall.sh` does both,
for all four or the ones you name (`sh uninstall.sh snooze`), backing up the
config first. herdr keeps each plugin's config and state directories, and
sidebar rows you added their tokens to (`$pr`, `$issue`, `$snoozed`) are left
for you; each plugin's README has the details.

## Better together

There's nothing to set up. Each plugin asks herdr which of the others are
installed, and links to them when they are.

![Recap, with an agent's Linear issue and pull request as links on its row](https://raw.githubusercontent.com/mrolafsson/herdr-recap/main/docs/images/agents.png)

- **Every agent carries its ticket and its pull request.** Linear and GitHub
  tag each agent and space with the issue and PR its branch is for:
  `ENG-142 In Progress`, `#482 ✓ approved`. Snooze adds when it wakes:
  `💤 17:30`. They show in herdr's sidebar and on every row in Recap.
- **Searchable.** Type a PR number or a ticket key in Recap's filter and the
  agent working on it comes up, even one that has moved on from a merged PR.
- **One key away.** In Recap, `ctrl+g` opens the agent's pull request in the
  GitHub popup and `ctrl+l` its issue in Linear; a click on either does the
  same. `ctrl+s` snoozes the agent, and snoozed agents have a tab of their own.
- **There and back.** herdr shows one popup at a time, so following a link
  turns the popup into the other plugin's, in place and without a flicker.
  `esc` there brings you back to the agent you were on.
- **One look.** Titles, branches, pull requests and keys are drawn the same
  in all four, in your herdr theme's colours. All of them work with the
  mouse, and each has a demo mode on made-up data to try it without an
  account.

So a morning goes: open Recap, two agents need you and one PR is green.
`ctrl+g`, merge, `esc`. Then over to Linear for the next ticket, one key to
start it, and a fresh worktree and agent pick it up.

## herdr-linear

[github.com/mrolafsson/herdr-linear](https://github.com/mrolafsson/herdr-linear)

![herdr-linear: my issues grouped by status](https://raw.githubusercontent.com/mrolafsson/herdr-linear/main/docs/images/issues.png)

- **Your issues** grouped by status, and **projects** with their progress and
  open issues.
- **Change status** from the team's own workflow, and **create an issue** in a
  few keystrokes.
- **Start an issue with one key:** it goes In Progress and is assigned to you,
  a worktree is made on Linear's branch name, and the issue is handed to the
  agent that opens there.
- **Sidebar labels:** every agent and space shows the issue its branch is for.

## herdr-github

[github.com/mrolafsson/herdr-github](https://github.com/mrolafsson/herdr-github)

![herdr-github: a pull request with its checks and reviews](https://raw.githubusercontent.com/mrolafsson/herdr-github/main/docs/images/pr.png)

- **What's waiting on you:** your pull requests, the ones your review is
  requested on, and the repo's.
- **A pull request** with its checks, reviews and unresolved threads, and why
  it can't merge yet.
- **Draft to ready, or merge,** with one key, by any method the repo allows.
- **Worktrees:** one key opens the PR's worktree, or makes it. Forks included.
- **Whose PR is it?** Each PR lists the agents that opened it and worked on it.

## herdr-recap

[github.com/mrolafsson/herdr-recap](https://github.com/mrolafsson/herdr-recap)

![herdr-recap: an agent found by something said in its conversation](https://raw.githubusercontent.com/mrolafsson/herdr-recap/main/docs/images/search.png)

- **Recaps written while you're away:** Claude Code's own `/recap`, or the
  agent's equivalent, in a throwaway fork, so the agent's conversation isn't
  touched. Claude, Codex, OpenCode and Hermes.
- **Grouped by whose move it is:** Needs you, Done, Needs fixing, Idle,
  Working, In review, Merged, Snoozed.
- **What a blocked agent wants,** right on its row, and **reply** without
  leaving the list.
- **Each row** has the branch, uncommitted and unpushed work, task progress,
  the PR and how long it has been waiting.
- **Type to filter;** when nothing matches, the agents' conversations are
  searched.
- **Better titles,** with the ticket key, for agents named after a slug.

## herdr-snooze

[github.com/mrolafsson/herdr-snooze](https://github.com/mrolafsson/herdr-snooze)

![herdr-snooze: how long to snooze an agent for](https://raw.githubusercontent.com/mrolafsson/herdr-snooze/main/docs/images/picker.png)

- **One key, both ways:** it asks how long and hides the agent, or wakes it
  if it's already snoozed.
- **As long as you like:** 15 minutes, an hour, tomorrow 9am, a week, or
  whatever you type.
- **A whole space at once,** including agents that start there later.
- **It comes back on time,** with nothing of the plugin running.
- **Nothing blocked stays hidden:** a snoozed agent that needs you still
  shows.

## Requirements

herdr 0.9.0 or later, on Linux or macOS. Go builds each plugin from source when
it's installed; without Go, the release binary is downloaded instead.
herdr-github needs [gh](https://cli.github.com), signed in. Each plugin's
README has the details.

## This repository

The four plugins are git submodules here, at the versions this README
describes:

```sh
git clone --recurse-submodules https://github.com/mrolafsson/herdr-overwatch
```

Issues and pull requests are welcome on each plugin's own repository.

## License

MIT
