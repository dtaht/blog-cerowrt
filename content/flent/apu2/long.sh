#!/bin/sh

S0=172.26.128.10 = linux
S1=172.26.128.11 = osx
S2="-H $S0 -H $S0 -H $S1 -H $S1"
T='300_90Mbit-ecn-cake'
# Make sure we're alive
OPTS="--step-size=.05 --test-parameter=qdisc_stats_hosts=rudolf,rudolf --test-parameter=qdisc_stats_interfaces=enp2s0,enp3s0"

fping -c 3 $S0 $S1
flent $OPTS -l 300 --swap-up-down -H $S0 -H $S0 -H $S0 -H $S0  -t "$T-down-long" rtt_fair_up
flent $OPTS -l 300 -H $S0 -H $S0 -H $S0 -H $S0  -t "$T-up-long" rtt_fair_up
exit
flent $OPTS -l 600 --swap-up-down $S2 -t "$T-down-long" rtt_fair_up
flent $OPTS -l 600 $S2 "$T-up-long" rtt_fair_up


