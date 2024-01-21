#include <emscripten/emscripten.h>

extern void _main();
extern void step();

int main() {
    _main();

    emscripten_set_main_loop(step, 0, 1);
    return 0;
}