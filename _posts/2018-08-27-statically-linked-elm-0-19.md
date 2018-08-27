---
layout: post
title:  "Statically compiling the Elm compiler (0.19) on a musl-based Gentoo system"
date:   2018-08-27 17:22:00 +0200
categories: elm
---

When Elm 0.19 came out a few days ago I wanted to try whether Elm’s compiler
could still be compiled and statically linked for execution on Linux systems
that only have a very old C library. It turns out that this is still possible.

This post is based on [my older post which describes how to compile Elm 0.17
and 0.18][compiling-0.17]. The general setup is the same: we have a musl-based
Gentoo running in a container which we use to run a statically linked GHC. This
post assumes that we still have our build environment for Elm 0.17 and 0.18
available. In particular, it is assumed that all workarounds that have been
found during compilation of Elm 0.17 and 0.18 have been applied.

## Prevent compile errors

The Elm 0.19 compiler has moved to <https://github.com/elm/compiler/> (up to
0.18 it lived at <https://github.com/elm-lang/elm-compiler/>). We prepare our
build environment by cloning the compiler repo. Then we update and install
additional dependencies.

    # git clone https://github.com/elm/compiler

    # cd compiler
    # cabal update
    # cabal install --only-dependencies --force-reinstalls

    # cabal build

### Fix libncursesw error

Now we get compiler errors that look like this:

    [  3 of 166] Compiling Generate.Functions ( builder/src/Generate/Functions.hs, dist/build/elm/elm-tmp/Generate/Functions.o )
    <no location info>:
        <command line>: can't load .so/.DLL for: /usr/lib/gcc/x86_64-gentoo-linux-musl/4.9.3/../../../libncursesw.so (Error loading shared library /usr/lib/gcc/x86_64-gentoo-linux-musl/4.9.3/../../../libncursesw.so: Exec format error)
    [ 22 of 166] Compiling Generate.Html    ( builder/src/Generate/Html.hs, dist/build/elm/elm-tmp/Generate/Html.o )
    <no location info>:
        ghc: panic! (the 'impossible' happened)
      (GHC version 7.10.3 for x86_64-unknown-linux):
            Dynamic linker not initialised
    Please report this as a GHC bug:  http://www.haskell.org/ghc/reportabug

Luckily, we have seen this kind of error [before][fix-libz-error], so we know
how to fix it.

    # mv /usr/lib/libncursesw.so /usr/lib/libncursesw.so.orig
    # ln -s /lib/libncursesw.so.5 /usr/lib/libncursesw.so

If we now run `cabal build` we get the following error:

    [152 of 166] Compiling Elm.Diff         ( builder/src/Elm/Diff.hs, dist/build/elm/elm-tmp/Elm/Diff.o )
    <no location info>:
        dist/build/elm/elm-tmp/Elm/Diff.o: getFileStatus: does not exist (No such file or directory)

The error disappears when we run `cabal build` a second time.

## Compile the Elm compiler

    # cabal build

Now we have a working Elm 0.19 compiler that is statically linked. To see the
output of `elm`, we can run `cabal run`.

    # cabal run
    Preprocessing executable 'elm' for elm-0.19.0...
    Running elm...
    Hi, thank you for trying out Elm 0.19.0. I hope you like it!
    [rest of output omitted]

    # file dist/build/elm/elm
    dist/build/elm/elm: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, not stripped

`elm` is now ready to be run without dependencies, e. g. outside our build
system. We leave our build system and run `file` again on our Ubuntu-based host
system (note the `$ ` again).

    $ file stage3/root/compiler/dist/build/elm/elm
    stage3/root/compiler/dist/build/elm/elm: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, with debug_info, not stripped
    $ stage3/root/compiler/dist/build/elm/elm
    Hi, thank you for trying out Elm 0.19.0. I hope you like it!
    [rest of output omitted]

[compiling-0.17]: {{ site.baseurl }}{% post_url 2016-11-06-statically-linked-elm %}
[fix-libz-error]: {{ site.baseurl }}{% post_url 2016-11-06-statically-linked-elm %}#fix-libz-error
