function build {
	variant=$1
	file=$2
    src=../vexriscv-impl/src/main/scala/vexriscv/demo/$variant.scala

    if [[ ! -f $file || $file -ot $src ]]; then
        cd ../vexriscv-impl
        sbt "runMain vexriscv.demo.$variant"
        cd -

        echo "Installing $variant in $file"
        mv ../vexriscv-impl/VexRiscv.v $file
        echo ""
    else
        echo $file up to date
    fi
}

build GenSmallest                   VexRiscv_sm.v
build GenSmallestMy                 VexRiscv_sm_my.v
build GenSmallAndProductive         VexRiscv_smprod.v
build GenSmallAndProductiveMy       VexRiscv_smprod_my.v
build GenSmallAndProductiveMyMulDiv VexRiscv_smprod_my_muldiv.v
build GenSmallAndProductiveICache   VexRiscv_smprod_icache.v
build GenFullNoMmuNoCache           VexRiscv_full_nommu_nocache.v
build GenFullNoMmuNoCacheSimpleMul  VexRiscv_full_simple.v
