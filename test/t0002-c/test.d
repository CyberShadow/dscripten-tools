import core.stdc.stdio;

import dscripten.standard; // TODO: should be unnecessary

extern(C) int test_add(int, int);

extern(C)
int main()
{
	int ret = test_add(17, 25);
	printf("The result is %d!\n", ret);
	return 0;
}
