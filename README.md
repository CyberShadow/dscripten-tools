Dscripten Build Tools [![Build Status](https://travis-ci.org/CyberShadow/dscripten-tools.svg?branch=master)](https://travis-ci.org/CyberShadow/dscripten-tools)
=====================

These allow using [dscripten](https://github.com/Ace17/dscripten) to
compile D code to JavaScript (asm.js) with typical D workflow (dmd and
rdmd).

Setup
-----

1. Run dscripten's `fetch_toolchain` script to download, patch and build LDC and Emscripten.
2. Build the tools in this directory (e.g. `dmd dmd-dscripten.d && dmd rdmd-dscripten.d`).
3. (Optional) Set up your environment (see the [Configuration](#configuration) section below).

Usage
-----

There are two ways to use this toolchain:

1. Invoke the tools directly (e.g. `path/to/rdmd-dscripten --compiler=path/to/dmd-dscripten --build-only worker.d`)
2. Prepend the `bin` directory to your `PATH`, so that it overrides the standard `dmd` and `rdmd` binaries.

Because these tools attempt to implement the same command-line interface as dmd/rdmd, the second method can be used with any programs (e.g. build tools, error highlighting in editors) without needing to configure them. For example, Dub can be used to build programs in its `--rdmd` mode.

In addition to the usual switches and `.d` files, `dmd-dscripten` also understands how to handle `.c`, `.llvm` and `.bc` files on its command line, and will appropriately compile or otherwise include them into the compilation. See the test suite for examples.

Configuration
-------------

The tools read a few environment variables:

- `DSCRIPTEN_RDMD` - path to real `rdmd` binary (default: `/usr/bin/rdmd`)
- `DSCRIPTEN_TOOLCHAINS` - path to toolchains build by `fetch_toolchain` (default: `/tmp/toolchains`)
- `LLVMJS` - path to Dscripten's LDC (default: `$DSCRIPTEN_TOOLCHAINS/llvm-js`)
- `EMSCRIPTEN` - path to Dscripten's Emscripten (default: `$DSCRIPTEN_TOOLCHAINS/emscripten`)
- `DSCRIPTEN_TOOLS` - path to the root of this repository (default: `thisExePath.dirName` - the directory the tool's executable is in)

Example
-------

### `worker.html`

```html
<!doctype html>
<html>
	<title>Dscripten WebWorker test</title>
	<meta charset="UTF-8">

	<script>
	 var w = new Worker('worker.js');
	 w.onmessage = function(event){
		 var text = (new TextDecoder("utf-8")).decode(event.data.data);
		 document.getElementById("result").innerHTML += text + '<br>';
	 };

	 w.postMessage({'funcName':'myFunc', 'data':'', 'callbackId':123});
	</script>

	<body>
		<div id="result"></div>
	</body>
</html>
```

### `worker.d`

```d
module worker;

import core.stdc.stdio;
import core.stdc.string;

import dscripten.emscripten;

import ldc.attributes;

@assumeUsed
extern(C)
void myFunc(char* data, int size)
{
    foreach (i; 0..10)
	{
		char[32] buf;
		sprintf(buf.ptr, "Working... %d", i);
        workerRespondProvisionally(buf.ptr[0..strlen(buf.ptr)]);
    }
    workerRespond("Done!");
}
```

Compile with:

```shell
$ rdmd-dscripten --compiler=dmd-dscripten --build-only worker.d
```

This will create `worker.js`.
