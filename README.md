# RISC-V implementation survey

## C test code
This test code pokes values into memory-mapped PWM interface, which controls the onboard RGB LED. It also features some gamma correction code.

### Linking
Provided linker script `test.ld` links the object files into ROM (`0x20000`). Others section currently untested.
Entry point of the code is the naked, `.boot` section `_start` function, which only calls the `main()` function.
Linker makes sure `_start` function (`j main` instruction) comes first at the start of ROM.

## PicoRV32
This survey uses [Yosys PicoRV32](https://github.com/YosysHQ/picorv32) implementation.

### Verilog code
- `clk.v` -- hosts PLL, generates 1MHz clock for system,
- `crv32.v` -- main SoC file,
- `dbgu32.v` -- debug module, see [debug uart](https://github.com/MrJake222/debug_uart),
- `pwm.v` -- PWM module,
- `ram32.v` -- SPRAM module, 32bit wide,
- `uart.v` -- UART module, used by `dbgu32.v`.

### Testbenches
(probably should've made a separate folder for those...)
- `tb_crv32_core_stack.v`
- `tb_crv32_core.v`
- `tb_crv32_dbgu32_mem.v`
- `tb_dbgu32_mem.v`
- `tb_dep_core.v`
- `tb_dep_uart.v`
- `tb_dep.v`
- `tb_mem.v`

(TODO describe them)

### Misc
- `crv32.pcf` -- Physical constraint file, to map toplevel's pins to package pins,
- `cells.py` -- custom script to list LUT consumption per module (run via `cells` target),
- `util.py` -- custom script to list general resource consumption (run via `all` or `util` targets).
