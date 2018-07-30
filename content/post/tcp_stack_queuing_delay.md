+++
date = "2018-07-25T18:02:58+01:00"
draft = true
tags = [ "bufferbloat", "flent", "rants" ]
title = "Running sch_cake at line rate"
description = "Let packets be packets!"
+++

sch_fq. 

is dicy

enter cake. splitting gso 

The local switch, which has, as far as I can tell, about 1.5ms of buffering
in it.

But I'm not here to gripe about that.

GRO/GSO etc all exist

Still losing packets in the switch, in addition to ecn marking locally.

You can see the observed RTT here:

Wait, we can do better. Let's set cake to the "metro" setting
which tunes up codel to use a target of 500us and an interval of about

70k. The typical rtt. This is 20x less local buffering and the tcp
stack observes X as the rtt.

And packet marking became high I'd reduce the MSS. This is something 
bittorrent used to do to keep the signal strength high. 

every application is entitled to one packet in the network - John Nagle

shedding load sanely

gain is too high

RFC

have 200 flows, the internal RTT doubles

self-congest

Even all that ecn marking is not enough. The switch is still dropping packets

