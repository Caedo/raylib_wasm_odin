Experiment with using Raylib + Odin on web.

# How does that work

This method abuses emscripten compiler and its toolchain by using small C program, that calls Odin code:
```c
#include <emscripten/emscripten.h>

extern void _main();
extern void step();

int main() {
    _main();

    emscripten_set_main_loop(step, 0, 1);
    return 0;
}
```

This way we can use Odin compiler to create object files that will be used by emcc. Check `build.bat` for calls and flags.

## The Issues

The default bindings from Vendor libarary won't work, since they use `core:c` package, which doesn't compile when targeting wasm. Thankfully the only thing neede from that package were types, like `c.int`, which can be easily copied and pasted to binding file, removing need for that import. (with the exception of `va_list`, but that's just one function which maybe will not be needed) 

The second issue with bindings is that the Odin's Foreign System doesn't really mesh well with what I want to do here. From what I understand, when giving a name to a foreing lib, wasm expects it to be in a module of the same name. Since that's not what I do here, I had to remove lib name from foreign block.

That also means that the same bindings can't be used for development on other platforms, probably.

Another issue is using `freestanding_wasm32` target. It's not an issue per se, but it means that I can't use some part of the standard library, mainly `core:fmt`. Usin `js_wasm` would be possible if there was a way to insert "odin_env" from odin's runtime.js into generated index.js file, but as for now I don't know if there is a way to do that (help appreciated!). 

## Other approach

The ideal way would be to completely ditch Emscriptem and use only Odin compiler, but with how much Raylib depends on Emscripten I would have to reimplement OpenGL, GLFW and other dependencies the same way Emscripten does. While it might not be feasible to do with Raylib, other libraries with lower amount of dependencies could be used this way.

The one issue with that is the Foreign System, for some reason, doesn't pass libraries paths to the linker when compiling to wasm. The easiest workaround I found (without modyfing the compiler) is to once again compile to object file and call wasm-ld manually.
