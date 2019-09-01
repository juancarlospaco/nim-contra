Contra
======

- Lightweight and fast Self-Documenting Design by Contract Programming, Design by Contract, zero cost at runtime.
- `Security Hardened <https://en.wikipedia.org/wiki/Hardening_%28computing%29#Binary_hardening>`_ mode (based from `Debian Hardened <https://wiki.debian.org/Hardening>`_ & `Gentoo Hardened <https://wiki.gentoo.org/wiki/Hardened_Gentoo>`_, checked with `hardening-check <https://bitbucket.org/Alexander-Shukaev/hardening-check>`_).
- Change `Immutable variables <https://en.wikipedia.org/wiki/Immutable_object>`_, into Immutable variables, Immutable programming.

.. image:: https://raw.githubusercontent.com/juancarlospaco/nim-contra/master/contra.jpg
  :align: center

- Produces no code at all when build for release, `KISS <http://wikipedia.org/wiki/KISS_principle>`_
- Works on NimScript, JavaScript, ``{.compiletime.}`` and ``static:``.


Use
===

Design By Contract
------------------

.. image:: https://raw.githubusercontent.com/juancarlospaco/nim-contra/master/selfdocumentdbc.png
  :align: center

.. code-block:: nim

  import contra

  func funcWithContract(mustBePositive: int): int =
    preconditions mustBePositive > 0, mustBePositive > -1 ## Require (Preconditions)
    postconditions result > 0, result < int32.high        ## Ensure  (Postconditions)

    result = mustBePositive - 1 ## Mimic some logic, notice theres no "body" block

  discard funcWithContract(2)
  # discard funcWithContract(0)  # Uncomment to see it fail as expected.


Hardened mode
-------------

.. code-block:: nim

  import contra
  hardenedBuild()  # Security Hardened mode enabled, compile with:  -d:hardened
  echo "Hello World"


Changing Immutable Variables
----------------------------

.. code-block:: nim

  import contra

  type Person = object # Changing Immutable Variables,into Immutable Variables.
    name: string
    age: Natural

  let
    bob = Person(name: "Bob", age: 42)  # Immutable Variable, original.
    olderBob = bob.deepCopy:            # Immutable Variable, but changed.
      this.age = 45
      this.name = this.name[0..^2]

  echo bob       # (name: "Bob", age: 42)      Original Immutable
  echo olderBob  # (name: "Bo", age: 45)       Changed Immutable

Its inspired by Scala:

.. code-block:: scala

  val immutableButChanged = immutable.copy(attribute = 9)


Assercho
--------

``assert(conditionBool, errorString)`` + ``echo(Nim_Code)`` + ``printf(C_Code)`` Combined *"3-in-1"*.

.. image:: https://raw.githubusercontent.com/juancarlospaco/nim-contra/master/assercho.png
  :align: center

- Is different than ``echo`` that you dont have to manually remove it from the code for Release builds.
- Is different than ``assert`` that it prints to terminal when ``conditionBool`` is ``true``.

It only works ``when not defined(release) and not defined(danger)`` for Debugging purposes.

C Source code debug is similar to JS Source Maps, shows C code corresponding to the same Nim code.

The assertion is a vanilla ``assert``, when fails produces an ``AssertionError``.

Produces No code at all when build for Release, zero runtime performance cost. ``assercho`` is a Macro.

``assercho`` when ``assert`` is ``true`` (Ok)

.. code-block:: nim

  import contra

  let foo = 42
  let bar = 9
  assercho(foo > bar, "Assercho for all the Brochachos!")  # 42 > 9

.. code-block:: bash

  Nim   foo > bar = true --> /home/juan/code/example.nim(3, 8)
  C     (bar_1kqJRPNteJWdjlPR09aibuA < foo_FvFJfeatIb8qi8DN7lzoAQ) = 1 --> /tmp/example.nim.c(9)

