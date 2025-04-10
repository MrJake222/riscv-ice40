#!/bin/bash

# absolute path to output directory
L="`pwd`"
Lo="$L/out"
C="../cores"

function all_older() {
	# $1 -- target file
	# $2 -- source wdir
	# .. -- source files
	target=$1
	wdir=$2
	shift 2
	
	cd $wdir
	for file in "$@"; do
		if [ "$file" -nt "$target" ]; then
			cd - > /dev/null
			return 1 # at least one file modified
		fi
	done
	
	cd - > /dev/null
	return 0
}

function lutcount {
	# $1 -- name
	# $2 -- tld
	# $3 -- wordking directory
	# .. -- src files
	name=$1
	tld=$2
	wdir=$3
	shift 3
	files=$@
		
	json="$Lo/$name.hw.json"
	cells="$Lo/$name.cells"
	
	all_older $json $wdir $files # returns $?=1 when at least one modified
	if [[ ! -f $json || $? -eq 1 ]]; then
		echo "calc $name"
		# run yosys in the working directory, output json to local output dir
		cd $wdir && yosys -q -p "synth_ice40 -top $tld -json $json" $files && cd - > /dev/null
		if [[ $? != 0 ]]; then exit 1; fi
	fi

	if [[ ! -f $cells || $cells -ot $json ]]; then
		../cells.py $json $tld > $cells
		if [[ $? != 0 ]]; then rm $cells; exit 1; fi
	fi

	printf "%35s:  " $name
	tail -n1 $cells
}

if [[ $1 == "clean" ]]; then
	rm $Lo/*.hw.json
	rm $Lo/*.cells
	exit 0
fi

rocket_src="Arbiter3_LLWB.v BreakpointUnit.v CSRFile.v IBuf.v MulDiv.v PlusArgTimeout.v rf_combMem.v RocketALU.v Rocket.v RVCExpander.v"
cv_src="cv32e40p_aligner.v cv32e40p_alu_div.v cv32e40p_alu.v cv32e40p_apu_disp.v cv32e40p_clock_gate.v cv32e40p_compressed_decoder.v cv32e40p_controller.v cv32e40p_core.v cv32e40p_cs_registers.v cv32e40p_decoder.v cv32e40p_ex_stage.v cv32e40p_ff_one.v cv32e40p_fifo.v cv32e40p_fp_wrapper.v cv32e40p_hwloop_regs.v cv32e40p_id_stage.v cv32e40p_if_stage.v cv32e40p_int_controller.v cv32e40p_load_store_unit.v cv32e40p_mult.v cv32e40p_obi_interface.v cv32e40p_popcnt.v cv32e40p_prefetch_buffer.v cv32e40p_prefetch_controller.v cv32e40p_register_file.v cv32e40p_sleep_unit.v cv32e40p_top.v fpnew_cast_multi_2E827_67072.v fpnew_classifier.v fpnew_divsqrt_multi_E225A_B8CF6.v fpnew_divsqrt_th_32_3DF01_FC8AC.v fpnew_fma_EA93F.v fpnew_fma_multi_B5D6B_2D261.v fpnew_noncomp_DE16F.v fpnew_opgroup_block_37AAD.v fpnew_opgroup_fmt_slice_07650.v fpnew_opgroup_multifmt_slice_23084.v fpnew_rounding.v fpnew_top_8A78A.v"
rv32_src="picorv32.v"
ibex_src="ibex_alu.v ibex_branch_predict.v ibex_compressed_decoder.v ibex_controller.v ibex_core.v ibex_counter.v ibex_cs_registers.v ibex_csr.v ibex_decoder.v ibex_dummy_instr.v ibex_ex_block.v ibex_fetch_fifo.v ibex_icache.v ibex_id_stage.v ibex_if_stage.v ibex_load_store_unit.v ibex_lockstep.v ibex_multdiv_fast.v ibex_multdiv_slow.v ibex_pmp.v ibex_prefetch_buffer.v ibex_register_file_ff.v ibex_register_file_fpga.v ibex_register_file_latch.v ibex_top.v ibex_wb_stage.v prim_clock_gating.v prim_generic_buf.v prim_generic_flop.v"
darkriscv_src="darkriscv.v"
kronos_src="kronos_agu.v kronos_alu.v kronos_branch.v kronos_core.v kronos_counter64.v kronos_csr.v kronos_EX.v kronos_hcu.v kronos_ID.v kronos_IF.v kronos_lsu.v kronos_RF.v"
hazard_src="hazard3_decode.v hazard3_triggers.v hazard3_instr_decompress.v hazard3_csr.v hazard3_power_ctrl.v arith/hazard3_onehot_priority.v arith/hazard3_shift_barrel.v arith/hazard3_priority_encode.v arith/hazard3_onehot_encode.v arith/hazard3_onehot_priority_dynamic.v arith/hazard3_muldiv_seq.v arith/hazard3_alu.v arith/hazard3_mul_fast.v arith/hazard3_branchcmp.v hazard3_cpu_2port.v hazard3_regfile_1w2r.v hazard3_core.v hazard3_irq_ctrl.v hazard3_frontend.v hazard3_pmp.v hazard3_cpu_1port.v debug/dtm/hazard3_ecp5_jtag_dtm.v debug/dtm/hazard3_jtag_dtm.v debug/dtm/hazard3_jtag_dtm_core.v debug/cdc/hazard3_sync_1bit.v debug/cdc/hazard3_reset_sync.v debug/cdc/hazard3_apb_async_bridge.v debug/dm/hazard3_sbus_to_ahb.v debug/dm/hazard3_dm.v"

#			name				tld				work dir							src...
lutcount "Rocket_tiny"			"Rocket"		"$C/rocket-build/Rocket_tiny" 		${rocket_src}
lutcount "cv32e40p"				"cv32e40p_top"	"$C/cv32e40p-build/cv32"			${cv_src}
lutcount "picorv32_counters"	"picorv32_tb"	"$C/picorv32"						${rv32_src}			"$L/picorv32_counters.v"
lutcount "ibex_noM"				"ibex_noM"		"$C/ibex-build/ibex"				${ibex_src}			"$L/ibex_noM.v"
lutcount "darkriscv"			"darkriscv"		"$C/darkriscv-build/rv32i"			${darkriscv_src}
lutcount "kronos"				"kronos_core"	"$C/kronos-build/kronos"			${kronos_src}
lutcount "hazard3_noMAC"		"hazard3_noMAC"	"$C/Hazard3/hdl"					${hazard_src}		"$L/hazard3_noMAC.v"
# nox
# pequeno
# rvx
# rsd (huge)
lutcount "VexRiscv_smprod_my"	"VexRiscv"		"$C/vexriscv-build"					"VexRiscv_smprod_my.v"
