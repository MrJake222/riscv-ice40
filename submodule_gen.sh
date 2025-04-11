#!/bin/bash

function get_remotes {
	while read path; do
		cd $path
		echo -ne "\t"
		git remote get-url origin
		cd - > /dev/null
	done
}

function gen_submodule_file {
	while read path; do
		cd $path
		origin=`git remote get-url origin`
		branch=`git rev-parse --abbrev-ref HEAD`
echo "[submodule \"$path\"]
	path = $path
	url = $origin
	branch = $branch"
		cd - > /dev/null
	done
}

git submodule | awk '{print $2}' | gen_submodule_file | tee .gitmodules2
mv .gitmodules2 .gitmodules
echo "replaced .gitmodules"
