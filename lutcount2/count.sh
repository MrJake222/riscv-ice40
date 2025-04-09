#!/bin/bash

function lutcount {
	# $1 -- name
	# $2 -- tld
	# $3 -- prefix
	# .. -- main (first) + extra files
	name=$1
	tld=$2
	prefix=$3
	shift 3
	main=$1   # first file = main file
	files=$@  # all files (main+extra)
	
	json="$name.hw.json"
	cells="$name.cells"
	
	if [[ ! -f $json || $json -ot $main ]]; then
		cd $prefix && yosys -p "synth_ice40 -top $tld -json $json" -q $files && cd - > /dev/null
		if [[ $? != 0 ]]; then exit 1; fi
		mv $prefix/$json . > /dev/null 2>&1
	fi

	if [[ ! -f $cells || $cells -ot $json ]]; then
		../cells.py $json $tld > $cells
		if [[ $? != 0 ]]; then rm $cells; exit 1; fi
	fi

	printf "%35s:  " $name
	tail -n1 $cells
}

if [[ $1 == "clean" ]]; then
	rm *.hw.json
	rm *.cells
	exit 0
fi

C="../cores"
picorv32_extra="$C/picorv32/picorv32.v"
rocket_extra="Arbiter3_LLWB.v BreakpointUnit.v CSRFile.v IBuf.v MulDiv.v PlusArgTimeout.v rf_combMem.v RocketALU.v RVCExpander.v"
cv_extra="cv32e40p_aligner.v cv32e40p_alu_div.v cv32e40p_alu.v cv32e40p_apu_disp.v cv32e40p_clock_gate.v cv32e40p_compressed_decoder.v cv32e40p_controller.v cv32e40p_core.v cv32e40p_cs_registers.v cv32e40p_decoder.v cv32e40p_ex_stage.v cv32e40p_ff_one.v cv32e40p_fifo.v cv32e40p_fp_wrapper.v cv32e40p_hwloop_regs.v cv32e40p_id_stage.v cv32e40p_if_stage.v cv32e40p_int_controller.v cv32e40p_load_store_unit.v cv32e40p_mult.v cv32e40p_obi_interface.v cv32e40p_popcnt.v cv32e40p_prefetch_buffer.v cv32e40p_prefetch_controller.v cv32e40p_register_file.v cv32e40p_sleep_unit.v fpnew_cast_multi_2E827_67072.v fpnew_classifier.v fpnew_divsqrt_multi_E225A_B8CF6.v fpnew_divsqrt_th_32_3DF01_FC8AC.v fpnew_fma_EA93F.v fpnew_fma_multi_B5D6B_2D261.v fpnew_noncomp_DE16F.v fpnew_opgroup_block_37AAD.v fpnew_opgroup_fmt_slice_07650.v fpnew_opgroup_multifmt_slice_23084.v fpnew_rounding.v fpnew_top_8A78A.v"

lutcount "picorv32_default"		"picorv32_tb"	"."									"picorv32_default.v"		${picorv32_extra}
lutcount "VexRiscv_smprod_my"	"VexRiscv"		"$C/vexriscv-build"					"VexRiscv_smprod_my.v"
#lutcount "Rocket_small"		"Rocket"		"$C/rocket-build/Rocket_small" 		"Rocket.v" 					${rocket_extra}
lutcount "Rocket_tiny"			"Rocket"		"$C/rocket-build/Rocket_tiny" 		"Rocket.v" 					${rocket_extra}
lutcount "cv32e40p"				"cv32e40p_top"	"$C/cv32e40p-build/cv32"			"cv32e40p_top.v" 			${cv_extra}
