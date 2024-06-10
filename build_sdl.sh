#! /bin/bash   
set -e


# This is no longer used, we used to use this via @import("zig-wii-sdk").runDevkitProBash()

# Run:
# MSYSTEM=MSYS CHERE_INVOKING=1 /usr/bin/bash -li /d/ZigProjects/Zig-Wii-SW/deps/SDL/build_sdl.sh
#
# Source:
# - CHERE_INVOKING = https://superuser.com/a/1297072
#   - Invoke from current working directory
# - MSYSTEM = MSYS
#   - Matches configuration in /c/devkitPro/msys2/msys2.ini
# - /usr/bin/bash -li 
#   - Must run bash with login to setup various environment variables

# Instructions
# https://github.com/devkitPro/SDL/blob/ogc-sdl-2.28/docs/README-ogc.md
# https://github.com/devkitPro/SDL/blob/9a759681abf8883cdbaa9a0299c07d13f08556d1/docs/README-ogc.md

# note: -Wno-dev to remove warnings from "zig build" output
cmake -S. -Bbuild -DCMAKE_TOOLCHAIN_FILE="$DEVKITPRO/cmake/Wii.cmake" -DCMAKE_BUILD_TYPE=Release -Wno-dev >/dev/null
cmake --build build >/dev/null 
cmake --install build >/dev/null
