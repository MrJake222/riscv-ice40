#!/bin/bash

# read.py & plot.py
P2="$HOME/Projects/Analog/amprobe"
# add scripts to path
PATH="$PATH:$P2"

plot.py "5,clk=0,0.1, 7.7,dsp,0.15, 24.5,learn,0.2, 28,inf,0.25,   30,end,0.05" fogml_16MHz_dark[1-4].log
mv Figure.pdf power_fogml.pdf
plot.py "5,clk=0,0.1,   7,dsp,0.15,  9.7,learn,0.2, 10.9,inf,0.25, 30,end,0.05" fogml_16MHz_dark_fpu[1-4].log
mv Figure.pdf power_fogml_fpu.pdf
