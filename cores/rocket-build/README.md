- Install [`firtool`](https://github.com/llvm/circt/releases/tag/firtool-1.40.0)
- Install `mill` version 0.11.x from [here](https://mill-build.org/mill/cli/installation-ide.html)
- `riscv-tests` from [here](https://github.com/riscv-software-src/riscv-tests)
  - install `picolibc-riscv64-unknown-elf` package (Debian)
  - modify `RISCV_GCC_OPTS ?= --specs=picolibc.specs ...`
  - provide with `RISCV` env variable to rocket
