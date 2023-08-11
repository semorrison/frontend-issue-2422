import Lean.Environment

open Lean

unsafe def findOrRegisterPersistentEnvExtensionUnsafe {α β σ : Type} [Inhabited σ] (descr : PersistentEnvExtensionDescr α β σ) : IO (PersistentEnvExtension α β σ) := do
  let pExts ← persistentEnvExtensionsRef.get
  match pExts.find? (fun ext => ext.name == descr.name) with
  | some ext => return unsafeCast ext
  | none =>
  let ext ← registerEnvExtension do
    let initial ← descr.mkInitial
    let s : PersistentEnvExtensionState α σ := {
      importedEntries := #[],
      state           := initial
    }
    pure s
  let pExt : PersistentEnvExtension α β σ := {
    toEnvExtension  := ext,
    name            := descr.name,
    addImportedFn   := descr.addImportedFn,
    addEntryFn      := descr.addEntryFn,
    exportEntriesFn := descr.exportEntriesFn,
    statsFn         := descr.statsFn
  }
  persistentEnvExtensionsRef.modify fun pExts => pExts.push (unsafeCast pExt)
  return pExt

@[implemented_by findOrRegisterPersistentEnvExtensionUnsafe]
opaque findOrRegisterPersistentEnvExtension {α β σ : Type} [Inhabited σ] (descr : PersistentEnvExtensionDescr α β σ) : IO (PersistentEnvExtension α β σ)

initialize dummyExt_findOrRegister :
    PersistentEnvExtension Unit Unit Unit ←
  findOrRegisterPersistentEnvExtension {
    mkInitial := pure ()
    addImportedFn := fun _ => pure ()
    addEntryFn := fun _ _ => ()
    exportEntriesFn := fun _ => #[]
  }