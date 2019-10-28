## Contra
## ======
##
## Lightweight Contract Programming (DbC) and optional Hardened Build mode
## (Based from Debian Hardened & Gentoo Hardened),designed for ``proc``/``func``,
## 2 Templates for Preconditions (Require) & Postconditions (Ensure) on 9 LoC.
## For performance it wont generate any code when build for release. Recommended
## `func <https://nim-lang.org/docs/manual.html#procedures-func>`_ and use of
## `Concepts <https://nim-lang.org/docs/manual_experimental.html#concepts>`_
## - https://en.wikipedia.org/wiki/Defensive_programming#Other_techniques
## - http://stackoverflow.com/questions/787643/benefits-of-assertive-programming
import macros
from strutils import strip, splitLines


when not defined(danger) and not defined(release) and defined(gcc):
  when defined(linux) or defined(windows) or defined(macos) and not defined(js):
    import os  # C Source code debug,similar to JS Source Maps,prints C code corresponding to the same Nim code.
    func internalAssercho(arg: any): void {.importc: "internalAssercho", header: currentSourcePath().splitPath.head / "assercho.h".}


const msg0 = "## **Self-Documenting Design by Contract:** Require Preconditions *("
const err0 = """Contra Require Precondition wrong syntax (conditionBool, errorString),
errorString must be 1 non-empty single-line human-friendly descriptive string literal,
Self-Documenting Design by Contract will replace errorString with macros.NimNode.lineInfo: """


macro assercho*(conditionBool: bool, errorString: string) =
  ## ``assert(conditionBool,errorString)`` + ``echo(Nim_Code)`` + ``printf(C_Code)`` Combined
  ## but only ``when not defined(release) and not defined(danger)`` for Debug.
  when not defined(danger) and not defined(release) and defined(gcc):
    when defined(linux) or defined(windows) or defined(macos) and not defined(js):
      let o_O = strip($conditionBool.toStrLit)
      result = parseStmt(
        "debugEcho(r\"\"\"Nim\t" & o_O & " = \"\"\", " & o_O & ", r\"\"\" --> " & conditionBool.lineInfo & "\"\"\")\n" &
        "internalAssercho(" & o_O & ")\n" &
        "assert(bool(" & o_O & "), r\"\"\"" & errorString.strVal.strip & "\"\"\")\n")


template preconditions*(requires: varargs[bool]) =
  ## Require (Preconditions) for Contract Programming on proc/func.
  when not defined(release) or defined(contracts):
    for i, contractPrecondition in requires: assert(contractPrecondition,
        "\nContract Precondition (Require) failed assert on position: " & $i)

template postconditions*(ensures: varargs[bool]) =
  ## Ensure (Postconditions) for Contract Programming on proc/func.
  when not defined(release) or defined(contracts):
    defer:
      for i, contractPostcondition in ensures: assert(contractPostcondition,
          "\nContract Postcondition (Ensure) failed assert on position: " & $i)

macro preconditions*(requires: varargs[tuple[conditionBool: bool, errorString: string]]) =
  ## Require (Preconditions) for Self-Documenting Design by Contract on proc/func.
  when not defined(release) or defined(contracts):
    var i: byte
    var code, msg, lin, nimc: string
    var rsts = msg0 & $requires.len & " total)*.\n"
    for line in requires:
      lin = line.lineInfo
      msg = line[1].strVal.strip
      nimc = strip($line[0].toStrLit)
      if msg.len == 0:
        warning(err0 & lin)
        msg = lin
      if msg.splitLines.len != 1:
        warning(err0 & lin)
        msg = lin
      inc i
      rsts &= "## * **" & $i & "** ``assert(" & nimc & ", \"" & msg & "\")`` --> " & lin & "\n"
      code &= "assert(bool(" & nimc & "), r\"\"\"" & msg & "\"\"\")\n"
    result = parseStmt(rsts & code)


