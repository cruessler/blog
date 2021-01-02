---
layout: post
title: "How the elm-logo VM executes code"
date:   2018-08-27 18:26:00 +0200
---

In elm-logo, any program is first parsed into a so-called “Abstract Syntax
Tree”, or “AST” for short. If you’re not familiar with what an AST is, you can
find a great introduction with links to resources in [Vaidehi Joshi’s
explanation of ASTs at BaseCS][basecs-asts].

The AST which represents the structure of the Logo code is, in a second step,
compiled to a list of instructions. These instructions are fed to the VM which
executes them one at a time. Each instruction modifies the state of the VM and
produces a new state. As soon as there is no more instruction to be executed,
the execution stops.

In this post, we will first have a look at some of the parts of our simple VM.
We will then take a basic program to see how it is represented and executed by
the VM.

## The VM

In the [first milestone][first-milestone], the VM is defined as follows:

```elm
type alias Vm =
    { instructions : Array Instruction
    , programCounter : Int
    , stack : List Type.Value
    , scopes : List Scope
    , environment : Environment
    , functionTable : Dict String Int
    }
```

- `instructions` is an `Array` containing the instructions of the compiled
  program. Its indices start at `0`.
- `programCounter` points at the instruction that is to be executed next. The
  counter is incremented after every instruction. It can be changed by one of
  the jump instructions which is used to implement control flow like `if` and
  `foreach`.
- `stack` is the VM’s stack. Under the hood, it is a list that is initially
  empty. The VM uses the stack to store intermediate values and pass them
  around between functions. While the program is executed, the stack grows in
  one direction and shrinks in the opposite direction.
- `environment` contains the state of the Logo world that goes beyond
  intermediate values and variables. In the first milestone, this record
  contains the lines that are printed via `print`, but in later versions it
  will be expanded to hold the objects that have been drawn to the screen.
- `scopes` is the VM’s stack of variable scopes. These scopes store the values
  of variables and will be explained in a later post.
- `functionTable` contains the addresses of compiled functions and will be
  explained in a later post as well.

## An example program

```
ifelse "true [ print "first ] [ print "second ]
```

Let’s have a look at the above example program to see how the VM represents and
executes it (`scopes` and `functionTable` are omitted for brevity). Given this
simple program, the VM’s initial state is the following:

```elm
{ instructions =
    [ PushValue <| Type.Word "true"
    , JumpIfFalse 4
    , PushValue <| Type.Word "first"
    , Command1 { name = "print", f = C.print }
    , Jump 3
    , PushValue <| Type.Word "second"
    , Command1 { name = "print", f = C.print }
    ]
        |> Array.fromList
, programCounter = 0
, stack = []
, environment = Environment.empty
}
```

We will trace the execution of the program one instruction at a time. At each
step, we will see a short representation of the VM’s state to get an idea of
how each instruction changes it.

The first instruction, `PushValue`, pushes its argument onto the stack. The
program counter is incremented and the execution continues.

```elm
{ programCounter = 1
, stack = [ Type.Word "true" ]
}
```

Then, `JumpIfFalse` pops the topmost element of the stack and does nothing
because `true` is not `false`. If the topmost value of the stack would have
been `false` the `programCounter` would have been incremented by 4 (because the
argument to `JumpIfFalse` was 4).

```elm
{ programCounter = 2
, stack = []
}
```

Next, a second value is pushed onto the stack.

```elm
{ programCounter = 3
, stack = [ Type.Word "first" ]
}
```

This time, the value gets popped and appended to the array of printed lines.
After the only value got popped, the stack is empty again.

```elm
{ programCounter = 4
, stack = []
, environment = { lines = [ "first" ] |> Array.fromList }
}
```

The last instruction that gets executed is a `Jump`. The jump is relative,
meaning that the target address is computed by adding a value to
`programCounter`, and unconditional, meaning that the jump does not depend on
the outcome of a previous computation.

```elm
{ programCounter = 7
, stack = []
, environment = { lines = [ "first" ] |> Array.fromList }
}
```

Now the `programCounter` does not point at a valid instruction anymore, and the
program stops. We have successfully executed the following program:

```
ifelse "true [ print "first ] [ print "second ]
```

The next post will have a look at how variables are stored by the VM.

[basecs-asts]: https://medium.com/basecs/leveling-up-ones-parsing-game-with-asts-d7a6fc2400ff
[first-milestone]: https://github.com/cruessler/elm-logo/tree/milestone-1
