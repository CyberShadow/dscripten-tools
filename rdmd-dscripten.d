/**
   Simple rdmd wrapper to build programs targeting the dscripten
   toolchain.

   https://github.com/Ace17/dscripten

   Currently geared towards "headless" scripts running from a web
   worker (output extension is .js only).
**/
   
module rdmd_dscripten;

import std.algorithm.searching;
import std.path;
import std.process;
import std.range.primitives;
import std.stdio;

//debug debug = verbose;

void main(string[] args)
{
	debug(verbose) stderr.writeln("rdmd-dscripten: Args: ", args[1..$]);

	auto realRDMD = environment.get("DSCRIPTEN_RDMD", "/usr/bin/rdmd");

	auto rdmdOpts = args[1..$];

	// Force .js file extension.
	// rdmd can't figure it out otherwise.
	auto nonOptions = args[1..$].find!(arg => !arg.startsWith("-"));
	if (!nonOptions.empty)
	{
		auto mainFile = nonOptions.front;
		auto jsFile = mainFile.setExtension(".js");
		rdmdOpts = ["-of" ~ jsFile] ~ rdmdOpts;
	}

	auto cmdLine = [realRDMD] ~ rdmdOpts;
	debug(verbose) stderr.writeln("rdmd-dscripten: Exec: ", cmdLine);
	execv(cmdLine[0], cmdLine);
}
