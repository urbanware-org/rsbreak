#!/bin/bash

# ============================================================================
# rsbreak - Quick-and-dirty cancel 'rsync' on error script
# Copyright (C) 2018 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/rsbreak
# GitLab: https://gitlab.com/urbanware-org/rsbreak
# ============================================================================

version="1.0.0"

source="$1"
destination="$2"

if [ -z "$source" ] || [ -z "$destination" ]; then
    echo "Usage: rsbreak.sh SOURCE DESTINATION"
    exit
fi

logfile="/tmp/rsbreak_$$.log"
exitcode=0

rsync -a $source $destination 2>$logfile &
pid=$!

while true; do
    ps aux | grep $pid | grep -v "grep" &>/dev/null
    if [ $? -ne 0 ]; then
        break
    fi

    grep -q -i "error" $logfile
    if [ $? -eq 0 ]; then
        kill $pid
        exitcode=1
        break
    fi
    sleep 1
done

cat $logfile
exit $exitcode

# EOF
