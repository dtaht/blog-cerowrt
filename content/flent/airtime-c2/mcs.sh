F="flent -x -l 30 --step-size=.05"
#S1="-H 172.22.148.3 -H 172.22.64.1"
#S="-H 172.22.254.25 -H 172.22.192.1 $S1"
S1="-H delay -H server"

S="$S1 $S1"

for r in `seq 0 15`
do
ssh root@nemesis "iw dev wlp3s0 set bitrates ht-mcs-5 $r"
for e in noecn
do
T="ap-from-linux-bbr-and-linux-bbr-mcs-$r-$e"
#$F $S -t "$T-up" rtt_fair_up
$F $S -t "$T-down" --swap-up-down rtt_fair_up
done
#$F $S -t $T rtt_fair4be
#$F $S -t $T rtt_fair
done
ssh root@nemesis "iw dev wlp3s0 set bitrates"