template hardenedBuild*() =
  ## Optional Security Hardened mode (Based from Debian Hardened & Gentoo Hardened).
  ## See: http:wiki.debian.org/Hardening & http:wiki.gentoo.org/wiki/Hardened_Gentoo
  ## http:security.stackexchange.com/questions/24444/what-is-the-most-hardened-set-of-options-for-gcc-compiling-c-c
  # Hardened build is ideal companion for a Contracts module,still optional anyway.
  when defined(hardened) and defined(gcc) and not defined(objc) and not defined(js):
    when defined(danger):
      {.fatal: "-d:hardened is incompatible with -d:danger".}
    when not defined(contracts):
      {.fatal: "-d:hardened requires -d:contracts".}
    {.hint: "Security Hardened mode is enabled.".}
    const hf = "-fstack-protector-all -Wstack-protector --param ssp-buffer-size=4 -pie -fPIE -Wformat -Wformat-security -D_FORTIFY_SOURCE=2 -Wall -Wextra -Wconversion -Wsign-conversion -mindirect-branch=thunk -mfunction-return=thunk -fstack-clash-protection -Wl,-z,relro,-z,now -Wl,-z,noexecstack -fsanitize=signed-integer-overflow -fsanitize-undefined-trap-on-error -fno-common"
    {.passC: hf, passL: hf, assertions: on, checks: on.}

  when defined(danger) and defined(release) and defined(gcc) and not defined(hardened):
    {.passC: "-flto -ffast-math -march=native -mtune=native -fsingle-precision-constant".}
    when defined(linux) or defined(windows) or defined(macos) and not defined(js):
      {.hint: "Compile-Time Term-Rewriting Template Optimizations is enabled.".}
      func fwrite(formatstr: cstring, size = 1.cuint, nmemb: cuint, stream = stdout) {.importc, header: "<stdio.h>".}
      template echo*(s: any{lit, noalias}) =          # SomeOrdinal? SomeNumber?
        fwrite($s & "\n", nmemb = len($s) + 1)        # Whats better?
      template echo*(s0, s1: any{lit, noalias}) =  # fwrite() > puts() > printf()
        fwrite($s0 & $s1 & "\n", nmemb = len($s0) + len($s1) + 1)
      template echo*(s0, s1, s2: any{lit, noalias}) =
        fwrite($s0 & $s1 & $s2 & "\n", nmemb = len($s0) + len($s1) + len($s2) + 1)
      template echo*(s0, s1, s2, s3: any{lit, noalias}) =
        fwrite($s0 & $s1 & $s2 & $s3 & "\n", nmemb = len($s0) + len($s1) + len($s2) + len($s3) + 1)
      template echo*(s0, s1, s2, s3, s4: any{lit, noalias}) =
        fwrite($s0 & $s1 & $s2 & $s3 & $s4 & "\n", nmemb = len($s0) + len($s1) + len($s2) + len($s3) + len($s4) + 1)
      template echo*(s0, s1, s2, s3, s4, s5: any{lit, noalias}) =
        fwrite($s0 & $s1 & $s2 & $s3 & $s4 & $s5 & "\n",
          nmemb = len($s0) + len($s1) + len($s2) + len($s3) + len($s4) + len($s5) + 1)
      template echo*(s0, s1, s2, s3, s4, s5, s6: any{lit, noalias}) =
        fwrite($s0 & $s1 & $s2 & $s3 & $s4 & $s5 & $s6 & "\n",
          nmemb = len($s0) + len($s1) + len($s2) + len($s3) + len($s4) + len($s5) + len($s6) + 1)
      template echo*(s0, s1, s2, s3, s4, s5, s6, s7: any{lit, noalias}) =
        fwrite($s0 & $s1 & $s2 & $s3 & $s4 & $s5 & $s6 & $s7 & "\n",
          nmemb = len($s0) + len($s1) + len($s2) + len($s3) + len($s4) + len($s5) + len($s6) + len($s7) + 1)
      template echo*(s0, s1, s2, s3, s4, s5, s6, s7, s8: any{lit, noalias}) =
        fwrite($s0 & $s1 & $s2 & $s3 & $s4 & $s5 & $s6 & $s7 & $s8 & "\n",
          nmemb = len($s0) + len($s1) + len($s2) + len($s3) + len($s4) + len($s5) + len($s6) + len($s7) + len($s8) + 1)
      template debugEcho*(s: any{lit, noalias}) =
        fwrite($s & "\n", nmemb = len($s) + 1)
      template debugEcho*(s0, s1: any{lit, noalias}) =
        fwrite($s0 & $s1 & "\n", nmemb = len($s0) + len($s1) + 1)
      template debugEcho*(s0, s1, s2: any{lit, noalias}) =
        fwrite($s0 & $s1 & $s2 & "\n", nmemb = len($s0) + len($s1) + len($s2) + 1)
      template debugEcho*(s0, s1, s2, s3: any{lit, noalias}) =
        fwrite($s0 & $s1 & $s2 & $s3 & "\n", nmemb = len($s0) + len($s1) + len($s2) + len($s3) + 1)
      template debugEcho*(s0, s1, s2, s3, s4: any{lit, noalias}) =
        fwrite($s0 & $s1 & $s2 & $s3 & $s4 & "\n", nmemb = len($s0) + len($s1) + len($s2) + len($s3) + len($s4) + 1)
      template debugEcho*(s0, s1, s2, s3, s4, s5: any{lit, noalias}) =
        fwrite($s0 & $s1 & $s2 & $s3 & $s4 & $s5 & "\n",
          nmemb = len($s0) + len($s1) + len($s2) + len($s3) + len($s4) + len($s5) + 1)
      template debugEcho*(s0, s1, s2, s3, s4, s5, s6: any{lit, noalias}) =
        fwrite($s0 & $s1 & $s2 & $s3 & $s4 & $s5 & $s6 & "\n",
          nmemb = len($s0) + len($s1) + len($s2) + len($s3) + len($s4) + len($s5) + len($s6) + 1)
      template debugEcho*(s0, s1, s2, s3, s4, s5, s6, s7: any{lit, noalias}) =
        fwrite($s0 & $s1 & $s2 & $s3 & $s4 & $s5 & $s6 & $s7 & "\n",
          nmemb = len($s0) + len($s1) + len($s2) + len($s3) + len($s4) + len($s5) + len($s6) + len($s7) + 1)
      template debugEcho*(s0, s1, s2, s3, s4, s5, s6, s7, s8: any{lit, noalias}) =
        fwrite($s0 & $s1 & $s2 & $s3 & $s4 & $s5 & $s6 & $s7 & $s8 & "\n",
          nmemb = len($s0) + len($s1) + len($s2) + len($s3) + len($s4) + len($s5) + len($s6) + len($s7) + len($s8) + 1)
      template optimizedFloatDivision*{f0 / f1}(f0: SomeFloat, f1: SomeFloat{lit, noalias}): untyped =
        ## Float Division slower than multiplication. Eg x/3.0 --> x*(1.0/3.0)
        f0 * static(1.0 / f1)  # Rewrite division by constant to multiplication with the inverse.

  when defined(release) and defined(gcc):
    {.passL: "-s".}


