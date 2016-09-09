#!/bin/sh

F="flent -4 -l 30"

for i in up down
do
$F -H lite-3 -H lite-2 -H lite-3 -H lite-2 -t "adhoc-one-hop-2-station" rtt_fair_var_$i
$F -H lite-3 -H lite-3 -H lite-3 -H lite-3 -t "adhoc-one-hop-1-station" rtt_fair_var_$i
$F -H lite-2 -H lite-2 -H lite-2 -H lite-2 -t "adhoc-one-hop-1-station" rtt_fair_var_$i
$F -H lite-3 -H lite-2 -H lite-3 -H lite-2 -t "adhoc-one-hop-2-station" rtt_fair_var_$i
done 

#$F -H lite-3 -H lite-2 -H lite-3 -H lite-2 -t "adhoc-one-hop-4-station" rtt_fair_var
for i in 1 2 4 8 12 16 24 48
do
$F -H lite-3 -t "adhoc-one-hop-$i-flows" --test-parameter=upload_streams=$i tcp_nup;
$F -H lite-3 -t "adhoc-one-hop-$i-flows" --test-parameter=download_streams=$i tcp_ndown;
done

$F -H lite-3 -t "adhoc-one-hop" rrul_be;
$F -H lite-3 -t "adhoc-one-hop" rrul;
$F -H lite-2 -t "adhoc-one-hop" rrul_be;
$F -H lite-2 -t "adhoc-one-hop" rrul;


