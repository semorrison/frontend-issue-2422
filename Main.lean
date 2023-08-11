import Lean.Elab.Frontend

open Lean Elab

unsafe def processInput (input : String) (initializers := false)  :
    IO (Environment × List Message) := do
  let fileName   := "<input>"
  let inputCtx   := Parser.mkInputContext input fileName
  if initializers then enableInitializersExecution
  let (header, parserState, messages) ← Parser.parseHeader inputCtx
  let (env, messages) ← processHeader header {} messages inputCtx
  let s ← IO.processCommands inputCtx parserState (Command.mkState env messages {}) <&> Frontend.State.commandState
  pure (s.env, s.messages.msgs.toList)

open System in
def findLean (mod : Name) : IO FilePath := do
  let olean ← findOLean mod
  let lean := if olean.components.contains "toolchains" then
    olean.toString.replace "lib/lean/" "src/lean/"
  else if olean.components.contains "stage1" then
    olean.toString.replace "build/release/stage1/lib/lean/" "src/"
  else
    olean.toString.replace "build/lib/" ""
  return FilePath.mk lean |>.withExtension "lean"

/-- Read the source code of the named module. -/
def moduleSource (mod : Name) : IO String := do
  IO.FS.readFile (← findLean mod)

unsafe def compileModule (mod : Name) (initializers := false) :
    IO (Environment × List Message) := do
  processInput (← moduleSource mod) initializers

unsafe def main (args : List String) : IO Unit := do
  initSearchPath (← findSysroot)
  let mut initializers := false
  let mut reinit := false
  match ← IO.getEnv "LEAN_INITIALIZERS" with
  | some "ONCE" =>
    IO.println "Invoking `enableInitializersExecution` once at the beginning."
    enableInitializersExecution
  | some "EACH" =>
    IO.println "Invoking `enableInitializersExecution` at each compilation."
    initializers := true
  | some "REINIT" =>
    IO.println "Invoking `enableInitializersExecution` and `enableReinitialization` at each compilation."
    initializers := true
    reinit := true
  | _ =>
    IO.println "Not invoking `enableInitializersExecution`"
  for mod in args do
    IO.println s!"Compiling {mod}"
    let (env, msgs) ← compileModule mod.toName initializers
    if reinit then enableReinitialization env
    for m in msgs do dbg_trace ← m.toString

-- % LEAN_INITIALIZERS=FALSE lake exe frontend Mathlib.Algebra.Abs
-- Not invoking `enableInitializersExecution`
-- Compiling Mathlib.Algebra.Abs
-- libc++abi: terminating with uncaught exception of type lean::exception: cannot evaluate `[init]` declaration 'Mathlib.Prelude.Rename.linter.uppercaseLean3' in the same module

-- % LEAN_INITIALIZERS=ONCE lake exe frontend Mathlib.Algebra.Abs
-- Invoking `enableInitializersExecution` once at the beginning.
-- Compiling Mathlib.Algebra.Abs

-- % LEAN_INITIALIZERS=ONCE lake exe frontend Mathlib.Algebra.AddTorsor
-- Invoking `enableInitializersExecution` once at the beginning.
-- Compiling Mathlib.Algebra.AddTorsor

-- % LEAN_INITIALIZERS=ONCE lake exe frontend Mathlib.Algebra.Abs Mathlib.Algebra.AddTorsor
-- Invoking `enableInitializersExecution` at each compilation.
-- Compiling Mathlib.Algebra.Abs
-- Compiling Mathlib.Algebra.AddTorsor
-- libc++abi: terminating with uncaught exception of type lean::exception: cannot evaluate `[init]` declaration 'Mathlib.Tactic.reflExt' in the same module

-- % LEAN_INITIALIZERS=EACH lake exe frontend Mathlib.Algebra.Abs
-- Invoking `enableInitializersExecution` at each compilation.
-- Compiling Mathlib.Algebra.Abs

-- % LEAN_INITIALIZERS=EACH lake exe frontend Mathlib.Algebra.AddTorsor
-- Invoking `enableInitializersExecution` once at the beginning.
-- Compiling Mathlib.Algebra.AddTorsor

-- % LEAN_INITIALIZERS=EACH lake exe frontend Mathlib.Algebra.Abs Mathlib.Algebra.AddTorsor
-- Invoking `enableInitializersExecution` at each compilation.
-- Compiling Mathlib.Algebra.Abs
-- Compiling Mathlib.Algebra.AddTorsor
-- PANIC at Lean.PersistentHashMap.find! Lean.Data.PersistentHashMap:160:14: key is not in the map
-- ...
-- <input>:6:0: error: invalid option declaration 'linter.uppercaseLean3', option already exists
-- ...

-- % LEAN_INITIALIZERS=REINIT lake exe frontend Mathlib.Algebra.Abs Mathlib.Algebra.AddTorsor
-- Invoking `enableReinitialization`.
-- Compiling Mathlib.Algebra.Abs
-- Compiling Mathlib.Algebra.AddTorsor