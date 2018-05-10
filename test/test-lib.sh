#!/bin/bash
set -euo pipefail
shopt -s lastpipe

extra_args=()

function BuildTools() {
	(
		cd ../..
		for prog in {dmd,rdmd}-dscripten
		do
			rdmd --build-only -g $prog
		done
	)
}

function RunTest() {
	# Ensure tools are built
	BuildTools

	local args=(
		../../rdmd-dscripten
		--compiler=../../dmd-dscripten
		--build-only
	)

	"${args[@]}" "${extra_args[@]}" test.d

	node test.js > output.txt
	diff -u output.exp output.txt
}
