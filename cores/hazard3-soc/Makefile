FNAME = h3soc
# input files
VERILOG = $(FNAME).v
# source files
SRC += hazard3_decode.v hazard3_triggers.v hazard3_instr_decompress.v hazard3_csr.v hazard3_power_ctrl.v
SRC += arith/hazard3_onehot_priority.v arith/hazard3_shift_barrel.v arith/hazard3_priority_encode.v arith/hazard3_onehot_encode.v
SRC += arith/hazard3_onehot_priority_dynamic.v arith/hazard3_muldiv_seq.v arith/hazard3_alu.v arith/hazard3_mul_fast.v arith/hazard3_branchcmp.v
SRC += hazard3_cpu_2port.v hazard3_regfile_1w2r.v hazard3_core.v hazard3_irq_ctrl.v hazard3_frontend.v hazard3_pmp.v hazard3_cpu_1port.v
#SRC += debug/dtm/hazard3_ecp5_jtag_dtm.v debug/dtm/hazard3_jtag_dtm.v debug/dtm/hazard3_jtag_dtm_core.v debug/cdc/hazard3_sync_1bit.v
#SRC += debug/cdc/hazard3_reset_sync.v debug/cdc/hazard3_apb_async_bridge.v debug/dm/hazard3_sbus_to_ahb.v debug/dm/hazard3_dm.v
HAZ=../hazard3/hdl/
VERILOG += $(patsubst %,$(HAZ)%,$(SRC))
# frequency
FREQ  = 8

SELFDIR := $(dir $(lastword $(MAKEFILE_LIST)))
include ${SELFDIR}/../Makefile
