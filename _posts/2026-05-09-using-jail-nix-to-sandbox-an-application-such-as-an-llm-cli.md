---
layout: post
title: Using jail.nix to sandbox an application, such as an LLM CLI
date: 2026-05-09 18:52 +0200
---
Yesterday, I spent some time reading Mark Erikson’s (of Redux fame) [blog
post][ai-thoughts-1] on how he once was convinced he’d never write any code
using an LLM, but then, at some point, found so much use in LLMs that he
started incorporating them into his workflow, to the point that they now play a
large part in how he gets things done. There was a lot of signal in that post,
and while I still mostly find myself not using LLMs all that much, I once again
considered trying some of the options to see what’s out there and what these
tools are capable of these days.

One major concern I still have, though, is that giving any LLM access to my
machine feels like a risk I’m not ready to take, in particular given the fact
that any text that gets fed to them can influence their behaviour in ways that
I would most certainly disapprove of. So before I will start using an LLM for
any real work, I first want to invest some time into making sure it does not
have access to anything important on my machine and that any damage it might
potentially do will only affect directories I can fully restore to a known good
state.

And so I went searching the internet for something like “nix sandbox llm” and
found [`jail.nix`][jail-nix] ([manual][jail-nix-manual]), a project that uses
[`bubblewrap`][bubblewrap] to sandbox applications. I’m running Ubuntu
(currently 25.10) on my machine, and I already had a working Nix and Home
Manager installation (following [this manual, sub-section “Standalone
installation”][home-manager-manual-without-flakes]), so I decided to give
`jail.nix` a try.

Since [`jail.nix`’s manual][jail-nix-manual] mentions installation via flakes,
I followed the [sub-section “Standalone setup”][home-manager-manual-flakes] of
the “Nix Flakes” section and changed my Home manager installation to be based
on flakes. Since I’m not a Nix expert, I’m not entirely sure whether that step
converted my existing installation or created a new one, but since I still have
all the programs installed via Home Manager available, that distinction does
not really matter to me. Anyway, [this is the commit that created my initial
`flake.nix`][commit-adding-flakes].

Adding a new command `jailed-vibe` was then just a matter of applying the diff
in [“Appendix”](#appendix) that adds `jailed-vibe` to `home.packages`. After
that, I ran `home-manager switch`, and with all that, I now have a command
`jailed-vibe` that I can run anywhere and that, basically, only has access to
the directory it runs in. Its access to my system is extremely limited, to the
point that it is not practically useful for anything beyond asking the LLM
questions about files in the directory it runs in, but that is something that
I’m going to be exploring next: how to give it access to a select, minimal set
of tools that are sufficient to make it useful for some tasks that involve
actually changing code and potentially running compilers, linters and tests.

After I had already written the major part of this post, I discovered that
[`ai-jail`][ai-jail] does something very similar to the setup presented here,
while being just a regular CLI application that you can install through `cargo`
or `brew`, among other things. So if you’re looking for something more
straightforward that does not require you to use Nix, then `ai-jail` probably
is worth looking at.

## Appendix

This is an excerpt from [this commit][commit-introducing-jail-nix].

```diff
diff --git a/.config/home-manager/flake.nix b/.config/home-manager/flake.nix
index 438d2da..bedb525 100644
--- a/.config/home-manager/flake.nix
+++ b/.config/home-manager/flake.nix
@@ -16,19 +16,60 @@
       url = "github:nix-community/home-manager";
       inputs.nixpkgs.follows = "nixpkgs";
     };
+    jail-nix.url = "sourcehut:~alexdavid/jail.nix";
+    mistral-vibe.url = "github:mistralai/mistral-vibe";
   };
 
   outputs =
-    { nixpkgs, home-manager, ... }:
+    {
+      nixpkgs,
+      home-manager,
+      jail-nix,
+      mistral-vibe,
+      ...
+    }:
     let
       system = "x86_64-linux";
       pkgs = nixpkgs.legacyPackages.${system};
+      jail = jail-nix.lib.init pkgs;
+      # I also needed to run the following after I got an error message trying
+      # to run the jailed executable:
+      #
+      #     # the error message I was getting
+      #     bwrap: setting up uid map: Permission denied
+      #
+      #     ❯ sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0
+      #     kernel.apparmor_restrict_unprivileged_userns = 0
+      #
+      # https://ubuntu.com/blog/ubuntu-23-10-restricted-unprivileged-user-namespaces
+      #
+      # According to this [comment], the above is system-wide and there is an
+      # alternative that only affects `bwrap` (even though I also found other
+      # sources that discouraged it, arguing that it effectively disables
+      # AppArmor for `bwrap`).
+      #
+      # [comment]: https://github.com/akitaonrails/ai-jail/issues/34#issuecomment-4314837965
+      #
+      # I don’t know whether there’s a more proper way of getting the path.
+      #
+      # https://github.com/mistralai/mistral-vibe/blob/b23f49e5f44e95aa997439a74fd5b470d762ecb0/flake.nix#L83
+      jailed-vibe = jail "jailed-vibe" "${mistral-vibe.packages.${system}.default}/bin/vibe" (
+        with jail.combinators;
+        [
+          network
+          time-zone
+          mount-cwd
+          no-new-session
+        ]
+      );
     in
     {
       homeConfigurations."christoph" = home-manager.lib.homeManagerConfiguration {
         inherit pkgs;
 
         modules = [ ./home.nix ];
+
+        extraSpecialArgs = { inherit jailed-vibe; };
       };
     };
 }
diff --git a/.config/home-manager/home.nix b/.config/home-manager/home.nix
index d2c5718..bd28a14 100644
--- a/.config/home-manager/home.nix
+++ b/.config/home-manager/home.nix
@@ -2,7 +2,12 @@
 # https://nix-community.github.io/home-manager/index.xhtml
 #
 # Use `nix-channel --update; and home-manager switch` to update packages.
-{ config, pkgs, ... }:
+{
+  config,
+  pkgs,
+  jailed-vibe,
+  ...
+}:
 
 # https://nix-community.github.io/home-manager/index.xhtml#_how_do_i_install_packages_from_nixpkgs_unstable
 let
@@ -46,6 +51,8 @@ in
     pkgs.vdirsyncer
 
     pkgs.zellij
+
+    jailed-vibe
   ];
 
   programs.home-manager.enable = true;
```

[ai-thoughts-1]: https://blog.isquaredsoftware.com/2026/05/ai-thoughts-part-1-fears-opinions-journey/
[jail-nix]: https://sr.ht/~alexdavid/jail.nix/
[jail-nix-manual]: https://alexdav.id/projects/jail-nix/
[bubblewrap]: https://github.com/containers/bubblewrap
[home-manager-manual-without-flakes]: https://nix-community.github.io/home-manager/index.xhtml#sec-install-standalone
[home-manager-manual-flakes]: https://nix-community.github.io/home-manager/index.xhtml#sec-flakes-standalone
[commit-adding-flakes]: https://github.com/cruessler/dotfiles/commit/32d4b9b37a275c6e638e647a660ca7d6b6b66892
[commit-introducing-jail-nix]: https://github.com/cruessler/dotfiles/commit/780b8c21fb06a0a9049f89dffcc8e20b200387ba
[ai-jail]: https://github.com/akitaonrails/ai-jail
