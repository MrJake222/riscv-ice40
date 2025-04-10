#!/bin/bash

function build {
	TOP="kronos_core"
    target=$1
    
    src="../kronos/rtl/core"
	
    mods="-y $src"
    incl=""
    pkgs="$src/kronos_types.sv"
    extra=""
    
    if [[ ! -d ${target} ]]; then
        echo "Installing $target"
        rm -rf ${target} && mkdir ${target}
        
        sv2v --top=${TOP} -w ${target} ${mods} ${incl} ${src}/${TOP}.sv ${pkgs} ${extra}
        if [[ $? != 0 ]]; then rm -rf ${target}; exit 1; fi
    else
        #echo -n "${target} exists, file present: "
        ls -1 ${target} | tr "\n" " "
        echo ""
    fi
}

build kronos
