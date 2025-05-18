#!/bin/bash

function lutcount {
	# $1 -- tld
	# $2 -- main file
	# .. -- extra files
	tld=$1
	main=$2
	shift 2
	files=$@
	
	bname=`basename $main .v`
	json="$bname.hw.json"
	cells="$bname.cells"

	fail=0
	
	if [[ ! -f $cells || $cells -ot $main ]]; then
		yosys -p "synth_ice40 -top $tld -json $json" -q $main $files
		if [[ $? != 0 ]]; then exit 1; fi
		
		../cells.py $json $tld > $cells
		if [[ $? != 0 ]]; then rm $cells; exit 1; fi
	fi

	printf "%35s:  " $bname
	tail -n1 $cells
}

if [[ $1 == "clean" ]]; then
	rm *.hw.json
	rm *.cells
	exit 0
fi

lutcount "picorv32_tb"	"picorv32_default.v"		"picorv32.v"
lutcount "picorv32_tb"	"picorv32_muldiv.v"			"picorv32.v"
lutcount "picorv32_tb"	"picorv32_muldivfast.v"		"picorv32.v"
lutcount "VexRiscv"		"VexRiscv_sm.v"
lutcount "VexRiscv"		"VexRiscv_sm_my.v"
lutcount "VexRiscv"		"VexRiscv_smprod.v"
lutcount "VexRiscv"		"VexRiscv_smprod_my.v"
lutcount "VexRiscv"		"VexRiscv_smprod_my_nopers.v"
lutcount "VexRiscv"		"VexRiscv_smprod_my_muldiv.v"
# lutcount "VexRiscv"		"VexRiscv_smprod_my_fpu.v"
# ERROR: no valid mapping found for memory VexRiscv.FpuPlugin_fpu.rf_scoreboards_0_hit
# consumption was: total  8170 (155%)
lutcount "VexRiscv"		"VexRiscv_smprod_icache.v"
lutcount "VexRiscv"		"VexRiscv_full_nommu_nocache.v"
lutcount "VexRiscv"		"VexRiscv_full_simple.v"
lutcount "FemtoRV32"	"femtorv32_quark.v"
lutcount "FemtoRV32"	"femtorv32_quark_bicycle.v"
lutcount "FemtoRV32"	"femtorv32_tachyon.v"
lutcount "FemtoRV32"	"femtorv32_electron.v"
