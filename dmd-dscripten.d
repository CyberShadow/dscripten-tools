/**
   Simple DMD driver to build programs targeting the dscripten
   toolchain.

   https://github.com/Ace17/dscripten

   Currently geared towards "headless" scripts running from a web
   worker (output extension is .js only).
**/
   
module dmd_dscripten;

import core.sys.posix.unistd : isatty;

import std.algorithm.comparison;
import std.algorithm.iteration;
import std.algorithm.mutation;
import std.algorithm.searching;
import std.array;
import std.digest.digest;
import std.digest.md;
import std.exception;
import std.file;
import std.format;
import std.path;
import std.process;
import std.stdio : stdout, stderr;

void main(string[] args)
{
	bool verbose = args[1..$].canFind("-v") && isatty(stdout.fileno);
	if (verbose) stderr.writeln("dmd-dscripten: Args: ", args[1..$]);

	auto toolchainsPath = environment.get("DSCRIPTEN_TOOLCHAINS", "/tmp/toolchains");
	auto llvmJSPath = environment.get("LLVMJS", toolchainsPath.buildPath("llvm-js"));
	auto emscriptenPath = environment.get("EMSCRIPTEN", toolchainsPath.buildPath("emscripten"));
	auto toolsPath = environment.get("DSCRIPTEN_TOOLS", thisExePath.dirName);

	auto compiler = llvmJSPath.buildPath("bin", "ldmd2");
	auto compilerOpts = args[1..$];

	void run(string[] args)
	{
		if (verbose) stderr.writeln("dmd-dscripten: Exec: ", args);
		auto result = spawnProcess(args, ["LD_LIBRARY_PATH" : llvmJSPath.buildPath("lib")]).wait();
		enforce(result == 0, "%s exited with status %d".format(args[0].baseName, result));
	}

	compilerOpts = compilerOpts.map!(
		opt => opt.skipOver("@") ? readResponseFile(opt) : [opt]).join;

	// Not only are the produced files not (directly) executable,
	// -run changes how the command-line is parsed,
	// so detect and forbid it explicitly to avoid any possible weird error messages.
	enforce(!compilerOpts.canFind("-run"), "Can't use -run with dscripten!");

	enum objsLink = ".dscripten-objs"; scope(exit) cleanLink(objsLink);
	enum rootLink = ".dscripten-root"; scope(exit) cleanLink(rootLink);

	// Include ourselves in the verbose output for rdmd to pick up,
	// so that changes in the tools causes a rebuild.
	if (compilerOpts.canFind("-v"))
	{
		stdout.writeln("binary    ", toolsPath.buildPath("dmd-dscripten"));
		stdout.writeln("binary    ", toolsPath.buildPath("rdmd-dscripten"));
	}

	// Add runtime to import paths
	string objDir, outputFile;
	compilerOpts.extract!(opt => opt.startsWith("-of")).each!(opt => outputFile = opt[3..$]);
	bool build = compilerOpts.canFind!(arg => !arg.startsWith("-")) && !compilerOpts.canFind("-o-");

	if (build)
	{
		enforce(outputFile, "Building with no outputFile?");
		compilerOpts.extract!(opt => opt.startsWith("-od")).each!(opt => objDir = opt[3..$]);
		enforce(objDir, "Building with no objDir?");

		// Ensure the object directory is empty, as we will be globbing it later.
		if (objDir.exists && !objDir.dirEntries("*.bc", SpanMode.depth, false).empty)
		{
			if (objDir.startsWith("/tmp/.rdmd-"))
			{
				rmdirRecurse(objDir);
				mkdir(objDir);
			}
			else
				throw new Exception("Dirty object directory: " ~ objDir);
		}

		// rdmd will never add object.d, so add it ourselves
		compilerOpts ~= toolsPath.buildPath("rt", "object.d");

		// Ugly work-around for missing -oq
		cleanLink(objsLink); symlink(objDir, objsLink);
		cleanLink(rootLink); symlink("/"   , rootLink);

		foreach (ref arg; compilerOpts)
			if (!arg.startsWith("-") && arg.endsWith(".d") && exists(arg))
				arg = rootLink ~ absolutePath(arg);

		compilerOpts = ["-output-bc", "-od" ~ objsLink, "-op"] ~ compilerOpts;
	}

	// Recognize .c / .llvm / .bc files on the command line, and include them in the compilation accordingly.
	auto cFiles = compilerOpts.extract!(arg => !arg.startsWith("-") && arg.endsWith(".c"));
	auto llvmFiles = compilerOpts.extract!(arg => !arg.startsWith("-") && arg.endsWith(".llvm"));
	auto bcFiles = compilerOpts.extract!(arg => !arg.startsWith("-") && arg.endsWith(".bc"));

	// Extract additional emcc options
	string[] emccExtra = compilerOpts.extract!((ref arg) => arg.skipOver("--emcc="));
	foreach (opt; compilerOpts.extract!((ref arg) => arg.skipOver("--emcc-s=")))
		emccExtra ~= ["-s", opt];

	bool wasm;
	if (compilerOpts.extract!(arg => arg == "--wasm"))
		wasm = true;

	if (wasm)
		compilerOpts ~= [
			"-disable-loop-vectorization",
		];

	enum target = "asmjs-unknown-emscripten";
	compilerOpts = [
		"-mtriple=" ~ target,
		"-version=dscripten",
		"-conf=" ~ toolsPath.buildPath("ldc2.conf"),
		"-I" ~ toolsPath.buildPath("rt"),
		"-I" ~ llvmJSPath.buildPath("include", "d"),
	] ~ compilerOpts;

	run([compiler] ~ compilerOpts);

	if (compilerOpts.canFind!(opt => opt.among("-h", "--help")))
	{
		stderr.writeln();
		stderr.writeln("Additional dmd-dscripten options:");
		stderr.writeln("  --wasm            configure for WebAssembly output");
		stderr.writeln("  --emcc=SWITCH     pass SWITCH on to emcc's command line");
		stderr.writeln("  --emcc-s=OPTION   shorthand for --emcc=-s --emcc=OPTION");
		stderr.writeln();
		stderr.writeln("dmd-dscripten can also accept additional *.c, *.llvm and *.bc files");
		stderr.writeln("to include in the build.");
	}

	if (build)
	{
		auto objFiles = dirEntries(objDir, "*.bc", SpanMode.depth, false).map!(de => de.name).array;

		foreach (cFile; cFiles)
		{
			auto bcFile = objDir.buildPath("c-" ~ toHexString(md5Of(cFile)) ~ ".bc");
			run([
				emscriptenPath.buildPath("emcc"),
				"-c",
				cFile,
				"-o", bcFile,
				// TODO: optimize?
			]);
			bcFiles ~= bcFile;
		}

		foreach (llvmFile; llvmFiles)
		{
			auto bcFile = objDir.buildPath("llvm-" ~ toHexString(md5Of(llvmFile)) ~ ".bc");
			run([
				llvmJSPath.buildPath("bin", "llvm-as"),
				llvmFile,
				"-o=" ~ bcFile,
			]);
			bcFiles ~= bcFile;
		}

		objFiles ~= bcFiles;
		auto linkedObjFile = objDir.buildPath("_all.bc");

		auto llvmLinker = llvmJSPath.buildPath("bin", "llvm-link");
		
		run([llvmLinker] ~ objFiles ~ ["-o=" ~ linkedObjFile]);

		// Maybe call 'opt' to optimize (LTO) here?

		auto emccArgs = [
			emscriptenPath.buildPath("emcc"),
		];

		// TODO: make this customizable somehow
		// It doesn't hurt for any use case, though, just adds some
		// WebWorker-specific declarations to the .js output.
		if (true)
			emccArgs ~= [
				"-s", "BUILD_AS_WORKER=1",
			];

		bool optimize;

		if (compilerOpts.canFind("-O"))
			optimize = true;

		if (wasm)
		{
			// Works around error:
			// failed to asynchronously prepare wasm: LinkError:
			// WebAssembly Instantiation: Import #6 module="env"
			// function="core.cpuid.__ModuleInfo" error: global import
			// must be a number
			optimize = true;
		}

		if (optimize)
			emccArgs ~= "-O3";

		emccArgs ~= [
			"--memory-init-file", "0",
			"--target=" ~ target,
			"-S",
			"-w", linkedObjFile,
			"-o", outputFile ~ ".js",
		];

		if (wasm)
			emccArgs ~= ["-s", "WASM=1"];

		emccArgs ~= emccExtra;

		run(emccArgs);
		if (exists(outputFile ~ ".js"))
			rename(outputFile ~ ".js", outputFile);
	}
}

/// Remove and return all elements of `arr` matching `pred`.
string[] extract(alias pred)(ref string[] arr)
{
	string[] result;
	size_t i = 0;
	while (i < arr.length)
	{
		auto e = arr[i];
		if (pred(e))
		{
			result ~= e;
			arr = arr.remove(i);
		}
		else
			i++;
	}
	return result;
}

void cleanLink(string link)
{
	try
		remove(link);
	catch (Exception) {}
}

string[] readResponseFile(string fileName)
{
	auto s = fileName.readText;
	string[] result;
	string arg;
	bool inQuote, backslash;
	foreach (c; s)
	{
		if (backslash)
		{
			arg ~= c;
			backslash = false;
		}
		else
		if (c == '\\')
			backslash = true;
		else
		if (c == '"')
			inQuote = !inQuote;
		else
		if ((c == ' ' || c == '\r' || c == '\n') && !inQuote)
		{
			if (arg.length)
				result ~= arg;
			arg = null;
		}
		else
			arg ~= c;
	}
	if (arg.length)
		result ~= arg;
	return result;
}
