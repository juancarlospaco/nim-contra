Contra
======

- Lightweight Contract Programming, Design by Contract, on 9 LoC.

.. image:: https://raw.githubusercontent.com/juancarlospaco/nim-contra/master/contra.jpg


# FAQ

- Why not just use [Contracts](https://github.com/Udiknedormin/NimContracts#hello-contracts) ?

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
