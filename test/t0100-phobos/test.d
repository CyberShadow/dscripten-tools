// Some limited Phobos tests

import std.array;
import std.math;

import core.stdc.stdio;

import dscripten.standard; // TODO: should be unnecessary
import dscripten.memory;

extern(C) void gc_init();

extern(C)
int main()
{
	printf("%f\n", sqrt(2.0));
	gc_init();
	Appender!string app;
	app.put("Hi there!");
	printf("%.*s\n", app.data.length, app.data.ptr);
	return 0;
}
