#!/usr/bin/env bash

rm -rf build
lake build

# Check that we can compile a file which shares with the executable
# a common import using an initializer.
# Here the executable for `frontend` imports `Frontend.Import2`.

# This is a minimisation of a situation in which we want to compile a file
# from a project (e.g. Mathlib), so that we can inject another tactic
# implemented in the same project into a goal state from the file.

# We observe that this works fine, but fails in the interpreter.
lake exe frontend Frontend.Import1
