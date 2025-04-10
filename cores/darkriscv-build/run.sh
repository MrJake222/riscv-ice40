#!/bin/bash

function build {
    target=$1
    
    src="../darkriscv/rtl"
    
    if [[ ! -d ${target} ]]; then
        echo "Installing $target"
        rm -rf ${target} && mkdir ${target}
        
        cp ${src}/darkriscv.v ${target}
        cp ${src}/config.vh ${target}
        sed -i 's/..\/rtl\/config.vh/config.vh/g' ${target}/darkriscv.v
        sed -i 's/`define __RV32E__/\/\/`define __RV32E__/g' ${target}/config.vh
    else
        #echo -n "${target} exists, file present: "
        ls -1 ${target} | tr "\n" " "
        echo ""
    fi
}

build rv32i
