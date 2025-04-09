#!/bin/bash

function build {
	TOP="cv32e40p_top"
    target=$1
    
    src="../cv32e40p/rtl"
    bhv="../cv32e40p/bhv"
    srcfp="$src/vendor/pulp_platform_fpnew/src"
    srccomm="$src/vendor/pulp_platform_common_cells/src"
    
    mods="-y $src -y $srcfp" # -y $srccomm"
    incl="-I $srccomm/../include"
    pkgs="$src/include/*.sv $srcfp/fpnew_pkg.sv"
    extra="$bhv/cv32e40p_sim_clock_gate.sv $src/cv32e40p_register_file_ff.sv" # TODO check
    
    if [[ ! -d ${target} ]]; then
        echo "Installing $target"
        rm -rf ${target} && mkdir ${target}
        sv2v --top=${TOP} -w ${target} ${mods} ${incl} ${src}/${TOP}.sv ${pkgs} ${extra}
        if [[ $? != 0 ]]; then rm -rf ${target}; exit 1; fi
    else
        #echo -n "${target} exists, file present: "
        ls -1 ${target} | tr "\n" " " | sed "s/${TOP}.v //g"
        echo ""
        echo ""
        echo "top: ${TOP}.v"
    fi
}

build cv32
