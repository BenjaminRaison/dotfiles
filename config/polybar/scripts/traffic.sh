#!/usr/bin/env bash

ifstat -T -n | awk 'NR>2 {print "🠝 " $8 "  🠟 "  $7}; system("")'

