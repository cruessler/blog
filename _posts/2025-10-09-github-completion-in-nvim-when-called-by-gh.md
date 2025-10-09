---
layout: post
title: Github completion in `nvim` when called by `gh`
date: 2025-10-09 20:36 +0200
---
I frequently use the [Github CLI][gh] for things like creating PRs (`gh pr
create`) or writing comments on PRs (`gh pr comment`). In these instances, it
is really helpful to have completion for issues and users via
[`blink-cmp-git`][blink-cmp-git]. For example, if you type `#`, you get a popup
with a list of Github issues, allowing you to easily reference relevant ones
without the need to context-switch.

However, I only want completion in very specific circumstances, when `nvim` is
started by `gh`. While the docs describe how `blink-cmp-git` can be enabled for
all Markdown files, that’s not what I want, as I find completion popups
annoying most of the time and want to limit the number of contexts they appear
in. So I was looking for a way to enable completion only when `nvim` is started
by `gh` and came up with the following solution.

First, I configured `GH_EDITOR` in `$HOME/.profile`:

```sh
# in `$HOME/.profile`
export GH_EDITOR="nvim -c 'lua vim.g.enable_git_completion=true'"
```

`gh` reads `GH_EDITOR` and starts `nvim`, passing a small piece of Lua that
sets a global variable to `true`. This variable is then read in my Neovim
config in order to enable Github completion:

```lua
enabled = function()
  return vim.tbl_contains({ "octo", "gitcommit" }, vim.bo.filetype) or vim.g.enable_git_completion == true
end
```

That way, `blink-cmp-git` is enabled for filetypes that are very likely related
to Github as well as when `enable_git_completion` is `true`.

[gh]: https://cli.github.com/
[blink-cmp-git]: https://github.com/Kaiser-Yang/blink-cmp-git
