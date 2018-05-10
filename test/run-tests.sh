#!/bin/bash
set -euo pipefail
shopt -s lastpipe

for dir in ./t????-*
do
	(
		cd "$dir"
		./run-test.sh
	)
done

printf 'All tests OK!\n' 1>&2
