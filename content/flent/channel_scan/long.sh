#!/bin/sh

S0=172.26.130.12
S1=172.26.130.11
S2="-H $S0 -H $S0 -H $S1 -H $S1"
T='txop-94-ecn-networkmanager-fqcodel-kitchen-tim'
# Make sure we're alive

fping -c 3 $S0 $S1
flent -l 300 --step-size=.05 --swap-up-down -H $S0 -H $S0 -H $S0 -H $S0  -t "$T-down-long" rtt_fair_up
flent -l 300 --step-size=.05 -H $S0 -H $S0 -H $S0 -H $S0  -t "$T-up-long" rtt_fair_up
exit
flent -l 600 --swap-up-down $S2 -t "$T-down-long" rtt_fair_up
flent -l 600 $S2 "$T-up-long" rtt_fair_up


