import Lake
open Lake DSL

package «frontend» {
  -- add package configuration options here
}

@[default_target]
lean_lib «Frontend» {
  -- add library configuration options here
}

@[default_target]
lean_exe «frontend» {
  root := `Main
}
