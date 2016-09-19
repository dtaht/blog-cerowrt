#!/bin/sh
# Simple netem script that gets delay correct on an
# interface symmetrically
# we *don't trust* netem to set a rate. Use htb + something on another
# interface entirely to set a rate. Also note that the limit is large,
# but arbitrarily so. Always check to see if netem dropped anything on
# longer RTT tests.

DELAY=24ms

modprobe ifb
modprobe act_mirred
ext=enp3s0
ext_ingress=ifbenp3s0

tc qdisc del dev $ext root
tc qdisc del dev $ext ingress
tc qdisc del dev $ext_ingress root
tc qdisc del dev $ext_ingress ingress

ip link add $ext_ingress type ifb
tc qdisc add dev $ext root netem delay $DELAY limit 10000
tc qdisc add dev $ext handle ffff: ingress
ifconfig $ext_ingress up
tc qdisc add dev $ext_ingress root netem delay $DELAY limit 10000
# Forward all ingress traffic to the IFB device
tc filter add dev $ext parent ffff: protocol all u32 match u32 0 0 action mirred egress redirect dev $ext_ingress

