+++
date = "2016-03-30T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat" ]
title = "Anomolies with network offloads"
description = "Packet processing at high speeds is hard with modern OSes"
+++

pcengines

## shaping starts dropping at the rx path

There are three sorts of anomolies

Dumps 64k into the network at Gigabit

IW10 windows

a patch arrived to make codel work better with "superpackets"

packet length 1000 - 64k to 1000k

0) Interactions with the scheduler
1) All the AQM
2) Bugs
3) Software GRO

The armada 6
Actually does this

4) Software GSO
5) TSO


6) TSO2 was proposed

shallow buffered switches

in [cake](/tags/cake), we gave up, and just started measuring packets in
bytes.


ECN has mass

and consistently on the high side. Take tcp_limit_output_bytes, PLEASE!

TSQ was originally set to 4096, it caused a regression on the current generation
of wifi drivers... so it got increased to 64k... then it caused a
regression on xen, which got the default bumped to 256k.
