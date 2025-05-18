#!/bin/bash

if [[ $# != 1 ]]; then
  echo "Usage: $0 [core name.bin]"
  exit 1
fi

NAME=`basename $1 .bin`

# debug.py & upload.sh
P1="$HOME/Projects/6502_v2/debug uart/debug_uart"
# read.py & plot.py
P2="$HOME/Projects/Analog/amprobe"
# add scripts to path
PATH="$PATH:$P1:$P2"
#echo $PATH
# dhrystone benchmark hex
DHEX="$HOME/Projects/pico-ice/risc-v/dhrystone/dhrystone.hex"
# debug params
DPARAMS="--d32 -p /dev/ttyACM2 -b 1000000"

echo "uploading the core's bitstream"
dfu-util -d 1209:b1c0 -a "iCE40 DFU (CRAM)" -D "$NAME.bin"

echo "upload benchmark"
debug.py $DPARAMS write --ihex $DHEX -v

function do_measure {
	echo "disable freerun and schedule a core's reset"
	debug.py $DPARAMS run -n
	debug.py $DPARAMS reset

	echo "starting measurement in 1 sec..."
	sleep 1

	read.py 25 &

	echo "measuring baseline (5 sec)"
	sleep 5

	echo "enabling freerun"
	debug.py $DPARAMS run -f
	echo "waiting for the benchmark to end (20 sec)"
	sleep 20

	wait
	echo "measurment ended"

	name="${NAME}${1}.log"
	mv read.log "$name"
	echo "saved as $name"
}

#do_measure ""
do_measure 1 && do_measure 2

