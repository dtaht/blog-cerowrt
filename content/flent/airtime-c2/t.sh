#!/bin/sh

F="flent -x --step-size=.05"
S1="-H server -H osx"
S="$S1 $S1"
T="c2-ap-to-osx-and-lite"
for t in up down
do
#$F $S -t "$T-up" rtt_fair_up
$F $S -t "$T-down" --swap-up-down rtt_fair_up
done
