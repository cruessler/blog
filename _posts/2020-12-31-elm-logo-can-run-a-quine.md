---
layout: post
title: "elm-logo can run a quine now"
date: 2020-12-31 18:33 +0100
categories: elm-logo
---

[elm-logo] can run a [quine][wikipedia-quine] now. A quine is a program that
prints its own source.

{% elm_logo_snippet %}
make "a [ 116 121 112 101 32 34 124 109 97 107 101 32 34 97 32 91 124 10 102 111 114 101 97 99 104 32 58 97 32 91 32 116 121 112 101 32 119 111 114 100 32 34 124 32 124 32 63 32 93 10 112 114 105 110 116 32 34 124 32 93 124 10 102 111 114 101 97 99 104 32 58 97 32 91 32 116 121 112 101 32 99 104 97 114 32 63 32 93 10 ]
type "|make "a [|
foreach :a [ type word "| | ? ]
print "| ]|
foreach :a [ type char ? ]
{% endelm_logo_snippet %}

This particular quine comes from [Rosetta Code][rosettacode-quine].

[elm-logo]: https://c.rubler.net/elm-logo/
[rosettacode-quine]: https://rosettacode.org/wiki/Quine#Logo
[wikipedia-quine]: https://en.wikipedia.org/wiki/Quine_(computing)