``assercho`` when ``assert`` is ``false`` (Error)

.. code-block:: nim

  import contra

  let foo = 42
  let bar = 9
  assercho(foo < bar, "Assercho for all the Brochachos!")  # 42 < 9

.. code-block:: bash

  Nim   foo < bar = false --> /home/juan/code/example.nim(3, 8)
  C     (bar_1kqJRPNteJWdjlPR09aibuA < foo_FvFJfeatIb8qi8DN7lzoAQ) = 0 --> /tmp/example.nim.c(9)
  Error: unhandled exception: `foo < bar` Assercho for all the Brochachos! [AssertionError]

Replaces approx the following code:

.. code-block:: nim

  when not defined(danger) and not defined(release):
    debugEcho "foo = ", foo
    debugEcho "bar = ", bar
    debugEcho foo > bar
    assert foo > bar, "Error message"
    # Custom Macro to get the Nim Source Code line info of origin (macros.NimNode.LineInfo)
    # Custom Macro/Template to get the C Source Code line info of origin


Compile-Time Term-Rewriting Template Optimizations
--------------------------------------------------

- ``echo()`` and ``debugEcho()`` gets Rewritten to use ``fwrite()`` from ``stdio.h`` directly. Logging is not touched.
- ``fwrite()`` is faster than ``puts()``, ``puts()`` is faster than ``printf()``. ``fwrite() > puts() > printf()``.
- Optimizations are optional, only get enabled ``when defined(release) and defined(danger)``.

.. code-block:: nim

  echo "a", "b", "c"

Gets optimized to:

.. code-block:: c

  fwrite("abc\012", ((unsigned int) 1), ((unsigned int) 4), stdout);

- Float Division is slower than multiplication. `1` CPU Cycle for Multiplication, `100` CPU Cycles or more for Division.
- Float Division gets Rewritten to multiplication with the inverse.
- Example ``x / 3.0`` --> ``x * static(1.0 / 3.0)``.
- Optimizations are optional, only get enabled ``when defined(release) and defined(danger)``.

.. code-block:: nim

  var x, y = 2.0
  echo x / 2.0

Gets optimized to:

.. code-block:: c

  NF x_9b3J8iZeIHRoRKYxMY9a9bzzQ;
  x_9b3J8iZeIHRoRKYxMY9a9bzzQ = 2.0000000000000000e+00;
  ( (NF)(x_9b3J8iZeIHRoRKYxMY9a9bzzQ) * (NF)(5.0000000000000000e-01) );

- `For more info check this commit. <https://github.com/juancarlospaco/nim-contra/commit/16f0bd40a1584a589c234dd16e59074ff8d7dabd#commitcomment-34858271>`_


Description
-----------

**Contract Preconditions:**

- ``preconditions`` takes preconditions separated by commas, asserts on arguments or local variables.

**Contract Postconditions:**

- ``postconditions`` takes postconditions separated by commas, must assert on ``result``, can assert on local variables.

**Contracts Preconditions and Postconditions:**

- ``postconditions`` must be AFTER ``preconditions``.
- ``postconditions`` must NOT be repeated.
- ``-d:contracts`` Force enable Contracts, can be used independently of ``-d:release``.

**Security Hardened Mode:**

- ``-d:hardened`` Force enable Security Hardened mode, can be used independently of ``-d:release``.
- ``-d:hardened`` requires ``-d:contracts``.
- Security Hardened mode only works for default target backend.
- Produces no code at all if ``-d:hardened`` is not defined.
- ``hardenedBuild()`` is 1 Template, takes no arguments, returns nothing.
- ``hardenedBuild()`` must be called on the root top of your main module.
- Hardened build is ideal companion for a Contracts module, still optional anyway.

**Changing Immutable Variables:**

- ``deepCopy`` Lets you change Immutable Variables, into Immutable Variables, using Mutated copies. It mimic Scala's ``val immutableButChanged = immutable.copy(attribute = 9)``. Immutable programming.

