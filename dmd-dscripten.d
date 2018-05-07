/**
   Simple DMD driver to build programs targeting the dscripten
   toolchain.

   https://github.com/Ace17/dscripten

   Currently geared towards "headless" scripts running from a web
   worker (output extension is .js only).
**/
   
module dmd_dscripten;

import std.algorithm.iteration;
import std.algorithm.searching;
import std.array;
import std.exception;
import std.file;
import std.format;
import std.path;
import std.process;
import std.stdio;

//debug debug = verbose;

void main(string[] args)
{
	debug(verbose) stderr.writeln("dmd-dscripten: Args: ", args[1..$]);

	auto toolchainsPath = environment.get("DSCRIPTEN_TOOLCHAINS", "/tmp/toolchains");
	auto llvmJSPath = environment.get("LLVMJS", toolchainsPath.buildPath("llvm-js"));
	auto emscriptenPath = environment.get("EMSCRIPTEN", toolchainsPath.buildPath("emscripten"));

	auto compiler = llvmJSPath.buildPath("bin", "ldmd2");
	auto compilerOpts = args[1..$];

	// Add runtime to import paths
	compilerOpts = ["-I" ~ thisExePath.dirName.buildPath("rt")] ~ compilerOpts;

	string objDir, outputFile;
	compilerOpts.filter!(opt => opt.startsWith("-of")).each!(opt => outputFile = opt[3..$]);
	bool build = !compilerOpts.canFind("-o-") && outputFile;
	if (build)
	{
		compilerOpts = ["-output-bc", "-op"] ~ compilerOpts.filter!(opt => !opt.startsWith("-of")).array;
		compilerOpts.filter!(opt => opt.startsWith("-od")).each!(opt => objDir = opt[3..$]);
		enforce(objDir, "Building with no objDir?");
	}
	enum target = "asmjs-unknown-emscripten";
	compilerOpts = ["-mtriple=" ~ target] ~ compilerOpts;

	run([compiler] ~ compilerOpts);

	if (build)
	{
		auto objFiles = dirEntries(objDir, "*.bc", SpanMode.depth).map!(de => de.name).array;
		auto linkedObjFile = objDir.buildPath("_all.bc");

		auto llvmLinker = llvmJSPath.buildPath("bin", "llvm-link");
		
		run([llvmLinker] ~ objFiles ~ ["-o=" ~ linkedObjFile]);

		// Maybe call 'opt' to optimize (LTO) here?

		auto emccArgs = [
			emscriptenPath.buildPath("emcc"),
		];

		// TODO: make this customizable somehow
		if (true)
			emccArgs ~= [
				"--pre-js", thisExePath.dirName.buildPath("worker.pre.js"),
				"-s", "BUILD_AS_WORKER=1",
				"-s", `EXPORTED_FUNCTIONS=['_one']`, // TODO!
			];

		if (compilerOpts.canFind("-O"))
			emccArgs ~= "-O3";

		emccArgs ~= [
			"--memory-init-file", "0",
			"--target=" ~ target,
			"-S",
			"-w", linkedObjFile,
			"-o", outputFile ~ ".js",
		];

		run(emccArgs);
		if (exists(outputFile ~ ".js"))
			rename(outputFile ~ ".js", outputFile);
	}
}

void run(string[] args)
{
	debug(verbose) stderr.writeln("dmd-dscripten: Exec: ", args);
	auto result = spawnProcess(args).wait();
	enforce(result == 0, "%s exited with status %d".format(args[0].baseName, result));
}
