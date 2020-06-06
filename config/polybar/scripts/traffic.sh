#!/usr/bin/env bash

ifstat -T -n | awk 'NR>2 {print "🠝 " $NF "  🠟 "  $(NF-1)}; system("")'

