/// Emscripten API.

module dscripten.emscripten;

pragma(LDC_no_moduleinfo);

extern(C) void emscripten_worker_respond_provisionally(const char *, size_t);
extern(C) void emscripten_worker_respond(const char *, size_t);

void workerRespondProvisionally(const(void)[] buf)
{
	emscripten_worker_respond_provisionally(cast(const(char)*)buf.ptr, buf.length);
}

void workerRespond(const(void)[] buf)
{
	emscripten_worker_respond(cast(const(char)*)buf.ptr, buf.length);
}
