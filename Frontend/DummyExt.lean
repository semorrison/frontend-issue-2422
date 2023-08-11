import Lean.Environment

open Lean

initialize dummyExt :
    PersistentEnvExtension Unit Unit Unit ←
  registerPersistentEnvExtension {
    mkInitial := pure ()
    addImportedFn := fun _ => pure ()
    addEntryFn := fun _ _ => ()
    exportEntriesFn := fun _ => #[]
  }