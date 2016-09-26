#!/bin/sh
#root@delay is my delay box which also runs fq_codel and cake (sqm-scripts)
#and is presently setup to emulate a 20Mbit connection and a 48ms rtt
#"$S" is a x86 box on the other side of it.

#I am not huge on running flent as root, but...

S=bbr-west-cloud
L=300
RTTS="0 1 4 8 24 48"
RTT=11ms
QDISCS="cake_flowblind cake fq_codel pie bfifo_64k bfifo_256k pfifo_100 pfifo_1000"
BWS="20Mbit 100Mbit 200Mbit 10Mbit 2Mbit 1Mbit"
BW=100Mbit_18Mbit
#QDISC="bfifo_1024k_256k_offloads=off"
QDISC="fq_codel_apu_cablemodem-long"
# remote control of queue delay and qdisc omitted

#FLOWS="1 2 4 8 12 16 24"
#FLOWS="64 32 1 4 2 16"
FLOWS="2 16 1" # 2 16"

P="--test-parameter=qdisc_stats_hosts=root@delay --test-parameter=qdisc_stats_interfaces=ifb4enp4s0 "
M="--remote-metadata=root@delay"

F1="flent -x -l $L $P $M --step-size=.05 --note=bw=$BW" # root can get a higher sampling rate

#CC="reno cubic bbr cdg"
CC="cubic"
#cubic cdg reno"

T="sch_fq-$QDISC-bw=$BW-rtt=$RTT"

# You should not have to fiddle more here

for c in $CC
do
    modprobe tcp_$c
done

echo $CC > /proc/sys/net/ipv4/tcp_allowed_congestion_control

for ecn in ecn noecn
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
$F -H $S --note=flows=$i -t "$T-flows=$i-$ecn-$c" --test-parameter=upload_streams=$i tcp_nup
$F -H $S --note=flows=$i -t "$T-flows=$i-$ecn-$c" --test-parameter=download_streams=$i tcp_ndown
#$F -H $S-ecn --note=flows=$i -t "$T-flows=$i-ecn-$c" --test-parameter=upload_streams=$i tcp_nup
done

#I actually have loads more tests than this but
$F -H $S -t "$T-flows=$i-$ecn-$c" rrul_be
$F -H $S -t "$T-flows=$i-$ecn-$c" rrul
done

# Cubic_bbr comparison (not checked into flent yet), done twice just to be sure

#$F -H $S -H $S-ecn -H $S2 -H $S2-ecn --note=flows=$i -t "$T-flows=$i-$ecn-$c" --test-parameter=upload_streams=$i rtt_fair_var_up

$F -H $S -t "$T-$ecn" --test-parameter=ping_hosts=$S cubic_bbr
#$F -H $S-ecn -t "$T-ecn" --test-parameter=ping_hosts=172.22.64.1 cubic_bbr
$F --step-size=.05 -d 3 -H $S -t "$T-$ecn" --test-parameter=ping_hosts=$S tcp_4up_squarewave
#$F --step-size=.05 -d 3 -H $S-ecn -t "$T-ecn" --test-parameter=ping_hosts=172.22.64.1 tcp_4up_squarewave

done

