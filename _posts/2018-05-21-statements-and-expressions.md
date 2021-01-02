---
layout: post
title:  "Statements and expressions in Logo"
date:   2018-05-21 13:30:00 +0200
categories: elm elm-logo
redirect_from:
  - /elm/elm-logo/2018/05/21/statements-and-expressions.html
---

Most programming languages have a distinction between expressions and
statements: [expressions][wikipedia-expression] resolve to a value, while
[statements][wikipedia-statement] can change the state of a program. Logo is
among them even though this difference is not marked by special syntax: an
expression does not look different than a statement, so that both can only be
disambiguated by context. Let’s look at a simple example (`? ` marks Logo’s
prompt):

```
? print "foo
foo
? "foo
You don’t say what to do with foo
? foo
I don’t know how to foo.
```

In the first two examples, the expression `"foo` is syntactically valid, as
evidenced by the absence of syntax errors. In the first example, the expression
`"foo` (which evaluates to the string `foo`, as printed by Logo) is an argument
in the statement `print "foo` which is a valid Logo program. In the second
input, however, the expression `"foo` is syntactically valid, but does not,
standing on its own, constitute a valid Logo program, and Logo prints an error.
In the third example, we see that `foo` without `"` is interpreted as a
function call instead of the string `foo`. Since we haven’t defined a function
named `foo`, we get an error.

```
? print print "foo
foo
print didn’t output to print
```

In this example, we can see that the inner `print "foo` is evaluated before
Logo prints the error message. Although Logo could, in theory, reject the
program at parse time since it knows that while `print "foo` prints a value, it
does not return one, it starts executing it until it encounters a runtime
error.

```
? ifelse "true [ print "foo ] [ print "bar ]
foo
? print ifelse "true [ "foo ] [ "bar ]
foo
? print ifelse "true [ print "foo ] [ "bar ]
foo
print didn’t output to print
```

Here, we can see that `ifelse …` on its own is ambigous: It can be used both as
a statement and as an expression. This falls in line with the previous example:
Logo parses a program and starts executing it until it hits an error. What’s
different in this example is that one can think of situations where it would
not be clear at parse time whether an `ifelse` returns a value or not, e. g.
when the condition depends on user input. While we can indeed for some programs
determine at parse time that they will produce an error at runtime, that is not
possible for all programs. In some situations we apparently have to check at
runtime whether something returns a value.

The first milestone of elm-logo follows a simpler model: the parser will only
recognize statements at the top level (e. g. `print "foo`). User-defined
functions and `ifelse …` will be handled like statements (meaning, they can’t
return a value for now). This simplifies the parser at the expense of turning
some runtime errors into parse errors: the first version won’t, e. g.,
recognize `"foo` as syntactically valid.

[In the next post][next-post], we will have a look at how the VM is structured.
We will explore what data structures are used to represent a Logo program and
how the VM makes use of them to execute a program.

[wikipedia-expression]: https://en.wikipedia.org/wiki/Expression_(computer_science)
[wikipedia-statement]: https://en.wikipedia.org/wiki/Statement_(computer_science)
[next-post]: {{ site.baseurl }}{% post_url 2018-08-27-vm-fundamentals %}
