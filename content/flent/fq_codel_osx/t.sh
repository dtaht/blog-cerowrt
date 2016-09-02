#!/bin/sh

flent -t "psk2-cc-ht40-linux-nosqm" -H 192.168.1.105 -l 30 rrul
flent -t "psk2-cc-ht40-linux-nosqm" -H 192.168.1.105 -l 30 rrul_be

for i in 1 2 4 8 12 16 24;
do
flent -t "psk2-cc-ht40-$i-flows-linux-nosqm" -H 192.168.1.105 -l 30 --test-parameter=upload_streams=$i tcp_nup
flent -t "psk2-cc-ht40-$i-flows-linux-nosqm" -H 192.168.1.105 -l 30 --test-parameter=download_streams=$i tcp_ndown
done

