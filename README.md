A slightly messy example of using luarocks libraries with
[rlua](https://crates.io/crates/rlua).

This Rust program uses the rlua crate to implement a simple `lua` interpreter.
The `luarocks_test.sh` script demonstrates using
[LuaRocks](https://luarocks.org/) to install the Lua `http` (which includes a C
library rather than pure Lua) and fetch a resource.

The script:

1. Builds the Rust executable which implements a basic Lua interpreter using rlua
2. Configures and installs LuaRocks into `./lr/`, using the executable as the
   Lua5.4 interpreter.
3. Uses the installed `luarocks` to install the `http` library
4. Runs a simple Lua script using `http` library to fetch from a URL.

The key features to make use of libraries from LuaRocks (for example) from a
target using rlua are:

- The Lua library symbols must be exported and available to the C library
  - In this example, this is done using build.rs to add the `-Wl,-export-dynamic`
    linker flag.
  - If using rlua with one of the `system-lua*` features, this would not be necessary
    (the system Lua library already exports the symbols)

- The rlua Lua instance must created using the `unsafe` `Lua::unsafe_new_with_flags()` 
  to enable loading compiled libraries (by default they are disabled as they can easily
  be used to break Rust's safety measures)

- The Lua load paths
  [package.path](https://www.lua.org/manual/5.4/manual.html#pdf-package.path)
  (for Lua libraries) and
  [package.cpath](https://www.lua.org/manual/5.4/manual.html#pdf-package.cpath) must
  point to the relevant library install locations.  In this example the paths are set
  inside `test_http.lua` and point to the LuaRocks installation.

For installing libraries there are a couple of options:

- Use a separate LuaRocks installation (for example one from your Linux
  distribution packages with a matching Lua version (e.g. 5.4) to install the
  libraries, and then point to those (possibly shipped separately) from your
  rlua application.

- Provide an executable/script which behaves enough like a vanilla Lua interpreter
  (support `prog -e lua_code()` and `prog script.lua arg1 arg2...`) to use it directly
  with LuaRocks.  This example does this (and has a couple of hacks including making
  a couple of symlinks to satisfy LuaRocks - there may be a better way for someone who
  knows it better (PRs/issues with information welcome)

Note that generally installing binary Lua rocks may need a C compiler, although
it is possible to distribute binary rocks.
