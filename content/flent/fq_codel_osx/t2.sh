#!/bin/sh

#flent -t "psk2-cc-ht40-linux-nosqm" -H 192.168.1.105 -l 30 rrul
#flent -t "psk2-cc-ht40-linux-nosqm" -H 192.168.1.105 -l 30 rrul_be

for i in 2
do
#flent -t "psk2-cc-ht40-$i-flows-linux-cap" -H 192.168.1.105 -l 30 --test-parameter=upload_streams=$i tcp_nup
flent -t "psk2-cc-ht40-$i-flows-60mbit-cap-ecn" -H 192.168.1.105 -l 30 --test-parameter=download_streams=$i tcp_ndown
done

