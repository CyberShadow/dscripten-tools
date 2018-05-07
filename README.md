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
