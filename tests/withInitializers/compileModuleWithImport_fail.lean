import Frontend.Compile
import Frontend.DummyExt

open Lean

-- Messages are generated:
-- `invalid environment extension, 'dummyExt' has already been used`
#eval show MetaM _ from do
  let (_, msgs, _) ← compileModule `Frontend.Main (initializers := true)
  for m in msgs do IO.println (← m.toString)
  return ()
