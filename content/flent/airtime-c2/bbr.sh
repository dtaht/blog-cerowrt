F="flent -x -l 30 --step-size=.05"
#S1="-H 172.22.148.3 -H 172.22.64.1"
#S="-H 172.22.254.25 -H 172.22.192.1 $S1"
S1="-H server -H delay"

S="$S1 $S1"

for e in noecn
do
T="ap-from-linux-cubic-and-linux-bbr-mcs-$r-$e"
#$F $S -t "$T-up" rtt_fair_up
$F $S -t "$T-down" --swap-up-down tcp_4up_squarewave
done
#$F $S -t $T rtt_fair4be
#$F $S -t $T rtt_fair
