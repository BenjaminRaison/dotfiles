#!/usr/bin/env bash

output=$(aptitude search '~U' | wc -l)


if [ $output -gt 0 ];
then
	echo ""
else
	echo ""
fi
