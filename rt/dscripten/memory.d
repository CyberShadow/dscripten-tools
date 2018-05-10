module dscripten.memory;

// Pull these in:
import rt.lifetime;
import rt.config;
import gc.proxy;
import ldc.arrayinit;

// Call this in your extern(C) main
extern(C) void gc_init();
