import Lake
open Lake DSL

package frontend

@[default_target]
lean_lib Frontend

lean_exe frontend {
  root := `Main
  supportInterpreter := true
}