template deepCopy*(immutableVariable, changes: untyped): untyped =
  ## Mimic Scalas ``val immutableButChanged = immutable.copy(attribute = 9)``.
  ## Change Immutable Variables, and remain Immutable, but with mutated copy.
  block:  # Original idea by Solitude. See the runnableExamples.
    var this {.inject.} = system.deepCopy(immutableVariable)
    changes
    this


# when isMainModule:
runnableExamples:
  hardenedBuild() ## Security Hardened mode enabled, compile with:  -d:hardened


  # ^ Hardened Build Templates ########## v Preconditions/Postconditions (DbC)


  func funcWithContract*(mustBePositive: int): int =
    preconditions((mustBePositive > 0, "Preconditions Document itself"),
      (mustBePositive > -1, "RST Doc via Macros"), (2 > 1, "DbC FTW"),
    )                                                       ## Require (Preconditions) Alternative 1.
    # preconditions mustBePositive > 0, mustBePositive > -1 ## Require (Preconditions) Alternative 2.
    postconditions result > 0, result < int32.high          ## Ensure  (Postconditions)
    result = mustBePositive - 1 ## Mimic some logic,notice theres no "body" block

  discard funcWithContract(2)

  func funcWithoutContract(mustBePositive: int): int =
    result = mustBePositive - 1 ## Same func but without Contract templates.
  echo funcWithoutContract(1) > 0, " <-- This must be 'true', if not is a Bug!"


  # ^ Preconditions/Postconditions (DbC) ################# v deepCopy Templates


  type Person = object # Changing Immutable Variables,into Immutable Variables.
    name: string
    age: Natural
  let
    bob = Person(name: "Bob", age: 42)  # Immutable Variable, original.
    olderBob = bob.deepCopy:            # Immutable Variable, but changed.
      this.age = 45
      this.name = this.name[0..^2]
    otherBob = deepCopy(bob)            # Immutable Variable,by system.deepCopy
  echo bob        # (name: "Bob", age: 42)      Original Immutable
  echo olderBob   # (name: "Bo", age: 45)       Changed Immutable
  echo otherBob   # (name: "Bob", age: 42)      Just to control is not confused

  # ^ deepCopy Templates ############################# v assercho (assert+echo)


  let foo = 42
  let bar = 9
  assercho(foo > bar, "Assercho for all the Brochachos!")


  # ^ assercho (assert+echo+C Debug) ########## v echo(literal) Optimizations


  echo "a"
  echo "a", "b"
  echo "a", "b", "c"
  echo "a", "b", "c", "d"
  echo "a", "b", "c", "d", "e"
  echo "a", "b", "c", "d", "e", "f"
  echo "a", "b", "c", "d", "e", "f", "g"
  echo "a", "b", "c", "d", "e", "f", "g", "h"
  echo 1
  echo 1, 2
  echo 1, 2, 3
  echo 1, 2, 3, 4
  echo 1, 2, 3, 4, 5
  echo 1, 2, 3, 4, 5, 6
  echo 1, 2, 3, 4, 5, 6, 7
  echo 1, 2, 3, 4, 5, 6, 7, 8
  debugEcho "a"
  debugEcho "a", "b"
  debugEcho "a", "b", "c"
  debugEcho "a", "b", "c", "d"
  debugEcho "a", "b", "c", "d", "e"
  debugEcho "a", "b", "c", "d", "e", "f"
  debugEcho "a", "b", "c", "d", "e", "f", "g"
  debugEcho "a", "b", "c", "d", "e", "f", "g", "h"
  debugEcho 1
  debugEcho 1, 2
  debugEcho 1, 2, 3
  debugEcho 1, 2, 3, 4
  debugEcho 1, 2, 3, 4, 5
  debugEcho 1, 2, 3, 4, 5, 6
  debugEcho 1, 2, 3, 4, 5, 6, 7
  debugEcho 1, 2, 3, 4, 5, 6, 7, 8


  # ^ echo(literal) Optimizations ############## v Float Division Optimizations


  var x, y = 2.0
  echo x / 2.0
  echo y / x
