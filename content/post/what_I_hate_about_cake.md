+++
date = "2016-08-28T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat" ]
title = "What I hate about cake"
description = ""
+++

# What I like about cake

## Ease of configuration

## Ease of re-configuration

Gargoyle wrote a very complicated and tied to HTB custom C program to dynamically adjust the bandwidth
based on external events.

Our fq_codel for wifi code relies on effective backpressure

Cross layer

## Per host/Per flow fair queuing

## Simpler framing

## The extensive statistics

## Tighter codel model

## GSO by default

increases the codel signal stength

congestion avoidance

## No packet limit

# What I hate about cake

As the most common application of the fq_codel algorithm was in QoS/SQM systems, and our big win
was from combining two algorithms traditionally done separately

It made a lot of sense to, and with that in hand, it was really straightforward to also combine that with an integrated shaper - saving a whole lot of indirection and two calls to time - the result of that was 40% faster than the equivalent htb + fq_codel implementation.

To me - that was good enough - we could have upstreamed that right then and there, and we would be done.  But then we ran afoul of 2nd system syndrome. Ideas we'd considered briefly and discarded during the heady days of creating fq_codel (like for example, 64 bit time, not using a sqrt cache or saturaing math), crept back in. It wasn't all bad - various alternatives to the basic codel algorithm were explored. Other ideas toward

good ideas, like per host/per 

The team grew larger, with different users desiring different things. One contingent wanted better statistics. Another,
ease of configuration. A third

And - as an all-volentueer project - progress periodically slowed to a halt. Clear roles were absent. As the instigator of the project, I felt strongly that I needed to take a hands-off attitude, provide a "safe space" for innovation and new ideas - and only rarely chimed in to attempt and provide direction. Sometimes the inner-team conflicts grew unpleasant - and as my own goal was so different (I wanted a faster inbound shaper)

Periodically I'd pop up, take a look at the state of things, rip out everything that I thought dubious,
test both, show that we had no tests to prove a difference, and wait for either a test that proved anything
or the feature to get ripped out.

Either rarely happened. What else would appear, what else was possible, if things kept going down this path?


We still need a faster inbound shaper, or policer.

## Attacking cake is easier

1000 flows. If you send 1000 flows at exactly the rate, marked with ecn, will starve out all other flows. That's not quite the case for fq_codel, where due to the possibility o

fq_codel, on the other hand won't fail, as we get hash collisions

fq_pie2

## Self regulation on syn/acks

Low rate attacks against modern AQM algorithms

## No ECN overload mechanism

** Repeat tests - ECN number of flows til it hits the memory limit and then what?

Staircase cdf

** Check fails to start

** Retransmits for flent

** RTOS for flent - we've long made a claim that we've nearly eliminated RTOs. Is it true?


** fq_codel, pie, fq_pie

## Speed

## AQM

##

## Blue

The *hope* is that blue will kick in against truly unresponsive flows but we have no objective evidence of such.

# Conclusion

In my mind, sch_cake is a waystop on the way to something even better, one day.

All the individual things I'd have ripped out,

Now we have an existence proof of an AQM that prefers ECN to drop until you run out of memory, what will happen?

That if you've got a queue of any length you aren't signalling agressively enough, 

Does the per host/per flow FQ actually scale?
