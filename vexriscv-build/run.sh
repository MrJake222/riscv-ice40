function build {
	variant=$1
	filename=$2

    if [[ ! -f $2 ]]; then
        cd ../vexriscv-impl
        sbt "runMain vexriscv.demo.$1"
        cd -

        echo "Installing $1 in $2"
        mv ../vexriscv-impl/VexRiscv.v $2
        echo ""
    else
        echo $2 exists
    fi
}

build GenSmallest                   VexRiscv_sm.v
build GenSmallAndProductive         VexRiscv_smprod.v
build GenSmallAndProductiveMy       VexRiscv_smprod_my.v
build GenSmallAndProductiveICache   VexRiscv_smprod_icache.v
build GenFullNoMmuNoCache           VexRiscv_full_nommu_nocache.v
