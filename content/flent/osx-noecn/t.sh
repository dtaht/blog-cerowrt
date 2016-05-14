#!/bin/sh

S0=172.26.130.12
S1=172.26.130.11
S2="-H $S0 -H $S0 -H $S1 -H $S1"
T='txop-94-noecn-step-.2-fqcodel-5'
# Make sure we're alive
OPTS="--test-parameter=qdisc_stats_hosts=apu2 --test-parameter=qdisc_stats_interfaces=wlp4s0 --test-parameter=cpu_stats_hosts=apu2"

fping -c 3 $S0 $S1

flent $OPTS $S2 -t "$T-up" rtt_fair_up
flent $OPTS $S2 --swap-up-down -t "$T-down" rtt_fair_up
flent $OPTS $S2 -t "$T" rtt_fair4be

flent $OPTS -H $S0 -t "$T-ath9k" tcp_12down
flent $OPTS -H $S1 -t "$T-mavericks" tcp_12down
flent $OPTS -H $S0 -t "$T-ath9k" tcp_12up
flent $OPTS -H $S1 -t "$T-mavericks" tcp_12up
flent $OPTS -H $S0 -t "$T-ath9k" tcp_upload
flent $OPTS -H $S1 -t "$T-mavericks" tcp_upload
flent $OPTS -H $S0 -t "$T-ath9k" tcp_download
flent $OPTS -H $S1 -t "$T-mavericks" tcp_download

for i in CS0 # CS1 CS5 CS6
do
flent $OPTS --swap-up-down $S2 -t "$T-$i-cubic-down" rtt_fair_up
done
# The last test tends to blow up babel
fping -c 3 $S0 $S1
sleep 30
fping -c 3 $S0 $S1

flent $OPTS -l 600 --swap-up-down $S2 -t "$T-down-long" rtt_fair_up
flent $OPTS -l 600 $S2 -t "$T-up-long" rtt_fair_up

# stress tests

flent $OPTS -H $S0 -t "$T-ath9k" rrul_be
flent $OPTS -H $S1 -t "$T-mavericks" rrul_be

# And blow up the queues last

flent $OPTS -H $S0 -t "$T-ath9k" rrul
flent $OPTS -H $S1 -t "$T-mavericks" rrul

