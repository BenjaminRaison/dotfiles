#!/bin/bash
if [ "$(/usr/sbin/rfkill --output SOFT | grep -Ec '\bblocked')" -gt 0 ]; then
    /usr/sbin/rfkill unblock all
else
    /usr/sbin/rfkill block all
fi
