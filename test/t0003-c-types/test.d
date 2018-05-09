import core.stdc.config;
import core.stdc.stddef;
import core.stdc.stdio;

import dscripten.standard; // TODO: should be unnecessary

extern(C) int sizeOfInt();
extern(C) int sizeOfLong();
extern(C) int sizeOfSizet();
extern(C) int sizeOfWchar();

extern(C)
int main()
{
	printf("%s\n", sizeOfInt() == int.sizeof ? "ok".ptr : "mismatch".ptr);
	printf("%s\n", sizeOfLong() == c_long.sizeof ? "ok".ptr : "mismatch".ptr);
	printf("%s\n", sizeOfSizet() == size_t.sizeof ? "ok".ptr : "mismatch".ptr);
	printf("%s\n", sizeOfWchar() == wchar_t.sizeof ? "ok".ptr : "mismatch".ptr);
	return 0;
}
