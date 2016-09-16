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

## Emulating the Internet, over ethernet

But it's still missing some things. You are emulating the internet, but
you are doing it over ethernet, which for local connectivity is dependent
on a few types of "ant" packets scurrying around to keep things working:
arp and ND.

## Real bottlenecks

Arrive at the bottleneck. This is the oft-used graph showing

Except that it's not drawn to scale. That burst came out at 10GigE, 
and is arriving at 10Mbits! It gets streeeched out - well, let's say
the thing is an inch wide on your screen - the actual size - it's 
now a thousand inches. 83 feet.

## RTTs really matter for control traffic

## 
