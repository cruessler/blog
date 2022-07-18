---
layout: post
title: elm-logo can solve the Towers of Hanoi problem
categories: elm-logo
date: 2022-07-18 20:42 +0200
---
This is another post about elm-logo being able to run an algorithm
from Rosetta Code although this post comes a bit late like the
previous one since the required features landed quite a while ago.
This time, it is [the Towers of Hanoi problem][towers-of-hanoi].

{% elm_logo_snippet %}
to move :n :from :to :via
  if :n = 0 [stop]
  move :n-1 :from :via :to
  (print [Move disk from] :from [to] :to)
  move :n-1 :via :to :from
end
move 4 "left "middle "right
{% endelm_logo_snippet %}

[towers-of-hanoi]: https://rosettacode.org/wiki/Towers_of_Hanoi#Logo
