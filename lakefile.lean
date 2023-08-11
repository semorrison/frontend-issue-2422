import Lake
open Lake DSL

package «frontend» {
  -- add package configuration options here
}

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git"

@[default_target]
lean_lib «Frontend» {
  -- add library configuration options here
}

@[default_target]
lean_exe «frontend» {
  root := `Main
}
