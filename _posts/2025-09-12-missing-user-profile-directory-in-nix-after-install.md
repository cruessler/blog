---
layout: post
title: Missing user profile directory in Nix after install
categories: today-i-debugged
date: 2025-09-12 10:27 +0200
---
Recently, on one of my Ubuntu machines, I decided to start relying on Nix for
installing and managing a couple of developers tools I regularly use, such as
`eza`, `hyperfine`, `samply` and `stylua`. Most of these tools are only
available in older versions in the Ubuntu package repositories or they’re not
available at all, but all are available in fairly recent versions in
[nixpkgs][nixpkgs].

```
❯ nix-env -q
eza-0.23.1
hyperfine-1.19.0
samply-0.13.1
stylua-2.1.0
```

I already had an old Nix installation from a couple years back, but it seemed
to not be in a good state, at least `nix doctor` (now `nix config check`) told
me there were a few issues. Unfortunately, `nix doctor` didn’t tell me how to
fix them. In order to reset to a known good state, I decided to reinstall Nix.

The [installation][installation] went well, except the multi-user installation
did not automatically create a profile directory inside
`/nix/var/nix/profiles/per-user/`. This left me with the following error
message when trying to install any package:

```
❯ nix-env -iA nixpkgs.stylua
installing 'stylua-2.1.0'
this path will be fetched (1.94 MiB download, 7.93 MiB unpacked):
  /nix/store/jax2k9jfays63q97kiz52mggswaar8g8-stylua-2.1.0
copying path '/nix/store/jax2k9jfays63q97kiz52mggswaar8g8-stylua-2.1.0' from 'https://cache.nixos.org'...
building '/nix/store/a5wiywv48g255zqql0xcaasr6iikvs6s-user-environment.drv'...
error: opening lock file '/nix/var/nix/profiles/per-user/christoph/profile.lock': No such file or directory
```

The [manual][installation] doesn’t mention the need to create a profile
directory, so I was a bit unsure as to what the canonical way of fixing this
issue was. In the end, I decided to create the missing directory by hand at
which point I was able to install packages.

```
nix/profiles/per-user🔒
❯ ls -al
drwxr-xr-x - root 11 Sep 20:17 root

nix/profiles/per-user🔒
❯ sudo mkdir christoph

nix/profiles/per-user🔒
❯ sudo chown $USER: christoph/

nix/profiles/per-user🔒
❯ ls -al
drwxr-xr-x - christoph 11 Sep 20:40 christoph
drwxr-xr-x - root      11 Sep 20:17 root
```

If it turns out this is the wrong way of fixing things, I’m going to update
this post.

[installation]: https://nix.dev/manual/nix/2.30/installation/installing-binary.html
[nixpkgs]: https://search.nixos.org/packages
[nix-package-manager]: https://nixos.wiki/wiki/Nix_package_manager
