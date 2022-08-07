---
layout: post
title: Using pass to store a GitHub access token
date: 2022-08-07 21:52 +0200
---
If you want to connect to GitHub using HTTPS, you need an [access
token][access-token]. You can store that token in `pass` and use the following
snippet to make git ask `pass` for the token. I put the snippet into
`.config/git/user` and include that file in my main `.gitconfig`. This example
uses `pass`, but you can replace the call with anything you like.

[access-token]: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token#using-a-token-on-the-command-line

```
# It is necessary to quote the command and escape any double quotes it contains
# (the example at [1] does not do that).
#
# [1]: https://git-scm.com/docs/api-credentials#_credential_helpers
[credential "https://github.com"]
  username = …
  helper = !"f() { echo \"password=`pass access-tokens/github.com`\"; }; f"
```
