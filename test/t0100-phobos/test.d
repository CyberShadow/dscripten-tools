// Some limited Phobos tests

import std.array;
import std.math;

import core.stdc.stdio;

import dscripten.standard; // TODO: should be unnecessary

extern(C)
int main()
{
	printf("%f\n", sqrt(2.0));
	Appender!string app;
	//app.put("Hi there!");
	return 0;
}
