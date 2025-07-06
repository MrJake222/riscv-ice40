#!/bin/bash

# read.py & plot.py
P2="$HOME/Projects/Analog/amprobe"
# add scripts to path
PATH="$PATH:$P2"

plot.py "5,clk=0,0.1, 23,x,0, 25,inf loop,0.2" 8MHz_dark.log 8MHz_femto.log 8MHz_pico.log 8MHz_vex.log 8MHz_haz.log
mv Figure.pdf power8.pdf

plot.py "5,clk=0,0.1, 15,x,0, 25,inf loop,0.2" 16MHz_dark.log 16MHz_femto.log 16MHz_pico.log 16MHz_vex.log
mv Figure.pdf power16.pdf
