#!/usr/bin/env bash

human() {
	echo $(numfmt --to=iec-i --suffix=KB $1)
}


ifstat -T -n | awk 'NR>2 {print "🠝 " $8 "  🠟 "  $7}; system("")'

