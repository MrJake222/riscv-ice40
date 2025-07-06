#!/bin/bash

if [[ $# != 2 ]]; then
  echo "Usage: $0 [core name.bin] <bench name>"
  exit 1
fi

NAME=`basename $1 .bin`
BENCH="$2"

if [[ "x$BENCH" == "xdhrystone" ]]; then
	FOGML=0
elif [[ "x$BENCH" == "xfogml" ]]; then
	FOGML=1
else
	echo "unknown bench: $BENCH."
	echo "available: dhrystone, fogml"
	exit 1
fi

# debug.py & upload.sh
P1="$HOME/Projects/6502_v2/debug uart/debug_uart"
# read.py & plot.py
P2="$HOME/Projects/Analog/amprobe"
# send.py / send-data-x116.gz
P3="$HOME/Projects/pico-ice/fogml-riscv"
# add scripts to path
PATH="$PATH:$P1:$P2:$P3"
# debug params
DPARAMS="--d32 -p /dev/ttyACM2 -b 1000000"
# benchmark hex
if [[ $FOGML == 0 ]]; then
	# dhrystone
	DHEX="../dhrystone/dhrystone.hex"
else
	# fogml
	[[ $NAME =~ fpu ]] && DHEX="fogml-riscv-fpu.hex" || DHEX="fogml-riscv.hex"
	# DHEX="fogml-riscv.hex"
fi

#echo "upload core $NAME"
dfu-util -d 1209:b1c0 -a "iCE40 DFU (CRAM)" -D "$NAME.bin"

function stop_reset {
	echo "disable freerun and schedule a core's reset"
	debug.py $DPARAMS run -n
	debug.py $DPARAMS reset
}
stop_reset

echo "upload benchmark $DHEX"
debug.py $DPARAMS write --ihex $DHEX -v

function do_measure {
	stop_reset

	echo "starting measurement in 1 sec..."
	sleep 1

	read.py 30 &

	echo "measuring baseline (5 sec)"
	sleep 5

	echo "enabling freerun"
	debug.py $DPARAMS run -f
	
	if [[ $FOGML == 1 ]]; then
		echo "sending fogml data"
		gunzip -c $P3/send-data-x116.gz | send.py 100 /dev/ttyACM3 &
	fi
	
	echo "waiting for the benchmark to end (20 sec)"
	sleep 25

	wait
	echo "measurment ended"

	if [[ $FOGML == 0 ]]; then
		name="${NAME}${1}.log"
	else
		name="fogml_${NAME}${1}.log"
	fi
	
	mv read.log "$name"
	echo "saved as $name"
}

# do_measure ""
do_measure 1 && do_measure 2
# do_measure 3 && do_measure 4

