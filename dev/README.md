# Developers Guide

Modified: 2022-11

## Navigation
1. [Toolchain Installation](#toolchain-installation)
2. [STM32 Headers](#stm32-headers)

## ARM Toolchain Installation
This demo version 10.3 which at the time of writing is the latest arm toolchain. Note that these downloads are large and may take some time.
### MacOSX
Get the CMSIS `arm-none-eabi-gcc` toolchain for ARM Cortex microcontrollers:
```bash
brew install --cask gcc-arm-embedded
```
### Windows
Download version 10.3 from the windows install link [here](https://developer.arm.com/downloads/-/gnu-rm)

## OpenOCD Installation
This demo version 0.11.0 which at the time of writing is the latest `openocd` version
### MacOSX
Get `openocd` using `brew`:
```bash
brew install openocd
```
### Windows
Download xPack OpenOCD v0.11.0-5 (xpack-openocd-0.11.0-5-win32-x64.zip) from the github release link [here](https://github.com/xpack-dev-tools/openocd-xpack/releases)

## CMake Installation
This demo requires a minimum `cmake` version 3.24 to build.
### MacOSX
Install `cmake` using `brew`:
```bash
brew install cmake
```
### Windows
Download version `3.34` or higher from the windows install link [here](https://cmake.org/download/)

## STM32 Headers
Get the STM32G4 (and CMSIS) headers from github. You will want to clone this at a location it can be easily referenced across multiple projects:
```bash
git clone git@github.com:STMicroelectronics/STM32CubeG4.git
```
> Note: This repository contains a ton of extra overhead meant for CubeIDE and other toolchains. This has no effect on the binary size since only what we include (and subsequent includes) will be used.

## VSCode Integration
TODO