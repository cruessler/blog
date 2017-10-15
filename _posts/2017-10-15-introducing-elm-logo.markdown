---
layout: post
title:  "Introducing elm-logo: a Logo interpreter in Elm"
date:   2017-10-15 23:11:00 +0200
categories: elm elm-logo
---

Recently, I have started developing a Logo interpreter in Elm.
[Logo][wikipedia-logo] is a dialect of LISP that goes back to 1967, and it is
often used as a tool to teach programming. It was the first programming
language I learned back in school, and, ever since, I have wanted to write an
interpreter and a UI for it myself.

I plan to regularly write about the project’s progress as well as about some
basic concepts I come across along the way (expressions and statements, data
types, variable scope, among other things). In this post, I’ll give a brief
overview of the overall architecture I am trying to implement. My
implementation will adhere as closely as possible to [UBCLogo][ubclogo] which
is considered “closest to a *de facto* standard”, according to
[Wikipedia][wikipedia-ubclogo].

# First implementation details

I will break down my work into several steps which build on top of each other.
As I expect to learn a lot, the architecture drafted below might change and
evolve in the future. Currently, I see 5 major parts to the project:

1. a VM to execute the Logo code in the form of a simple “bytecode”
  - I have begun to do some research on assembly as well as some virtual
    machines (e. g. the Java VM)
  - my VM will be a stack based virtual machine since those are easier to
    implement
  - this part will include developing an instruction set that is suitable for
    Logo
  - the VM will be able to execute the “bytecode” one instruction at a time
  - the execution of the “bytecode” has certain similarities to an `update`
    function in the Elm architecture: the VM takes in a stream of instructions
    each of which make it produce a new state that is solely based on the
    instruction and the VM’s previous state

2. an `Environment` to hold all the state that belongs to a Logo session
  - initially this will be nothing more than the output of `print` commands
  - at a later stage this will include the state of the turtle and everything
    that has been drawn so far

3. an [AST][wikipedia-ast] to represent a given piece of source code
  - this will be implemented once the instruction set has reached a certain
    level of maturity

4. a parser to turn a given piece of source code into an AST
  - this will be implemented at the same time as the AST

5. a UI which brings the lower levels to the screen and provides an easily
  usable interface to the language
  - the UI will be implemented last
  - my goal is to have the UI be just a simple stateless function that takes an
    `Environment` and draws it onto the screen, much like a `view` function in
    the Elm architecture

# First milestone

My first goal is to have my VM interpret the following small example that is
given on [UBCLogo’s page][ubclogo-example]:

```
to choices :menu [:sofar []]
if emptyp :menu [print :sofar stop]
foreach first :menu [(choices butfirst :menu sentence :sofar ?)]
end

choices [[small medium large]
         [vanilla [ultra chocolate] lychee [rum raisin] ginger]
         [cone cup]]
```

This example shows the use of function definitions, lists, recursion, functions
with default parameters and template-based iteration (`foreach` in combination
with `?`). Some of these are higher-level concepts that require a few more
basic concepts before they can be implemented. To start with something quite
fundamental, my next post will be about Logo’s distinction between “commands”
(like `print`) and “operations” (like `first`).

[wikipedia-ast]: https://en.wikipedia.org/wiki/Abstract_syntax_tree
[wikipedia-logo]: https://en.wikipedia.org/wiki/Logo_(programming_language)
[wikipedia-ubclogo]: https://en.wikipedia.org/wiki/UCBLogo
[ubclogo]: http://www.cs.berkeley.edu/~bh/logo.html
[ubclogo-example]: https://people.eecs.berkeley.edu/~bh/logo-sample.html
