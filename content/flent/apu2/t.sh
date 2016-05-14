#!/bin/sh

S0=172.26.128.10 # linux
S1=172.26.128.11 # osx
T='300_90Mbit-ecn-cake'
S2="-H $S0 -H $S0 -H $S1 -H $S1"
OPTS="--step-size=.05 --test-parameter=qdisc_stats_hosts=rudolf,rudolf --test-parameter=qdisc_stats_interfaces=enp2s0,enp3s0"
# Make sure we're alive

fping -c 3 $S0 $S1

flent $OPTS -H $S0 -t "$T-linux" tcp_12down
flent $OPTS -H $S1 -t "$T-mavericks" tcp_12down
flent $OPTS -H $S0 -t "$T-linux" tcp_12up
flent $OPTS -H $S1 -t "$T-mavericks" tcp_12up
flent $OPTS -H $S0 -t "$T-linux" tcp_upload
flent $OPTS -H $S1 -t "$T-mavericks" tcp_upload
flent $OPTS -H $S0 -t "$T-linux" tcp_download
flent $OPTS -H $S1 -t "$T-mavericks" tcp_download

for i in CS0 # CS1 CS5 CS6
do
flent $OPTS --swap-up-down $S2 --test-parameter=cc=cubic --test-parameter=dscp=$i,$i -t "$T-$i-cubic-down" rtt_fair_up
flent $OPTS --swap-up-down $S2 --test-parameter=cc=reno --test-parameter=dscp=$i,$i -t "$T-$i-reno-down" rtt_fair_up
done
# The last test tends to blow up babel
fping -c 3 $S0 $S1
sleep 30
fping -c 3 $S0 $S1

flent $OPTS $S2 -t "$T-up" rtt_fair_up
flent $OPTS $S2 -t "$T" rtt_fair4be

#flent $OPTS -l 600 --swap-up-down $S2 test-parameter=cc=cubic --test-parameter=dscp=CS0,CS0 -t "$T-down-long" rtt_fair_up
#flent $OPTS -l 600 $S2 test-parameter=cc=cubic --test-parameter=dscp=CS0,CS0 -t "$T-up-long" rtt_fair_up

# stress tests

flent $OPTS -H $S0 -t "$T-linux" rrul_be
flent $OPTS -H $S1 -t "$T-mavericks" rrul_be

# And blow up the queues last

flent $OPTS -H $S0 -t "$T" rrul
flent $OPTS -H $S1 -t "$T" rrul

