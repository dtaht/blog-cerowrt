+++
date = "2016-04-02T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat", "ath10k" ]
title = "Dealing with delay"
description = "Too many people - including me - don't test with real-world delays"
+++

Getting that right is *hard*.

I am presently using 

This is a simple script that gets the basics more or less right:

<pre>
#!/bin/sh
DELAY=24ms # Delay in each direction (e.g. 48ms)
ext=enp3s0 # ethernet interface
ext_ingress=ifbenp3s0 # inbound redirector

modprobe ifb
modprobe act_mirred

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
tc filter add dev $ext parent ffff: protocol all u32 match u32 0 0 action mirred
 egress redirect dev $ext_ingress
</pre>

But it's still missing some things. You are emulating 


