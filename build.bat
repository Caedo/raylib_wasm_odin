@echo off

set STACK_SIZE=1048576
set HEAP_SIZE=67108864

call emsdk activate latest

if not exist build mkdir build
pushd build


call odin build ../src -target=freestanding_wasm32 -out:odin -build-mode:obj -debug -show-system-calls
call emcc -o index.html ../src/main.c odin.wasm.o ../lib/libraylib.a -s USE_GLFW=3 -s GL_ENABLE_GET_PROC_ADDRESS -DWEB_BUILD -sSTACK_SIZE=%STACK_SIZE% -s TOTAL_MEMORY=%HEAP_SIZE% -sERROR_ON_UNDEFINED_SYMBOLS=0

popd