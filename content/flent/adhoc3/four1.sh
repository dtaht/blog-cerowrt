#!/bin/sh

F="flent -4 -l 30 --test-parameter=wifi_stats_hosts=root@lite-4 --test-parameter=wifi_stats_interfaces=wlan1 --test-parameter=wifi_stats_stations=68:72:51:48:d7:b5,80:2a:a8:17:1b:1d,80:2a:a8:17:1e:95,80:2a:a8:4a:28:00"

$F -H lite-3 -H m2-1 -H lite-1 -H lite-3  -t "all-txpower_20-adhoc-one-hop-4-station-m2-antennna" rtt_fair4be
for i in 1 2 3 4 5
do
for i in up down
do
$F -H lite-3 -H m2-1 -H lite-1 -H lite-2 -t "all-txpower-20-stats-adhoc-one-hop-4-station-m2-antenna" rtt_fair_var_$i
done 
done

$F -H lite-3 -H m2-1 -H lite-1 -H lite-2 -t "adhoc-one-hop-4-station" rtt_fair_var

for s in m2-1 lite-1 lite-2 lite-3
do
for i in 1 2 4 8 12 16 24 48
do
$F -H $s -t "$s-adhoc-one-hop-$i-flows" --test-parameter=upload_streams=$i tcp_nup;
$F -H $s -t "$s-adhoc-one-hop-$i-flows" --test-parameter=download_streams=$i tcp_ndown;
done
done

$F -H lite-3 -t "adhoc-one-hop" rrul_be;
$F -H lite-3 -t "adhoc-one-hop" rrul;
$F -H lite-2 -t "adhoc-one-hop" rrul_be;
$F -H lite-2 -t "adhoc-one-hop" rrul;


