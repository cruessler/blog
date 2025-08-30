---
layout: post
title: Workaround for missing `cargo install --name`
date: 2025-08-30 11:57 +0200
---
Last week, I wanted to install a Rust binary using `cargo install`, but I wanted to
give it a custom name. My specific use case was installing two different
versions of the same binary and differentiate them via a suffix, resulting in
something like `gitui` and `gitui@v0.27.0`.

This doesn’t exist in `cargo install` yet and it is also not likely to be
implemented soon, according to [this PR][rust-pr-12366]. There’s a quick
workaround, though, that I’m documenting here, mostly because I didn’t
immediately think of it, instead putting time into following a few of the links
in the PR.

```
# on the branch that’s supposed to supply the unsuffixed binary
❯ cargo install --path .

# and on the branch that’s supposed to result in a suffixed binary
❯ cargo build --release
❯ cp target/release/gitui ~/bin/gitui@v0.27.0
```

[rust-pr-12366]: https://github.com/rust-lang/cargo/issues/12366
