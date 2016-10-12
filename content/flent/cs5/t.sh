#!/bin/sh

F="flent -l 30 -x --step-size=.05"
S1="-H server -H osx"
S="$S1 $S1"
T="CS5-short-c2-ap-to-osx-and-server"
for t in up 
do
$F $S -t "$T-up" rtt_fair_up
$F $S -t "$T-down" --swap-up-down rtt_fair_up
done
