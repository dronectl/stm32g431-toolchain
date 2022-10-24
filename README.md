# STM32G4 Toolchain

Modified: 2022-10

A toolchain for baremetal development of STM32G4 microcontrollers.

## Navigation
1. [Software Requirements](#software-requirements)
2. [Quickstart](#quickstart)
3. [License](#license)

## Software Requirements
This toolchain leverages the following software tools:
 - [CMake](https://cmake.org) (Build system)
 - [ARM GCC](https://developer.arm.com/Tools%20and%20Software/GNU%20Toolchain) (Code generation toolchain)
 - [STM32CubeG4](https://www.st.com/en/embedded-software/stm32cubeg4.html) (STM microcontroller header files)
 - [OpenOCD](https://openocd.org) (Open source on-chip debugger)

For installation instructions see the [developers guide](./dev/README.md)

## Quickstart
Clone this repository and navigate to the repository root:
```bash
git clone git@github.com:dronectl/stm32g431-toolchain.git
cd stm32g431-toolchain
```
Initialize the build system using `cmake`:
```bash
mkdir build
cd build
# pass the basepath of the STM32CUBEG4 install directory
cmake .. -DSTM32CUBEG4_BASE=/path/to/STM32CubeG4
...
```
Compile the firmware
```bash
make -j
...
```
Plugin the evaluation board to your PC over mini USB and flash the microcontroller over UART:
```bash
make flash
```
> OpenOCD automatically detects STLINK debugger interfaces over USB. 

![img](/docs/demo.gif)

## License
This project is licensed under the terms of the [MIT License](LICENSE)