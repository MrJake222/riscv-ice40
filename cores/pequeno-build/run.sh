#!/bin/bash

function build {
	TOP="pqr5_core_top"
    target=$1
    
    pq="../pequeno/src"
    src="../pequeno/src/core"
    common="$pq/common"
    
    mods="-y $src"
    incl=""
    pkgs="$common/pqr5_core_pkg.sv"
    extra=""
    defines="-DCORE_SYNTH"
    
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

build pqr5
