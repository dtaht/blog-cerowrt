+++
date = "2016-03-30T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat"  ]
title = "Full Airtime Fairness"
description = "We *can* scale wifi to more stations"
+++

The fundamental unit of a wifi transaction is a TXOP - a transmission
opportunity. Getting one is arbitrated by a complex process based
(usually) on something called the EDCA scheduler.

Strict Round robin, although an enormous improvement over merely taking
packets in random order, still has problems.

Starve the beast

The codel algorthm only needs to run once per *flow* within a given txop. As a txop cannot be smaller than 
a RTT.

If it is going to drop more than that it is acting to reduce the backlog rather than to act
It's a packing problem.

# Aggregation is a packing problem,, not a FQ problem..

So identify all flows that should be dropping

pack the flows that are not dropping into one aggregate.
pack the flows that could drop into another (and do a QoSNOack)
put the last packet of the dropping flows into the last aggregate.
Wait for replies

