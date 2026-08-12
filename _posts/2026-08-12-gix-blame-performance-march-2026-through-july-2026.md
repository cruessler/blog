---
layout: post
title: gix-blame performance March 2026 through July 2026
date: 2026-08-12 21:07 +0200
---
I recently started a new blog dedicated to [`gitoxide`][gitoxide] performance
analyses at <https://cruessler.github.io>. The [first post][first-new-post],
“`gix-blame` performance March 2026 through July 2026”, is about getting an
idea of how `gix-blame`’s performance changed between March 2026 and July 2026.
This was a period where there were no major changes to `gix-blame` itself.

[gitoxide]: https://github.com/GitoxideLabs/gitoxide
[first-new-post]: https://cruessler.github.io/posts/gix-blame-march-2026-through-july-2026/

My primary reason for starting a new blog was the tech stack. This blog runs on
Jekyll which is a fine choice for the fairly text-centered content that I’ve
been publishing so far. The new blog, on the other hand, runs on Quarto, and
Quarto integrates with Python and Jupyter (and also R and Julia), so it is very
well suited to the kinds of performance analyses that I want to occasionally
create, most often probably in the context of some of the projects I work on in
`gitoxide`.

These analyses involve a fair bit of data processing, presenting and
visualizing, and the combination of Python, its rich ecosystem of libraries and
Quarto has made creating them far more approachable for me. So much so, in
fact, that I’ve already migrated (and extended!) [two][first-existing-post] of
my [previous posts][second-existing-post] that took me some time and effort to
create with Jekyll (as there was a lot of manual work involved) to my new blog
where it was almost trivial to iterate on them, extend them and port the
changes between them. I certainly hope that I’ll find more opportunities for
new posts in the future!

[first-existing-post]: https://cruessler.github.io/posts/gix-blame-performance-with-imara-diff-0-1-and-0-2/
[second-existing-post]: https://cruessler.github.io/posts/gix-blame-performance-improved-by-a-change-in-gix-diff/
