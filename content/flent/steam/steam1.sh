#!/bin/sh

# Yet another quick and dirty shell script to abuse a network

F=1
H=`hostname`
D=.bufferbloat.net
T="$H-Flows=$F-ac-dual-one-cake-dual-srchost-dual-dsthost"
#SITES="fremont dallas tokyo newark london atlanta"
SITES="fremont" #dallas tokyo newark london atlanta
#S="-l 120 --te=qdisc_stats_hosts=root@172.26.16.1,root@172.26.64.1 --te=qdisc_stats_interfaces=eth0,eth0"
S="-l 120 --te=qdisc_stats_hosts=root@172.26.64.1 --te=qdisc_stats_interfaces=eth0"

for i in 1
do
for d in $SITES
do
S="$S -H flent-${d}$D"
done
done

#flent -6 -t ipv6-$T $S rtt_fair_var_up
#sleep 20
#flent -6 -t ipv6-$T $S rtt_fair_var_down
#sleep 20
flent -4 -t ipv4-$T $S rtt_fair_var_down
sleep 20
flent -4 -t ipv4-$T $S rtt_fair_var_up
sleep 20

