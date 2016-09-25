#!/bin/sh
#root@delay is my delay box which also runs fq_codel and cake (sqm-scripts)
#and is presently setup to emulate a 20Mbit connection and a 48ms rtt
#"server" is a x86 box on the other side of it.

#I am not huge on running flent as root, but...

L=60
RTTS="0 1 4 8 24 48"
RTT=8ms
QDISCS="cake_flowblind cake fq_codel pie bfifo_64k bfifo_256k pfifo_100 pfifo_1000"
BWS="20Mbit 100Mbit 200Mbit 10Mbit 2Mbit 1Mbit"
BW=20Mbit_5Mbit_cable
#QDISC="bfifo_1024k_256k_offloads=off"
QDISC="fq_codel_ce_threshold_1ms-noecn-vs-ecn"
# remote control of queue delay and qdisc omitted

#FLOWS="1 2 4 8 12 16 24"
#FLOWS="64 32 1 4 2 16"
FLOWS="2 16" # 2 16"

P="--test-parameter=qdisc_stats_hosts=root@delay --test-parameter=qdisc_stats_interfaces=ifb4enp4s0 "
M="--remote-metadata=root@delay --remote-metadata=root@server"

F1="flent -x -l $L $P $M --step-size=.05 --note=bw=$BW" # root can get a higher sampling rate

#CC="reno cubic bbr cdg"
CC="bbr cubic cdg reno"

T="sch_fq-$QDISC-bw=$BW-rtt=$RTT"

# You should not have to fiddle more here

for c in $CC
do
    modprobe tcp_$c
done

echo $CC > /proc/sys/net/ipv4/tcp_allowed_congestion_control

for ecn in noecn # noecn
do
case $ecn in 
	ecn) sysctl -w net.ipv4.tcp_ecn=1 ;;
	noecn) sysctl -w net.ipv4.tcp_ecn=0 ;;
esac

for c in $CC
do
echo $c > /proc/sys/net/ipv4/tcp_congestion_control

F="$F1 --note=rtt=$RTT --note=cc=$c --note=qdisc=$QDISC --note=ecn=$ecn"

# Test lots of flows

for i in $FLOWS
do
$F -H server --note=flows=$i -t "$T-flows=$i-$ecn-$c" --test-parameter=upload_streams=$i tcp_nup
$F -H server-ecn --note=flows=$i -t "$T-flows=$i-ecn-$c" --test-parameter=upload_streams=$i tcp_nup
done

#I actually have loads more tests than this but
$F -H server -t "$T-flows=$i-$ecn-$c" rrul_be
done

# Cubic_bbr comparison (not checked into flent yet), done twice just to be sure

$F -H server -H server-ecn -H server2 -H server2-ecn --note=flows=$i -t "$T-flows=$i-$ecn-$c" --test-parameter=upload_streams=$i rtt_fair_var_up

$F -H server -t "$T-noecn" --test-parameter=ping_hosts=172.22.64.1 cubic_bbr
$F -H server-ecn -t "$T-ecn" --test-parameter=ping_hosts=172.22.64.1 cubic_bbr
$F --step-size=.05 -d 3 -H server -t "$T-noecn" --test-parameter=ping_hosts=172.22.64.1 tcp_4up_squarewave
$F --step-size=.05 -d 3 -H server-ecn -t "$T-ecn" --test-parameter=ping_hosts=172.22.64.1 tcp_4up_squarewave

done

