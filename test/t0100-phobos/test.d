// Some limited Phobos tests

import std.math;

import core.stdc.stdio;

import dscripten.standard; // TODO: should be unnecessary

extern(C)
int main()
{
	printf("%f\n", sqrt(2.0));
	return 0;
}
