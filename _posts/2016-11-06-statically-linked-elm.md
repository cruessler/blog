---
layout: post
title:  "Statically compiling the Elm compiler (0.17/0.18) on a musl-based Gentoo system"
date:   2016-11-06 19:12:00 +0200
categories: elm
redirect_from:
  - /elm/2016/11/06/statically-linked-elm.html
---
Some time ago, I wanted to use Elm on a server that was running CentOS 5. At
first, this proved to be impossible as the target system was not able to run
the Elm binaries provided by npm. These binaries are linked against `glibc` >=
2.14 while the server only had 2.12. This seemed to be a perfect use case for
static linking. That turned out to be true, and even though statically
compiling the Elm compiler is not something I’d do on a daily basis I had quite
a lot of fun.

The final solution uses a musl-based Gentoo container to statically compile a
Haskell compiler (GHC) which is then used to statically compile the Elm
compiler. Some paths that didn’t lead me to a destination involved Alpine Linux
as well as cross-compilation on my host system using `crosstools-ng` (although
I might have given up on those too early).

### Update 2017-05-09

The process described for Elm 0.17 can be also used to compile Elm 0.18.

### Update 2018-08-27

The process for compiling Elm 0.19 has changed a little, but it is still
possible to get a statically linked Elm binary. See [my newer post]({{
site.baseurl }}{% post_url 2018-08-27-statically-linked-elm-0-19 %}) for
details.

## Prerequisites

My computer runs Ubuntu 16.04. Commands run on this system will be prefixed
with `$ ` throughout this post. To be able to run Gentoo on this system, you
need to install `systemd-container`. This lets you start a musl-based system in
a container. I shortly experimented with docker until I decided I didn’t want
to add an extra layer of indirection although it might have made my solution
more portable.

    $ sudo apt-get install systemd-container

## Download and extract a musl-based Gentoo sytem

    $ wget http://distfiles.gentoo.org/experimental/amd64/musl/stage3-amd64-musl-vanilla-20160804.tar.bz2
    $ wget http://distfiles.gentoo.org/experimental/amd64/musl/stage3-amd64-musl-vanilla-20160804.tar.bz2.DIGESTS

We verify the integrity of the file by comparing its checksum to the one in
`*.DIGESTS`.

    $ sha512sum stage3-amd64-musl-vanilla-20160804.tar.bz2

    $ mkdir stage3
    $ tar xfp stage3-amd64-musl-vanilla-20160804.tar.bz2 -C stage3 --xattr

Now, we can change into the just extracted Gentoo system.

    $ sudo systemd-nspawn -D stage3 -a

## Install portage musl overlays

At this point, we’re inside our build environment which has to be configured
further. Commands run inside our build system will be prefixed by `# `. The
following commands mostly follow the guides at
<https://wiki.gentoo.org/wiki/Project:Hardened_musl> and
<http://distfiles.gentoo.org/experimental/amd64/musl/HOWTO>. They make sure the
important packages on the build system have the necessary patches to be usable
with musl.

    # emerge --sync

    # echo "dev-vcs/git -gpg" >> /etc/portage/package.use
    # emerge -q layman dev-vcs/git

    # layman -L
    # layman -a musl
    # echo "source /var/lib/layman/make.conf" >> /etc/portage/make.conf

    # emerge -uvNDq world   # may do nothing

## Install musl-based GHC

Now, we have to install a musl-based GHC to compile the Elm compiler. Since
`emerge ghc` fails we have to get it elsewhere. We can either [cross-compile
GHC]({{site.baseurl}}{% post_url 2016-11-05-cross-compiling-ghc %}) and copy
the resulting binaries to our container. To do this we have to shortly leave
our container (note the `$ `).

    $ sudo cp -r /opt/ghc/ stage3/opt/

