Dscripten Build Tools
=====================

These allow using [dscripten](https://github.com/Ace17/dscripten) to
compile D code to JavaScript (asm.js) with typical D workflow (dmd and
rdmd).

Usage
-----

1. Run dscripten's `fetch_toolchain` script to download, patch and build LDC and Emscripten.
2. Build the tools in this directory (e.g. `dmd dmd-dscripten.d && dmd rdmd-dscripten.d`).
3. Invoke these tools instead of `dmd` / `rdmd`, e.g. by adding links to them to a directory on your PATH.

Configuration
-------------

The tools read a few environment variables:

- `DSCRIPTEN_RDMD` - path to real `rdmd` binary (default: `/usr/bin/rdmd`)
- `DSCRIPTEN_TOOLCHAINS` - path to toolchains build by `fetch_toolchain` (default: `/tmp/toolchains`)
- `LLVMJS` - path to Dscripten's LDC (default: `$DSCRIPTEN_TOOLCHAINS/llvm-js`)
- `EMSCRIPTEN` - path to Dscripten's Emscripten (default: `$DSCRIPTEN_TOOLCHAINS/emscripten`)

Example
-------

