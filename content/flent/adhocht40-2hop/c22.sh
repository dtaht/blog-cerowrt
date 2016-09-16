#!/bin/sh

F="flent -4 -l 30 --test-parameter=wifi_stats_hosts=root@lite-4 --test-parameter=wifi_stats_interfaces=wlan1 --test-parameter=wifi_stats_stations=68:72:51:48:d7:b5,80:2a:a8:17:1b:1d,80:2a:a8:17:1e:95,80:2a:a8:4a:28:00"

$F -H lite-3 -H m2-1 -H lite-1 -H lite-2  -t "routers-txpower_20-bw_30Mbit_rtt_48-adhoc-one-hop-4-station-m2-ht40" rtt_fair4be
$F -H c2 -H nemesis -H lite-1 -H lite-2  -t "with-c2+laptop-txpower_20-bw_30Mbit_rtt_48-adhoc-one-hop-4-station-m2-ht40" rtt_fair4be

for i in 1 2 3 4 5
do
for i in up down
do
$F -H lite-3 -H nemesis -H lite-1 -H lite-2 -t "with-laptop-txpower-20-bw_30Mbit_rtt_48-stats-adhoc-one-hop-4-station-m2-ht40-$i" rtt_fair_var_$i
$F -H c2 -H nemesis -H lite-1 -H lite-2 -t "with-c2+laptop-txpower-20-bw_30Mbit_rtt_48-stats-adhoc-one-hop-4-station-m2-ht40-$i" rtt_fair_var_$i
$F -H c2 -H m2-1 -H lite-1 -H lite-2 -t "with-c2-txpower-20-bw_30Mbit_rtt_48-stats-adhoc-one-hop-4-station-m2-ht40-$i" rtt_fair_var_$i
$F -H lite-3 -H m2-1 -H lite-1 -H lite-2 -t "routers-txpower-20-bw_30Mbit_rtt_48-stats-adhoc-one-hop-4-station-m2-ht40-$i" rtt_fair_var_$i
done 
done
exit 0

$F -H lite-3 -H nemesis -H lite-1 -H lite-2 -t "adhoc-one-hop-4-station-ht40" bw_30Mbit_rtt_fair_var

for s in nemesis lite-1 lite-2 lite-3
do
for i in 1 2 4 8 12 16 24 48
do
$F -H $s -t "$s-adhoc-one-hop-$i-flows-ht40" --test-parameter=upload_streams=$i tcp_nup;
$F -H $s -t "$s-adhoc-one-hop-$i-flows-ht40" --test-parameter=download_streams=$i tcp_ndown;
done
done

$F -H lite-3 -t "adhoc-one-hop-ht40" rrul_be;
$F -H lite-3 -t "adhoc-one-hop-ht40" rrul;
$F -H lite-2 -t "adhoc-one-hop-ht40" rrul_be;
$F -H lite-2 -t "adhoc-one-hop" rrul;


