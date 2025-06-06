#!/bin/bash

# copy one file over another
# handle any name changes inside

if [[ $# != 2 && $# != 3 ]]; then
	echo "Usage: $0 [mv] <gtkw src> <gtkw dst>"
	exit 1
fi

if [[ "$1" == "mv" ]]; then
	move=1
	shift 1
fi

src=$1
dst=$2

pattern=`basename $1 .gtkw`
replace=`basename $2 .gtkw`

if [[ -f $dst ]]; then cp $dst $dst.bak; fi
cp $src $dst
sed -i "s/$pattern/$replace/g" $dst
if [[ $move == 1 ]]; then rm $src; fi
