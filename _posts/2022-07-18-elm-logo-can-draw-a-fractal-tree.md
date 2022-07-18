---
layout: post
title: elm-logo can draw a fractal tree
categories: elm-logo
date: 2022-07-18 17:01 +0200
---

This post comes a bit late, but since quite a while elm-logo has all
the features reqired to draw a fractal tree using this [algorithm from
Rosetta Code][fractal-tree] (only `pendown` was added).

{% elm_logo_snippet %}
to tree :depth :length :scale :angle
  if :depth=0 [stop]
  setpensize round :depth/2
  forward :length
  right :angle
  tree :depth-1 :length*:scale :scale :angle
  left 2*:angle
  tree :depth-1 :length*:scale :scale :angle
  right :angle
  back :length
end

clearscreen
pendown
tree 10 80 0.7 30
{% endelm_logo_snippet %}

[fractal-tree]: https://rosettacode.org/wiki/Fractal_tree#Logo
