#!/bin/sh

S=172.26.128.1
S0=172.26.128.1
S1=172.26.16.130
S2="-H $S -H $S -H $S1 -H $S1"
T='qca-10.2'
# Make sure we're alive

fping -c 3 $S $S1

flent -H $S0 -t "$T-fq" tcp_12down
flent -H $S1 -t "$T" tcp_12down
flent -H $S0 -t "$T-fq" tcp_12up
flent -H $S1 -t "$T" tcp_12up
flent -H $S0 -t "$T0-fq" tcp_upload
flent -H $S1 -t "$T" tcp_upload
flent -H $S0 -t "$T-fq" tcp_download
flent -H $S1 -t "$T" tcp_download

for i in CS0 CS1 CS5 CS6
do
flent --swap-up-down $S2 --test-parameter=cc=cubic --test-parameter=dscp=$i,$i -t "$T-$i-cubic-down" rtt_fair_up
flent --swap-up-down $S2 --test-parameter=cc=reno --test-parameter=dscp=$i,$i -t "$T-$i-reno-down" rtt_fair_up
done
# The last test tends to blow up babel
fping -c 3 $S $S1
#sleep 30
fping -c 3 $S $S1

flent $S2 -t "$T-up" rtt_fair_up
flent $S2 -t "$T" rtt_fair4be

# stress tests

flent -H $S -t "$T"  rrul_be
flent -H $S1 -t "$T" rrul_be
flent -H $S -t "$T" rrul
flent -H $S1 -t "$T" rrul

flent -l 300 --swap-up-down $S2 --test-parameter=dscp=CS0,CS0 -t "$T-$i-down-long" rtt_fair_up

