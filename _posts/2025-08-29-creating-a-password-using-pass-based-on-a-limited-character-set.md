---
layout: post
title: Creating a password using `pass` based on a limited character set
date: 2025-08-29 21:25 +0200
---
Recently, I had to create a new password for a web service that had very
restrictive character requirements. Only lowercase letters, uppercase letters,
numbers and a few special characters were allowed. Since I couldn’t quickly
find a single comprehensive example of how to do this with [`pass`][pass] (my
password manager), I’m documenting my solution, so that future me can refer
back back to it in case the issue comes up again. The solution is based on
`man pass`, but I find the syntax for `PASSWORD_STORE_CHARACTER_SET` hard to
remember, so this should be helpful later.

```
❯ env PASSWORD_STORE_CHARACTER_SET="[a-zA-Z0-9]\.:@!&,\/;=\\" pass generate example.com 16
```

[pass]: https://www.passwordstore.org/
