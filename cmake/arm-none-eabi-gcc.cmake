##
## Generic CMake Toolchain for baremetal arm-gcc compiler
## 

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR arm-eabi)
set(TOOLCHAIN_PREFIX arm-none-eabi)

# get the binary search command for the host platform and set toolchain extensions
if(MINGW OR CYGWIN OR WIN32)
  set(UTIL_SEARCH_CMD where)
  set(TOOLCHAIN_EXT ".exe" )
elseif(UNIX OR APPLE)
  set(UTIL_SEARCH_CMD which)
  set(TOOLCHAIN_EXT "" )
endif()

# search for arm toolchain binary and get its absolute path
execute_process(
  COMMAND ${UTIL_SEARCH_CMD} ${TOOLCHAIN_PREFIX}-gcc
  OUTPUT_VARIABLE BINUTILS_PATH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

# add handler for unfound resources
if (${BINUTILS_PATH} STREQUAL "")
  message(FATAL "Could not locate ${TOOLCHAIN_PREFIX} compiler and utilities.")
endif()

# get the filename components path
get_filename_component(TOOLCHAIN_DIR ${BINUTILS_PATH} DIRECTORY)
message(STATUS "Discovered ARM CGT path: " ${TOOLCHAIN_DIR})

# This avoids running the linker and is intended for use with cross-compiling toolchains
# that cannot link without custom flags or linker scripts.
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Object build options
# -O0                   No optimizations, reduce compilation time and make debugging produce the expected results.
# -mthumb               Generate thumb instructions.
# -fno-builtin          Do not use built-in functions provided by GCC.
# -Wall                 Print only standard warnings, for all use Wextra
# -ffunction-sections   Place each function item into its own section in the output file.
# -fdata-sections       Place each data item into its own section in the output file.
# -fomit-frame-pointer  Omit the frame pointer in functions that don’t need one.
# -mabi=aapcs           Defines enums to be a variable sized type.
set(OBJECT_GEN_FLAGS "-O0 -mthumb -Wno-unused-parameter -Wpedantic -fno-builtin -Wall -Wextra -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs")

set(CMAKE_C_FLAGS   "${OBJECT_GEN_FLAGS} -std=gnu11 " CACHE INTERNAL "C Compiler options")
set(CMAKE_CXX_FLAGS "${OBJECT_GEN_FLAGS} -std=c++11 " CACHE INTERNAL "C++ Compiler options")
set(CMAKE_ASM_FLAGS "${OBJECT_GEN_FLAGS} -x assembler-with-cpp " CACHE INTERNAL "ASM Compiler options")

# -Wl,--gc-sections     Perform the dead code elimination.
# --specs=nano.specs    Link with newlib-nano.
# --specs=nosys.specs   No syscalls, provide empty implementations for the POSIX system calls.
set(CMAKE_EXE_LINKER_FLAGS "-Wl,--print-memory-usage -Wl,--gc-sections --specs=nano.specs -mthumb -mabi=aapcs -Wl,-Map=${CMAKE_PROJECT_NAME}.map,--cref" CACHE INTERNAL "Linker options")

# Options for DEBUG build
# -Og   Enables optimizations that do not interfere with debugging.
# -g    Produce debugging information in the operating system’s native format.
set(CMAKE_C_FLAGS_DEBUG "-Og -g" CACHE INTERNAL "C Compiler options for debug build type")
set(CMAKE_CXX_FLAGS_DEBUG "-Og -g" CACHE INTERNAL "C++ Compiler options for debug build type")
set(CMAKE_ASM_FLAGS_DEBUG "-g" CACHE INTERNAL "ASM Compiler options for debug build type")
set(CMAKE_EXE_LINKER_FLAGS_DEBUG "" CACHE INTERNAL "Linker options for debug build type")

# Options for RELEASE build
# -Os   Optimize for size. -Os enables all -O2 optimizations.
# -flto Runs the standard link-time optimizer.
set(CMAKE_C_FLAGS_RELEASE "-Os -flto" CACHE INTERNAL "C Compiler options for release build type")
set(CMAKE_CXX_FLAGS_RELEASE "-Os -flto" CACHE INTERNAL "C++ Compiler options for release build type")
set(CMAKE_ASM_FLAGS_RELEASE "" CACHE INTERNAL "ASM Compiler options for release build type")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "-flto" CACHE INTERNAL "Linker options for release build type")

# set cmake compilers
message(STATUS "Setting compilers.")
set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}-gcc${TOOLCHAIN_EXT} CACHE INTERNAL "C Compiler")
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}-g++${TOOLCHAIN_EXT} CACHE INTERNAL "C++ Compiler")
set(CMAKE_ASM_COMPILER ${TOOLCHAIN_PREFIX}-gcc${TOOLCHAIN_EXT} CACHE INTERNAL "ASM Compiler")

# configure find_program search directives
set(CMAKE_FIND_ROOT_PATH ${BINUTILS_PATH})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)