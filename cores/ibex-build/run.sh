#!/bin/bash

function build {
	TOP="ibex_top"
    target=$1
    
    ibex="../ibex"
    src="$ibex/rtl"
    srcip="$ibex/vendor/lowrisc_ip/ip/prim/rtl"
    srcipg="$ibex/vendor/lowrisc_ip/ip/prim_generic/rtl"
    srcdv="$ibex/vendor/lowrisc_ip/dv/sv/dv_utils"
    srcuvm="$ibex/dv/uvm/core_ibex/common/prim"
	syn="$ibex/syn/rtl"
	
    mods="-y $src" # -y $srcipg -y $srcuvm"
    incl="-I $srcip -I $srcdv"
    pkgs="$src/ibex_pkg.sv $srcip/prim_ram_1p_pkg.sv $srcip/prim_secded_pkg.sv $srcuvm/prim_pkg.sv"
    extra="$srcipg/prim_generic_buf.sv $srcipg/prim_generic_flop.sv"
    
    if [[ ! -d ${target} ]]; then
        echo "Installing $target"
        rm -rf ${target} && mkdir ${target}
        
        OPTS="-w ${target} -DSYNTHESIS -DYOSYS"
		sv2v ${OPTS} ${incl} "$srcipg/prim_generic_buf.sv"
		sv2v ${OPTS} ${incl} "$srcipg/prim_generic_flop.sv"
        sv2v --top=${TOP} ${OPTS} ${mods} ${incl} ${src}/${TOP}.sv ${pkgs} ${extra}
        if [[ $? != 0 ]]; then rm -rf ${target}; exit 1; fi
		cp "$syn/prim_clock_gating.v" ${target}
		        
        # replace with generics
        sed -i 's/prim_buf/prim_generic_buf/g' ${target}/*.v
        sed -i 's/prim_flop/prim_generic_flop/g' ${target}/*.v
    else
        #echo -n "${target} exists, file present: "
        ls -1 ${target} | tr "\n" " " | sed "s/${TOP}.v //g"
        echo ""
        echo ""
        echo "top: ${TOP}.v"
    fi
}

build ibex
