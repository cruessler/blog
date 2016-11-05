---
layout: post
title:  "Cross-compiling GHC 7.10.3 with a musl toolchain"
date:   2016-11-05 19:07:00 +0200
---
# Cross-compiling GHC 7.10.3 with a musl toolchain

In my endeavor to statically compile the Elm compiler with a musl-based GHC I
first had to cross-compile the latter since my system (Ubuntu 16.04) is
glibc-based. This post describes how I did that. Most of it is inspired [by][1]
[other][2] [guides][3].

[1]: <http://funwithsoftware.org/posts/2016-04-13-building-a-ghc-cross-compiler.html>
[2]: <https://www.reddit.com/r/haskell/comments/37m7q7/ghc_musl_easier_static_linking/>
[3]: <https://ghc.haskell.org/trac/ghc/wiki/Building/CrossCompiling>

This post assumes that a cross-compiled toolchain can be found at
`$HOME/x-tools/x86_64-unknown-linux-musl/` and has been added to `$PATH`
(`crosstools-ng` 1.22.0 has been used for this post). Instructions on how to
configure `crosstools-ng` can be found [in this post][1].

    $ export PATH=$HOME/x-tools/x86_64-unknown-linux-musl/bin:$PATH

Now we’re ready to download the GHC source (and check its integrity by
verifying its signature).

    $ wget http://downloads.haskell.org/~ghc/7.10.3/ghc-7.10.3b-src.tar.bz2
    $ wget http://downloads.haskell.org/~ghc/7.10.3/ghc-7.10.3b-src.tar.bz2.sig

    $ gpg --search-keys 97DB64AD
    $ gpg --verify ghc-7.10.3b-src.tar.bz2.sig

We extract the source code and configure it to use our cross-compiling
toolchain. Since the toolchain has been added to `$PATH` it can be found by
`configure` automatically. To not interfere with our host system we set the
prefix to `/opt/ghc` (where the binaries will later be installed to).

    $ tar xf ghc-7.10.3b-src.tar.bz2
    $ cd ghc-7.10.3/
    $ ./configure --target=x86_64-unknown-linux-musl --prefix=/opt/ghc

We then copy the sample configuration and adapt it to out needs.

    $ cp mk/build.mk.sample mk/build.mk
    $ sed --in-place 's/#BuildFlavour = quick$/BuildFlavour = quick/' mk/build.mk

We don’t want our build to depend on [GMP][gmp].

    $ echo "INTEGER_LIBRARY = integer-simple" >> mk/build.mk

[gmp]: <https://gmplib.org/>

If we now tried to compile GHC we would run into all sorts of compiler and
linker errors because of `ncurses`. We have two options: We can either [get GHC
to compile with `ncurses` by fixing the errors][1] or we can circumvent them by
not depending on `ncurses`. We take the latter choice and remove all
dependencies on Haskell’s `terminfo` package from our build configuration (as
is done [here][4] and [here][5]).

[4]: <https://github.com/nilcons/ghc-musl/blob/master/ghc-cross/Dockerfile>

    $ sed --in-place s/terminfo// ghc.mk
    $ sed --in-place s/^.*terminfo// utils/ghc-pkg/ghc-pkg.cabal
    $ sed --in-place s/unix,/unix/ utils/ghc-pkg/ghc-pkg.cabal

[5]: <https://gitweb.gentoo.org/repo/gentoo.git/tree/dev-lang/ghc/ghc-7.10.2-r1.ebuild?id=f6fa6889c4c19340c23b8cd5c34cff167e1953ba>

    $ echo "utils/ghc-pkg_HC_OPTS += -DBOOTSTRAPPING" >> mk/build.mk

Now we’re finally ready to start the compilation and install the resulting
binaries.

    $ make -j 8
    $ make install

`/opt/ghc` now contains a GHC compiler that won’t run on our glibc-based host
system. It will, however, run on a musl-based system.
