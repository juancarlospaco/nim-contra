## Contra
## ======
##
## Lightweight runtime Contract Programming(DbC),designed for ``proc``/``func``,
## 2 Templates for Preconditions (Require) & Postconditions (Ensure) on 9 LoC.
## For performance it wont generate any code when build for release. Recommended
## `func <https://nim-lang.org/docs/manual.html#procedures-func>`_ and use of
## `Concepts <https://nim-lang.org/docs/manual_experimental.html#concepts>`_
## - https://en.wikipedia.org/wiki/Defensive_programming#Other_techniques
## - http://stackoverflow.com/questions/787643/benefits-of-assertive-programming

template preconditions*(requires: varargs[bool]) =
  ## Require (Preconditions) for runtime Contract Programming on proc/func.
  when not defined(release):
    for i, contractPrecondition in requires: assert(contractPrecondition,
        "\nContract Precondition (Require) failed assert on position: " & $i)

template postconditions*(ensures: varargs[bool]) =
  ## Ensure (Postconditions) for runtime Contract Programming on proc/func.
  when not defined(release):
    defer:
      for i, contractPostcondition in ensures: assert(contractPostcondition,
          "\nContract Postcondition (Ensure) failed assert on position: " & $i)


# when isMainModule:
runnableExamples:
  func funcWithContract(mustBePositive: int): int {.compiletime.} =
    preconditions mustBePositive > 0, mustBePositive > -1 ## Require (Preconditions)
    postconditions result > 0, result < int32.high        ## Ensure  (Postconditions)
    result = mustBePositive - 1 ## Mimic some logic, notice theres no "body" block
  assert funcWithContract(2) > 0

  func funcWithoutContract(mustBePositive: int): int =
    result = mustBePositive - 1 ## Same func but without Contract templates.
  echo funcWithoutContract(1) > 0, " <-- This must be 'true', if not is a Bug!"
