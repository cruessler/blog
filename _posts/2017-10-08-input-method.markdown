---
layout: post
title:  "Changing the input method to xim"
date:   2017-10-15 12:47:00 +0200
categories: today-i-debugged
---

## The problem

- Diacritics or the compose key not working in Konsole (the KDE terminal
  emulator),
- certain parts of my desktop, e. g. Krunner, only getting a small fraction of
  all the keys I was typing.

## The solution

Changing the input method to `xim`. Running `im-setup` created a file
`~/.xinputrc` with the following contents:

```bash
# im-config(8) generated on Tue, 22 Aug 2017 13:00:14 +0200
run_im xim
# im-config signature: 5de73d7936d4a2337e90a24bf1fae287  -
```

After restarting my computer my keyboard worked again as expected.

## The solutions that weren’t

Trying to set the input method to `fcitx` as some bug reports suggested did not
help.

Versions: KDE Plasma 5.10.5, KDE Frameworks 5.37.0, Qt 5.7.1

More info: `man im-config`