Or we can mostly follow the guide at
<https://github.com/redneb/ghc-alt-libc/blob/master/HOWTO-gentoo-musl-chroot.md>
and download a suitable GHC binary by using one of the links at
<https://drive.google.com/folderview?id=0B0zktggRQYRkbGJkbmU0UFFSYUE#list>
(linked to at <https://github.com/redneb/ghc-alt-libc>). In this post we use
version 7.10.3. We can continue once we have moved the tarball to our
containers’ `/root`.

    # tar xf ghc-7.10.3-x86_64-unknown-linux-musl.tar.xz -C /tmp
    # cd /tmp/ghc-7.10.3
    # ./configure --prefix=/opt/ghc
    # make install

Either way, we have to adapt `$PATH`.

    # echo 'export PATH="$PATH:/opt/ghc/bin"' >> .env-vars
    # source .env-vars

    # ghc --version
    The Glorious Glasgow Haskell Compilation System, version 7.10.3

Now, we have a working GHC, but for the Elm compiler to be built, we need
cabal, too.

## Bootstrap cabal

    # wget https://www.haskell.org/cabal/release/cabal-install-1.22.9.0/cabal-install-1.22.9.0.tar.gz
    # tar xf cabal-install-1.22.9.0.tar.gz -C /tmp/
    # cd /tmp/cabal-install-1.22.9.0/
    # ./bootstrap.sh

    # echo 'export PATH="$PATH:/root/.cabal/bin"' >> .env-vars
    # source .env-vars

    # cabal --version
    cabal-install version 1.22.9.0
    using version 1.22.5.0 of the Cabal library

Now that we have cabal installed, we need to configure it to produce statically
linked binaries.

    # cabal user-config update
    # sed --in-place 's/-- ghc-options:/ghc-options: -optl-static/' ~/.cabal/config

With cabal in place and configured, we can start compiling the Elm compiler.
With the current setup, we would run into several errors, though. Luckily, all
of them can be fixed.

## Prevent compile errors

### libgmp

If we tried to compile Elm now, we’d get lots of errors that look like this:

    zlib-0.6.1.1 failed during the configure step. The exception was:
    user error ('/opt/ghc/bin/ghc' exited with an error:
    /usr/lib/gcc/x86_64-gentoo-linux-musl/4.9.3/../../../../x86_64-gentoo-linux-musl/bin/ld:
    cannot find -lgmp
    collect2: error: ld returned 1 exit status
    )
    zlib-bindings-0.1.1.5 depends on zlib-0.6.1.1 which failed to install.

These errors are due to `libgmp` not being ready for use in static compilation.
To solve this, we can add a USE flag to make our Gentoo system produce static
libraries and recompile the relevant packages.

    # sed --in-place 's/USE="/USE="static-libs /' /etc/portage/make.conf
    # emerge -uvNDq world

After this change, the linker can find `libgmp`.

### Enable `-PIC` for GCC

We have fixed one type of errors, but we’d get different ones when we tried to
compile Elm now. The C runtime doesn’t use [Position independent code
(PIC)](https://en.wikipedia.org/wiki/Position-independent_code) which makes the
linker unable to use the runtime in static linking.

    [44 of 44] Compiling Data.Text.Read   ( Data/Text/Read.hs, dist/dist-sandbox-fd83d382/build/Data/Text/Read.o )
    /usr/lib/gcc/x86_64-gentoo-linux-musl/4.9.3/../../../../x86_64-gentoo-linux-musl/bin/ld: /usr/lib/gcc/x86_64-gentoo-linux-musl/4.9.3/crtbeginT.o: relocation R_X86_64_32 against `__TMC_END__' can not be used when making a shared object; recompile with -fPIC
    /usr/lib/gcc/x86_64-gentoo-linux-musl/4.9.3/crtbeginT.o: error adding symbols: Bad value
    collect2: error: ld returned 1 exit status

Luckily, `ld` not only tells us what’s wrong, but also how to fix the errors.
We have to recompile GCC with `-fPIC` and can do so by issuing the following
commands.

    # sed --in-place 's/CFLAGS="/CFLAGS="-fPIC /' /etc/portage/make.conf
    # emerge -vq --oneshot sys-devel/gcc

### Fix libz error

We’re now almost ready to actually compile the Elm compiler. There are only two
errors left, so be brave and steady! The errors we now get look like this.

    [4 of 8] Compiling StaticFiles      ( src/backend/StaticFiles.hs, dist/dist-sandbox-fd83d382/build/elm-reactor/elm-reactor-tmp/StaticFiles.o )
    <command line>: can't load .so/.DLL for: /usr/lib/gcc/x86_64-gentoo-linux-musl/4.9.3/../../../libz.so (Error loading shared library /usr/lib/gcc/x86_64-gentoo-linux-musl/4.9.3/../../../libz.so: Exec format error)

In the current setup, `/usr/lib/libz.so` is a linker script. This script can
for some reason not be used by the `BuildFromSource.hs` process. We can replace
the linker script by a symbolic link to `libz` to make it work.

    # mv /usr/lib/libz.so /usr/lib/libz.so.orig
    # ln -s /lib/libz.so.1 /usr/lib

### Recompile zlib with `-fPIC`

That brings us to our last error. `libz` has to be recompiled with `-fPIC`,
too.

    /usr/lib/gcc/x86_64-gentoo-linux-musl/4.9.3/../../../../x86_64-gentoo-linux-musl/bin/ld: /usr/lib/gcc/x86_64-gentoo-linux-musl/4.9.3/../../../libz.a(crc32.o): relocation R_X86_64_32 against `.rodata' can not be used when making a shared object; recompile with -fPIC
    /usr/lib/gcc/x86_64-gentoo-linux-musl/4.9.3/../../../libz.a: error adding symbols: Bad value
    collect2: error: ld returned 1 exit status

    # emerge -vq --oneshot sys-libs/zlib

We repeat the fix for the `libz` linker script, and we’re finally ready to
statically compile the Elm compiler!

    # mv -f /usr/lib/libz.so /usr/lib/libz.so.orig
    # ln -s /lib/libz.so.1 /usr/lib/libz.so

## Compile the Elm compiler

    # mkdir elm-platform && cd elm-platform
    # wget https://raw.githubusercontent.com/elm-lang/elm-platform/master/installers/BuildFromSource.hs

Note: 0.17.1 cannot be compiled because of
<https://github.com/elm-lang/elm-compiler/pull/1431>.

    # runhaskell BuildFromSource.hs 0.17

    # file Elm-Platform/0.17/.cabal-sandbox/bin/elm-make
    Elm-Platform/0.17/.cabal-sandbox/bin/elm-make: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, stripped
    # Elm-Platform/0.17/.cabal-sandbox/bin/elm-make --help
    elm-make 0.17 (Elm Platform 0.17.0)
    [rest of output omitted]

`elm-make` and its companions are now ready to be run without dependencies, e.
g. outside our build system (note the `$ ` again, denoting we have left our
Gentoo-based build system and are again on our Ubuntu-based host system).

    $ file stage3/root/elm-platform/Elm-Platform/0.17/.cabal-sandbox/bin/elm-make
    stage3/root/elm-platform/Elm-Platform/0.17/.cabal-sandbox/bin/elm-make: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, stripped
    $ stage3/root/elm-platform/Elm-Platform/0.17/.cabal-sandbox/bin/elm-make --help
    elm-make 0.17 (Elm Platform 0.17.0)
    [rest of output omitted]

The resulting executables run on a wide variety of Linux systems.

### Update 2017-05-09

You can replace `0.17` with `0.18` if you want to compile Elm 0.18.
