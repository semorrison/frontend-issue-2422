import Frontend.Compile
import Frontend.Import2

/-!

When compiles, this file works fine:
```
lake exe main Frontend.Import1
```

However in the interpreter,
if we uncomment the `#eval` below there are error messages while compiling.

These errow messages go away if we remove the `import Frontend.Import2` above:
the problem is that both this file and `Frontend.Import` import
`Frontend.RegisterOption`.


-/

open Lean

unsafe def main (args : List String) : IO UInt32 := do
  initSearchPath (← findSysroot)
  let mut count : UInt32 := 0
  for mod in args do
    IO.println s!"Compiling {mod}"
    let (_env, msgs) ← compileModule mod.toName true
    for m in msgs do IO.println (← m.toString)
    if msgs.length > 0 then count := 1
  return count

-- #eval main ["Frontend.Import1"]