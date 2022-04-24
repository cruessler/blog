---
layout: post
title: elm-logo can now solve the n-queens problem
date: 2022-04-24 20:06 +0200
categories: elm-logo
---

elm-logo now has all the features reqired to solve the n-queens problem using
this slightly modified [algorithm from Rosetta Code][n-queens-problem].

{% elm_logo_snippet %}
to try :files :diag1 :diag2 :tried
  if :files = 0 [make "solutions :solutions+1 show :tried stop]
  localmake "safe (bitand :files :diag1 :diag2)
  until :safe = 0 [ localmake "f bitnot bitand :safe minus :safe try bitand :files :f ashift bitand :diag1 :f minus 1 (ashift bitand :diag2 :f 1)+1 fput bitnot :f :tried localmake "safe bitand :safe :safe-1 ]
end
to queens :n
  make "solutions 0
  try (lshift 1 :n)-1 minus 1 minus 1 []
  output :solutions
end
print queens 8
{% endelm_logo_snippet %}

[n-queens-problem]: https://rosettacode.org/wiki/N-queens_problem#Logo
