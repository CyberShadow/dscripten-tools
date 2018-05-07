#!/bin/bash
set -euo pipefail

# Ensure tools are built

for prog in {dmd,rdmd}-dscripten
do
	rdmd --build-only -g ../$prog
done

for dir in ./t????-*
do
	(
		cd "$dir"
		../../rdmd-dscripten --compiler=../../dmd-dscripten --build-only test.d
		node test.js > output.txt
		diff -u output.exp output.txt
	)
done
