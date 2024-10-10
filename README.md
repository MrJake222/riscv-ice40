# RISC-V implementation survey

TL;DR: See ***Synthesis toolchain*** and ***GCC Toolchain*** sections.





## RISC-V

### Synthesis toolchain
For Debian: `sudo apt install iverilog yosys nextpnr-ice40 fpga-icestorm`.
Now try to build & upload one of the cores:
```
cd picorv32
make
make prgcram
```

### Extras
Folder `extra` contains common Verilog code.
- `clk.v` -- hosts PLL, generates 1MHz clock for system,
- `dbgu32.v` -- debug module, see [debug uart](https://github.com/MrJake222/debug_uart),
- `pwm.v` -- PWM module,
- `ram32.v` -- SPRAM module, 32bit wide,
- `timer.v` -- timer module,
- `uart.v` -- UART module, used by `dbgu32.v`,
- `uartblk.v` -- standalone memory-mapped UART module.

### Make targets
All RISC-V cores use the same Makefile template. Build Targets:
- `all` -- synthesize, place & route, pack to bin, display utilisation,
- `sim` -- simulate all testbenches,
- `verify` -- run Icarus Verilog to verify syntax ([recommended](https://github.com/YosysHQ/yosys/discussions/4347) instead of yosys),
- `util` -- print resource consumption (done with `all`),
- `cells` -- print per module cell usage,
- `clean`
- `prgflash` -- use `dfu-util` to upload code to nonvolatile flash storage ([pico-ice](https://github.com/tinyvision-ai-inc/pico-ice) board),
- `prgcram` -- program configuration RAM (same as above, only volatile).

### FemtoRV
Currenly unused.

### PicoRV32
This survey uses [Yosys PicoRV32](https://github.com/YosysHQ/picorv32) implementation
contained within `picorv32-impl` folder. `picorv32` contains files specific to this project.
Variants are set up by changing options inside `crv32.v` at core instantiation.
Default options only enable performance counters.

### VexRiscV
Additional directory `vexriscv-build` is used for builing the core from Scala.
Other folders are the same as PicoRV32. Variants are provided as separate files.
Changing them requires Makefile modification.
- `VexRiscv_smprod_my.v` -- Small & productive with modifications
- `VexRiscv_sm_my.v` -- Small with modifications
- `VexRiscv_smprod_my_muldiv.v` -- Small & productive with modifications and simple muldiv unit.

Modifications include `cmdForkPersistence` set to true and performance counters.

### Testbenches
Tests can be found in core folders for ex. `picorv32/tb`.
`dep.v` is a common file for all tests.
Provided `gtkw/` folder won't work for you, because of hardcoded paths to data files.
Adjust `[dumpfile]` and `[savefile]` directives.
`src` contains testbenches:
- `*_bus_instr.v` -- jump to the same address,
- `*_bus_data_read.v` -- try to read all memory types,
- `*_bus_data_write.v` -- write zero to all PWMs,
- `*_bus_data_byte_access.v` -- try to read/write singular bytes, tests write mask,
- `*_counters.v` -- test cycle and instruction counters,
- `*_stack.v` -- try to use stack,
- `*_uart0.v` -- write uart and wait,
- `dbgu32_mem.v` -- program memory cell by uart.





## C test code
- `led.c` -- test PWM,
- `led_breathe.c` -- cycle through RGB leds,
- `counters.c` -- tests performance counters required for Dhrystone benchmarking,
- `uart.c` -- simple UART test, send "a" 10 times and stop,
- `delay.c` -- send character each 100ms,
- `ram.c` -- test RAM mapping,
- `ram_test.c` -- test whole RAM,
- `time.c` -- hardware timer test,
- `uart_comm.c` -- send hello world, echo characters,
- `print_test.c` -- test lightweight `printf`.

### GCC Toolchain
Unfortunately, a lot of distros don't provide prebuilt packages
for this simplest 32-bit architecture. Note: requires ~10GB of space and
*quite a bit* of time.
Install prerequisites:
`sudo apt install build-essential texi2html texinfo gawk bison flex libgmp-dev libmpfr-dev libmpfrc++-dev`.
Do tell me when some packages are still missing from this list.
```
git clone https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
mkdir build-rv32i
cd build-rv32i
sudo mkdir /opt/riscv32i
sudo chown $USER /opt/riscv32i
../configure --with-arch=rv32i --prefix=/opt/riscv32i
make -j4
```
If case of any failures, rerun with single-core `make` and install missing packages.
Add `/opt/riscv/bin/` to `$PATH`.
Now try to deploy the test files:
```
cd c
make
```
To upload selected `.hex` files with `debug_uart/upload.sh` (see [here](https://github.com/MrJake222/debug_uart)), use:
`./upload.sh path/to/c/led.hex`.

### Linking
Provided linker script `linker.ld` links the object files into ROM (`0x20000`) and arrays into RAM(`0x00000`).
Entry point of the code is the naked, `.boot` section `_start` function.
Linker makes sure `_start` function comes first at the start of ROM.
All tests initialize stack and jump to `main`.

### Dumping testbench code
Provided `tbdump.sh` file uses `objdump` and various shell utils to produce testbench code
which will force the program into ROM at tests' start.

### Dhrystone
After testing the core with programs listed above, try running the provided benchmark.
Dhrystone was modified to use callbacks to register performance counter / timers values.





## Misc
- `.pcf` -- Physical constraint file, to map toplevel's pins to package pins,
- `gcp.sh` -- copies `.gtkw` testbench files and changes data reference names inside them,
- `cells.py` -- custom script to list LUT consumption per module (run via `cells` target),
- `util.py` -- custom script to list general resource consumption (run via `all` or `util` targets).
