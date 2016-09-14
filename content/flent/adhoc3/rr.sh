#!/bin/sh

F="flent -4 -l 300"

for s in lite-1 lite-2 lite-3
do
$F -H $s -t "$s-ecn-adhoc-one-hop-simul-long" rrul_be &
#$F -H $s -t "$s-adhoc-one-hop" rrul &
done

