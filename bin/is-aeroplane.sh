#!/bin/bash
if [ "$(/usr/sbin/rfkill --output SOFT | grep -Ec '\bblocked')" -gt 1 ]; then
    echo '{"text": "", "class": "activated"}'
else
    echo '{"text": "", "class": "inactive"}'
fi
