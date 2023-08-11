import Frontend.Compile

open Lean

-- No messages are printed.
#eval show MetaM _ from do
  let (_, msgs, _) ← compileModule `Frontend.Main (initializers := true)
  for m in msgs do dbg_trace ← m.toString
  return msgs.length
