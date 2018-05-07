/**
   Simple DMD driver to build programs targeting the dscripten
   toolchain.

   https://github.com/Ace17/dscripten

   Currently geared towards "headless" scripts running from a web
   worker (output extension is .js only).
**/
   
module dmd_dscripten;

import core.sys.posix.unistd : isatty;

import std.algorithm.iteration;
import std.algorithm.searching;
import std.array;
import std.exception;
import std.file;
import std.format;
import std.path;
import std.process;
import std.stdio : stdout, stderr;

bool verbose;

void main(string[] args)
{
	verbose = args[1..$].canFind("-v") && isatty(stdout.fileno);
	if (verbose) stderr.writeln("dmd-dscripten: Args: ", args[1..$]);

	auto toolchainsPath = environment.get("DSCRIPTEN_TOOLCHAINS", "/tmp/toolchains");
	auto llvmJSPath = environment.get("LLVMJS", toolchainsPath.buildPath("llvm-js"));
	auto emscriptenPath = environment.get("EMSCRIPTEN", toolchainsPath.buildPath("emscripten"));
	auto toolsPath = environment.get("DSCRIPTEN_TOOLS", thisExePath.dirName);

	auto compiler = llvmJSPath.buildPath("bin", "ldmd2");
	auto compilerOpts = args[1..$];

	enum objsLink = ".dscripten-objs"; scope(exit) cleanLink(objsLink);
	enum rootLink = ".dscripten-root"; scope(exit) cleanLink(rootLink);

	// Add runtime to import paths
	string objDir, outputFile;
	compilerOpts.filter!(opt => opt.startsWith("-of")).each!(opt => outputFile = opt[3..$]);
	bool build = !compilerOpts.canFind("-o-") && outputFile;
	if (build)
	{
		compilerOpts.filter!(opt => opt.startsWith("-od")).each!(opt => objDir = opt[3..$]);
		enforce(objDir, "Building with no objDir?");

		// Ugly work-around for missing -oq
		cleanLink(objsLink); symlink(objDir, objsLink);
		cleanLink(rootLink); symlink("/"   , rootLink);

		foreach (ref arg; compilerOpts)
			if (!arg.startsWith("-") && arg.endsWith(".d") && exists(arg))
				arg = rootLink ~ absolutePath(arg);

		compilerOpts = ["-output-bc", "-od" ~ objsLink, "-op"] ~ compilerOpts.filter!(opt => !opt.startsWith("-of") && !opt.startsWith("-od")).array;
	}
	enum target = "asmjs-unknown-emscripten";
	compilerOpts = [
		"-mtriple=" ~ target,
		"-version=dscripten",
		"-conf=" ~ toolsPath.buildPath("ldc2.conf"),
		"-I" ~ toolsPath.buildPath("rt"),
		"-I" ~ llvmJSPath.buildPath("include", "d"),
		"-betterC",
	] ~ compilerOpts;

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
				"--pre-js", toolsPath.buildPath("worker.pre.js"),
				"-s", "BUILD_AS_WORKER=1",
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

void cleanLink(string link)
{
	try
		remove(link);
	catch (Exception) {}
}

void run(string[] args)
{
	if (verbose) stderr.writeln("dmd-dscripten: Exec: ", args);
	auto result = spawnProcess(args).wait();
	enforce(result == 0, "%s exited with status %d".format(args[0].baseName, result));
}
