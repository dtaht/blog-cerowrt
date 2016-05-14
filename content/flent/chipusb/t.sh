#!/bin/sh

S0=chipzilla #fd99::23 # chipzilla
S1=rudolf # fd99::12 # rudolf
S2="-H $S0 -H $S0 -H $S1 -H $S1"
T='chipzilla_vs_apu2_cake_single'
# Make sure we're alive

fping6 -c 3 $S0 $S1

flent --local-bind=fd99::1 -6 -H $S0 -t "$T-${S0}" tcp_12down
flent --local-bind=fd99::1 -6 -H $S1 -t "$T" tcp_12down
flent --local-bind=fd99::1 -6 -H $S0 -t "$T-${S0}" tcp_12up
flent --local-bind=fd99::1 -6 -H $S1 -t "$T" tcp_12up
flent --local-bind=fd99::1 -6 -H $S0 -t "$T-${S0}" tcp_upload
flent --local-bind=fd99::1 -6 -H $S1 -t "$T" tcp_upload
flent --local-bind=fd99::1 -6 -H $S0 -t "$T-${S0}" tcp_download
flent --local-bind=fd99::1 -6 -H $S1 -t "$T" tcp_download

for i in CS0 # CS1 CS5 CS6
do
flent --local-bind=fd99::1 -6 --swap-up-down $S2 --test-parameter=cc=cubic --test-parameter=dscp=$i,$i -t "$T-$i-cubic-down" rtt_fair_up
flent --local-bind=fd99::1 -6 --swap-up-down $S2 --test-parameter=cc=reno --test-parameter=dscp=$i,$i -t "$T-$i-reno-down" rtt_fair_up
done
# The last test tends to blow up babel
fping6 -c 3 $S0 $S1
sleep 30
fping6 -c 3 $S0 $S1

flent --local-bind=fd99::1 -6 $S2 -t "$T-up" --test-parameter=cc=cubic --test-parameter=dscp=CS0,CS0 rtt_fair_up
flent --local-bind=fd99::1 -6 $S2 -t "$T" rtt_fair4be

# stress tests

flent --local-bind=fd99::1 -6 -H $S0 -t "$T" rrul_be
flent --local-bind=fd99::1 -6 -H $S1 -t "$T" rrul_be

flent --local-bind=fd99::1 -6 -l 600 --swap-up-down $S2 test-parameter=cc=cubic --test-parameter=dscp=CS0,CS0 -t "$T-down-long" rtt_fair_up

# And blow up the queues last

flent --local-bind=fd99::1 -6 -H $S0 -t "$T" rrul
flent --local-bind=fd99::1 -6 -H $S1 -t "$T" rrul

