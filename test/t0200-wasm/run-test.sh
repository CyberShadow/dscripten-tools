#!/bin/bash
source ../test-lib.sh

if [[ -n ${TRAVIS+x} ]]
then
	# Travis' GCC seems to crash / run out of resources while
	# attempting to build Binaryen.
	# https://travis-ci.org/CyberShadow/dscripten-tools/builds/377109592
	SkipTest
fi

extra_args+=(--wasm)
RunTest
