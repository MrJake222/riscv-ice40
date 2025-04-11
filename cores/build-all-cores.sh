#!/bin/bash

for path in *-build; do
	cd $path
	./run.sh
	cd - > /dev/null
done
