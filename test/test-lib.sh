#!/bin/bash
set -euo pipefail
shopt -s lastpipe

printf '%s:\n' "$(basename "$PWD")" 1>&2

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

	if [[ ${#extra_args[@]} -gt 0 ]]
	then
		args+=("${extra_args[@]}")
	fi

	"${args[@]}" test.d

	node test.js > output.txt
	diff -u output.exp output.txt

	printf '  >>> OK\n' 1>&2
}

function SkipTest() {
	printf '  >>> Skipped!\n' 1>&2
	exit 0
}
