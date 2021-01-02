---
layout: post
title: elm-logo got shorthands
date: 2021-01-02 15:36 +0100
categories: elm-logo
---

elm-logo now knows [UBCLogo][ubclogo] shorthands to the few commands that are
already implemented. `rt` and `right`, for example, can be used
interchangeably.

{% elm_logo_snippet %}
pendown repeat 8 [rt 45 repeat 6 [repeat 90 [fd 2 rt 2] rt 90]]
{% endelm_logo_snippet %}

{% elm_logo_snippet %}
pendown repeat 1800 [fd 10 rt repcount + 0.1]
{% endelm_logo_snippet %}

Both examples come from a contest that was held over 20 years ago and whose
results can be found [here][mathcats].

[ubclogo]: http://www.cs.berkeley.edu/~bh/logo.html
[mathcats]: http://www.mathcats.com/gallery/15wordcontest.html
