#!/bin/bash

function build {
	TOP="nox"
    target=$1
    
    nox="../nox"
    src="../nox/rtl"
    
    mods="-y $src"
    incl=""
    pkgs="$src/inc/* $nox/bus_arch_sv_pkg/*"
    extra=""
    defines="-DSYNTHESIS -DYOSYS -DNO_ASSERTIONS"
    
    if [[ ! -d ${target} ]]; then
        echo "Installing $target"
        rm -rf ${target} && mkdir ${target}
        sv2v --top=${TOP} -w ${target} ${defines} ${mods} ${incl} ${pkgs} ${extra} ${src}/${TOP}.sv
        if [[ $? != 0 ]]; then rm -rf ${target}; exit 1; fi
    else
        #echo -n "${target} exists, file present: "
        ls -1 ${target} | tr "\n" " "
        echo ""
    fi
}

build nox
