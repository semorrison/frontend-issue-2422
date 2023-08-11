import Frontend

open Lean

-- No messages are printed
#eval show MetaM _ from do
  let (_, msgs) ← compileModule `Mathlib.Algebra.Abs (initializers := false)
  for m in msgs do IO.println (← m.toString)
  return msgs.length
