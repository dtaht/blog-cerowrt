#!/bin/sh
RTT=48ms
DOWN=100mbit
UP=100mbit
QDISC=cake
TITLE=ecn_${QDISC}_nooffload_vs_sch_fq
#TITLE=ecn_fq_codel_nooffload_vs_sch_fq

#R1=172.26.48.1
#S=172.26.48.10
#S1=172.26.48.11
R1=router
S=linux
S1=osx

ulimit -n 4096 # the 1000 upload test runs us out of file descriptors - set this everywhere

QSTATS="--test-parameter=qdisc_stats_hosts=$R1,$R1 --test-parameter=qdisc_stats_interfaces=ifb4enp3s0,enp3s0"

SR="$QSTATS -H $S -H $S1 -H $S -H $S1"
NF="--test-parameter=download_streams=12 --test-parameter=upload_streams=4"

N="--note=rtt=$RTT --note=down=$DOWN --note=up=$UP --note=qdisc=${QDISC}\
   --note=offloads=none\
   --remote-metadata=root@$S\
   --remote-metadata=root@$R1"

flent -x $N -t rtt_${RTT}_${TITLE}_${DOWN}_${UP} $SR rrul_be_delayed
#flent -l 600 -x $N -t long-rtt_${RTT}_${TITLE}_${DOWN}_${UP} $SR rrul_be_delayed
exit 0
flent -x $N -t rtt_${RTT}_${TITLE}_${DOWN}_${UP} $SR rrul_50_down
flent -x $N -t rtt_${RTT}_${TITLE}_${DOWN}_${UP} $SR rtt_fair_up
flent -x $N -t rtt_${RTT}_${TITLE}_${DOWN}_${UP} $SR $NF rrul_be
flent -x $N -t rtt_${RTT}_${TITLE}_${DOWN}_${UP} $SR $NF rrul
flent -x $N -t rtt_${RTT}_${TITLE}_${DOWN}_${UP} $SR $NF cubic_dctcp
flent -x $N -t rtt_${RTT}_${TITLE}_${DOWN}_${UP} $SR $NF cubic_cdg
flent -x $N -t rtt_${RTT}_${TITLE}_${DOWN}_${UP} $SR $NF cubic_reno
flent -x $N -t rtt_${RTT}_${TITLE}_${DOWN}_${UP} $SR $NF cubic_westwood

flent -x $N -t rtt_${RTT}_${TITLE}_${DOWN}_${UP}-swap --swap-up-down $SR rtt_fair_up
#flent -x $N -t rtt_${RTT}_${TITLE}_${DOWN}_${UP}-up $SR tcp_upload_1000
flent -x $N -t rtt_${RTT}_${TITLE}_${DOWN}_${UP}-swap --swap-up-down $SR tcp_upload_1000 
flent -x $N -t rtt_${RTT}_${TITLE}_${DOWN}_${UP} $SR $NF rrul_be_nflows
flent -x $N -t rtt_${RTT}_${TITLE}_${DOWN}_${UP} $SR reno_cubic_westwood_cdg

