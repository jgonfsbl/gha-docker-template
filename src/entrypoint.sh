#!/bin/ash

# Delay initialization, in case this is desired for whatever reason.

delaystart=$1
if [ -z "${delaystart}" ]
then
    delaystart=0
fi
sleep $delaystart

#
# Write the rest of the script here
#

exit 0
##