**Assercho:**

- ``assert`` + ``echo`` = ``assercho``. Assertive programming util.


Install
-------

- ``nimble install contra``


FAQ
---

- Why not just use `Contracts <https://github.com/Udiknedormin/NimContracts#hello-contracts>`_ ?

.. code-block::

  $ cat example.nim
  import contracts
  from math import sqrt, floor
  proc isqrt[T: SomeInteger](x: T): T {.contractual.} =
    require:
      x >= 0
    ensure:
      result * result <= x
      (result+1) * (result+1) > x
    body:
      (T)(x.toBiggestFloat().sqrt().floor().toBiggestInt())
  echo isqrt(18)
  echo isqrt(-8)

  $ nim js -r example.nim
  Error: undeclared identifier: 'deepCopy'

  $ nim e example.nim
  Error: undeclared identifier: 'deepCopy'

  $ cat example2compiletime.nim
  import contracts
  from math import sqrt, floor
  proc isqrt[T: SomeInteger](x: T): T {.contractual, compiletime.} =
    require:
      x >= 0
    ensure:
      result * result <= x
      (result+1) * (result+1) > x
    body:
      (T)(x.toBiggestFloat().sqrt().floor().toBiggestInt())
  echo isqrt(18)
  echo isqrt(-8)

  $ nim c -r example2compiletime.nim
  Error: request to generate code for .compileTime proc: isqrt

  $ cloc ~/.nimble/pkgs/contracts-0.1.0/
  Language          files         blank        comment        code
  ----------------------------------------------------------------
  Nim               21            119          515            640


- Whats Contract Programming, Design by Contract?.

https://www.youtube.com/watch?v=DRVoh5XiAZo

https://en.wikipedia.org/wiki/Defensive_programming#Other_techniques

http://stackoverflow.com/questions/787643/benefits-of-assertive-programming

https://en.wikipedia.org/wiki/Hoare_logic#Hoare_triple

- What about No Side Effects?.

https://nim-lang.org/docs/manual.html#procedures-func

https://nim-lang.org/docs/manual.html#pragmas-nosideeffect-pragma

- What about Types?.

https://nim-lang.org/docs/manual_experimental.html#concepts

- How to use this at Compile Time?.

Add ``{.compiletime.}`` or ``static:``.

- What about ``assume`` blocks?.

Assume blocks produce no code at all and are only meant for human reading only,
you can do that using ``discard`` or similar contruct on Nim. KISS.

- What about ``body`` blocks?.

This library does NOT uses nor needs ``body`` blocks.

- What about ``invariant`` blocks?.

You can pass Invariants on the ``postconditions`` block.

- What about ``forall`` and ``forsome`` blocks?.

Use ``sequtils.filterIt``, ``sequtils.mapIt``, ``sequtils.keepItIf``, ``sequtils.allIt``, ``sequtils.anyIt``, etc.

- What about ``ghost`` block?.

Use ``when defined(release):`` or ``when defined(contracts):``

- Whats the performance and speed cost of using Contra?.

Zero cost at runtime, since it produces no code at all when build for Release.

- I prefer the naming ``require`` and ``ensure`` ?.

.. code-block:: nim

  from contra import preconditions as require
  from contra import postconditions as ensure


- I prefer the naming ``pre`` and ``post`` ?.

.. code-block:: nim

  from contra import preconditions as pre
  from contra import postconditions as post


- If I add this to my project I am forced to use it everywhere?.

No.

The code will just work on blocks without Contract.
You only need to add 2 lines to your existing code (1 for Preconditions, 1 for Postconditions).
Is recommended to at least use it con "core" functionality.

- Whats Hardened mode ?.

https://en.wikipedia.org/wiki/Hardening_%28computing%29#Binary_hardening

- More Documentation?.

``nim doc contra.nim``


*" TDD is Poor-Man's Contracts "*
