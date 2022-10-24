# based on ubuntu-latest standard
cmake_minimum_required(VERSION 3.22)
# autoload toolchain
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/cmake/arm-none-eabi-gcc.cmake)

# global project name
set(EXECUTABLE "demo")
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# cmake build guard
if(PROJECT_SOURCE_DIR STREQUAL PROJECT_BINARY_DIR)
  message(FATAL_ERROR "In-source builds not allowed. Please make a new directory (called a build directory) and run CMake from there.")
endif()

# cmake build guard
if(NOT DEFINED STM32CUBEG4_BASE)
  message(FATAL_ERROR "Must provide STM32CUBEG4 (absolute) base path: -DSTM32CUBEG4_BASE=/path/to/stm32cubeg4")
endif()

project(
    ${EXECUTABLE}
    LANGUAGES C ASM
    VERSION 1.0
    DESCRIPTION "STM32G4 CMake Toolchain Demo."
)

set(MCU STM32G431xx)

message(STATUS "Linking linker script.")
get_filename_component(LINKER_SCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/tools/STM32G431RBTX_FLASH.ld ABSOLUTE)

message(STATUS "Linking OpenOCD configuration.")
get_filename_component(OPENOCD_CONFIG ${CMAKE_CURRENT_SOURCE_DIR}/tools/stlink.cfg ABSOLUTE)

set(
  STM32CUBEG4_INCLUDE
  ${STM32CUBEG4_BASE}/Drivers/CMSIS/Device/ST/STM32G4xx/Include
  ${STM32CUBEG4_BASE}/Drivers/CMSIS/Core/Include
)

# set compile flags for STM32G431XX
list(APPEND STM32G431XX_C_FLAGS -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard)
list(APPEND STM32G431XX_COMPILE_DEFINITIONS -D${MCU})
list(APPEND STM32G431XX_LINKER_FLAGS -T${LINKER_SCRIPT} -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard)

# find code generation tooling
message(STATUS "Discovering cgt executables.")
find_program(ARM_OBJCPY NAMES ${TOOLCHAIN_PREFIX}-objcopy${TOOLCHAIN_EXT} PATHS ${TOOLCHAIN_DIR} NO_DEFAULT_PATH)
find_program(ARM_OBJDUMP NAMES ${TOOLCHAIN_PREFIX}-objdump${TOOLCHAIN_EXT} PATHS ${TOOLCHAIN_DIR} NO_DEFAULT_PATH)
find_program(ARM_SIZE NAMES ${TOOLCHAIN_PREFIX}-size${TOOLCHAIN_EXT} PATHS ${TOOLCHAIN_DIR} NO_DEFAULT_PATH)
find_program(OPENOCD NAMES openocd${TOOLCHAIN_EXT} PATHS ${TOOLCHAIN_DIR} NO_DEFAULT_PATH)

add_executable(
  ${EXECUTABLE}
  src/main.c
  src/system_stm32g4xx.c
  src/startup_stm32g431xx.s
)
set_target_properties(${EXECUTABLE} PROPERTIES OUTPUT_NAME ${EXECUTABLE}.elf)
target_include_directories(${EXECUTABLE} PUBLIC ${STM32CUBEG4_INCLUDE})
target_compile_definitions(${EXECUTABLE} PRIVATE ${STM32G431XX_COMPILE_DEFINITIONS})
target_compile_options(${EXECUTABLE} PRIVATE ${STM32G431XX_C_FLAGS})
target_link_options(${EXECUTABLE} PRIVATE ${STM32G431XX_LINKER_FLAGS})

message(STATUS "Adding custom targets")
add_custom_target(${EXECUTABLE}-size DEPENDS ${EXECUTABLE} COMMAND ${ARM_SIZE} -B -d --target=binary ${EXECUTABLE}.elf)
add_custom_target(hex ALL ${ARM_OBJCPY} -O ihex ${EXECUTABLE}.elf ${EXECUTABLE}.hex DEPENDS ${EXECUTABLE})
add_custom_target(bin ALL ${ARM_OBJCPY} -O binary -S ${EXECUTABLE}.elf ${EXECUTABLE}.bin DEPENDS ${EXECUTABLE})
add_custom_target(objdump ${ARM_OBJDUMP} -S ${EXECUTABLE}.elf DEPENDS ${EXECUTABLE})
add_custom_target(flash DEPENDS ${EXECUTABLE}-size COMMAND ${OPENOCD} -finterface/stlink.cfg -ftarget/stm32g4x.cfg -c "program demo.elf verify reset exit")