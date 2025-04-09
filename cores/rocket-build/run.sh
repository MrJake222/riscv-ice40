#!/bin/bash

function build {
    variant=$1
    target=$2
    src="../rocket-impl/out/emulator/freechips.rocketchip.system.TestHarness/freechips.rocketchip.system.$variant/mfccompiler/compile.dest"
    
    #src=../vexriscv-impl/src/main/scala/vexriscv/demo/$variant.scala
    #if [[ ! -f $file || $file -ot $src ]]; then
    
    if [[ ! -d ${target} ]]; then
		cd ../rocket-impl
		MILL=./mill make verilog CONFIG="freechips.rocketchip.system.$variant"
		cd -

        echo "Installing $variant in $target"
        rm -rf ${target} && mkdir ${target}
        sv2v --top=Rocket -w ${target} -y ${src} ${src}/Rocket.sv
        
        # remove debugging calls
        sed -i 's/\$finish/\/\/$finish/g' ${target}/*.v
        sed -i 's/\$display/\/\/$display/g' ${target}/*.v
        sed -i 's/\$fwrite/\/\/$fwrite/g' ${target}/*.v
        # remove reader debug unit
        sed -i 's/plusarg_reader #/\/*plusarg_reader #/g' ${target}/*.v
        sed -i 's/_plusarg_reader_out));/_plusarg_reader_out));*\//g' ${target}/*.v
        echo ""
    else
        echo -n "${target} exists, file present: "
        ls -1 ${target} | tr "\n" " "
        echo ""
    fi
}

build DefaultSmallConfig    Rocket_small
build TinyConfig            Rocket_tiny
