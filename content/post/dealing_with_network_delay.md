+++
date = "2016-04-02T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat", "ath10k" ]
title = "Dealing with delay"
description = "Too many people - including me - don't test with real-world delays"
+++

Once upon a time, a magnificent new network product was developed. It
looked great in the lab - very exciting inhouse demos - and in the culture
of secrecy that existed inside that particular company - no code left the
the building. 3 days before the announcement, the executives were allowed
to take it home to play with... and it didn't work!! - at all - at real world
RTTs and bandwidths.

Getting that right is *hard*.

EE's have a particularly hard time with this. Their response to an operation
that takes longer than a clock cycle is to make stuff smaller. This works
so long as you've got nanometers to deal with, but as things gradually grew
from meters to miles, and to cross-continental distances, real world RTTs
intrude. 

I would love it, honestly, if a class on queue theory was required for the
EEs of the world. They could start with the problem of distriubuted clocks
on a chip, grow to asynchronus chip design (a long neglected area), then
scale up to, at least, inches, then data centers, and then - the world!

It's not fair for me to pick on EEs. Nearly everybody gets even the most
basic of queue theory wrong. It's not helpful that the field has it's
own notation, it's own language, and sits off in the side of so many
things.

Algorithms to live by.

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
