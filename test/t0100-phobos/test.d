// Some limited Phobos tests

import std.array;
import std.format;
import std.math;

import core.stdc.stdio;

import dscripten.standard; // TODO: should be unnecessary
import dscripten.memory;

void puts(in char[] s)
{
	printf("%.*s\n", s.length, s.ptr);
}

extern(C)
int main()
{
	printf("%f\n", sqrt(2.0));
	gc_init();
	Appender!string app;
	formattedWrite(app, "%d + %d = %d", 2, 2, 4);
	puts(app.data);
	puts(format("On the %s!", "heap"));
	return 0;
}
