#!/bin/sh

F="flent -4 -l 30 --test-parameter=wifi_stats_hosts=root@lite-4 --test-parameter=wifi_stats_interfaces=wlan1 --test-parameter=wifi_stats_stations=68:72:51:48:d7:b5,80:2a:a8:17:1b:1d,80:2a:a8:17:1e:95,80:2a:a8:4a:28:00"


for s in lite-3
do
for i in 1 2 4 8 12 16 24 48
do
$F -H $s -t "$s-adhoc-one-hop-$i-flows-ht40" --test-parameter=upload_streams=$i tcp_nup;
$F -H $s -t "$s-adhoc-one-hop-$i-flows-ht40" --test-parameter=download_streams=$i tcp_ndown;
done
done

$F -H lite-3 -t "lite-3-adhoc-one-hop-ht40" rrul_be;
$F -H lite-3 -t "lite-3-adhoc-one-hop-ht40" rrul;
#$F -H lite-2 -t "adhoc-one-hop-ht40" rrul_be;
#$F -H lite-2 -t "adhoc-one-hop" rrul;


