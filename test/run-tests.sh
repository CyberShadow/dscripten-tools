#!/bin/bash
set -euo pipefail
shopt -s lastpipe

for dir in ./t????-*
do
	(
		cd "$dir"
		printf '%s:\n' "$dir" 1>&2
		./run-test.sh
		printf '  >>> OK\n' 1>&2
	)
done

printf 'All tests OK!\n' 1>&2
