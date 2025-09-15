---
layout: post
title: Using SvelteKit’s `resolve` with dynamic paths and parameters
date: 2025-09-15 16:07 +0200
---
I’m just documenting a minor doc issue I had with SvelteKit recently, in order
to prevent me from running into it again.

[The docs][resolve-docs] don’t mention that you are not free to choose
placeholder names in `resolve`’s first parameter. In fact, you are constrained
to the actual directory structure inside `src/routes`, a fact that was not
immediately obvious to me. While this constraint probably can be inferred from
`resolve` expecting a “route ID” as its first parameter, something that _is_
mentioned in the docs, I still found it confusing.

```
└── blog
    └── [slug]
        └── +page.svelte
```

So, given the above directory structure, you’ll need to use
`resolve('/blog/[slug]', { slug: 'slug' })` while anything else, such as
`resolve('/blog/[id]', { id: 'id' })`, will not work. Instead, TypeScript will
give you an error that unfortunately makes it quite hard to figure out the
actual problem: `Expected 1 arguments, but got 2.` The reason for this is that
the parameters’ types are conditional on the first parameter being an actually
existing route. Only if it is one, `resolve` will accept a second parameter.

I initially came across this issue as an update to `eslint-plugin-svelte` came
with a new lint rule, [`svelte/no-navigation-without-resolve`][lint-rule], in
response to which I rewrote a couple of lines related to generating URLs.

[lint-rule]: https://sveltejs.github.io/eslint-plugin-svelte/rules/no-navigation-without-resolve/
[resolve-docs]: https://svelte.dev/docs/kit/$app-paths#resolve
