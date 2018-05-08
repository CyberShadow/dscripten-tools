// Some limited Phobos tests

import std.array;
import std.format;
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
	formattedWrite(app, "%d + %d = %d", 2, 2, 4);
	printf("%.*s\n", app.data.length, app.data.ptr);
	return 0;
}
