Contra
======

- Lightweight Contract Programming, Design by Contract, on 9 LoC.
- Produces no code when build for release, works on NimScript and JavaScript too.

.. image:: https://raw.githubusercontent.com/juancarlospaco/nim-contra/master/contra.jpg

Use
---

.. code-block:: nim

  func funcWithContract(mustBePositive: int): int =
    preconditions mustBePositive > 0, mustBePositive > -1 ## Require (Preconditions)
    postconditions result > 0, result < int32.high        ## Ensure  (Postconditions)

    result = mustBePositive - 1 ## Mimic some logic, notice theres no "body" block

  discard funcWithContract(2)
  # discard funcWithContract(0)


Install
-------

- ``nimble install contra``


FAQ
---

- Why not just use `Contracts <https://github.com/Udiknedormin/NimContracts#hello-contracts>`_ ?

.. code-block:: nim

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

  $ cloc ~/.nimble/pkgs/contracts-0.1.0/
  Language          files         blank        comment        code
  ----------------------------------------------------------------
  Nim               21            119          515            640


- Whats Contract Programming, Design by Contract?.

https://en.wikipedia.org/wiki/Defensive_programming#Other_techniques

http://stackoverflow.com/questions/787643/benefits-of-assertive-programming

- What about No Side Effects?.

https://nim-lang.org/docs/manual.html#procedures-func

https://nim-lang.org/docs/manual.html#pragmas-nosideeffect-pragma

https://nim-lang.org/docs/manual_experimental.html#concepts
