+++
date = "2016-09-18T12:02:58+01:00"
draft = true
tags = [ "bufferbloat", "tcp", "bbr" ]
title = "TCP BBR verses ECN"
description = "What is the right response to explicit congestion notification?"
+++

Does Google's [new TCP BBR congestion controller](https://patchwork.ozlabs.org/patch/671069/) solve bufferbloat?


So I setup an internet emulation (0 and 48ms RTTs), at 20Mbits,
to take a look, using the sqm-scripts (htb + fq_codel), for the rate
management on one interface, and netem (for delay) on the other on the
middlebox.

<pre>
server 1Gbit running cdg/cubic/reno/bbr with sch_fq on its interfaces
     |
  enp3s0 w/netem 24 ms each way
delay box
  enp4s0 w/sqm-scripts 20mbit both ways
     |
client 1Gbit with fq_codel, cubic
</pre>

##

{{< figure src="/flent/bbr-comprehensive/bbr_ecn_eventually_starving_ping.png" >}}

## Self congestion

Flent's testing scheme [is flawed](/post/flaws_in_flent) in that normal tcp
users don't open this many connections at the same time to the same server. We
do it that way... and prior to BBR's arrival it wasn't a problem - natural
randomness in the aqm drop and tcp backoff algorithms gave us what generally
appeared to be out of phase behavior in most cases (I know of one major
exception to this but I've [never finished writing it up](/post/sprong)-
basically fq'd systems are always trying to provide equal service to all
flows, constantly pushing them towards parity. When they actually achieve
parity, things can go "sprong" - in ways you might not expect).

Similarly, the synchronized slow start has always been a problem but we
haven't paid much attention to it.

FQ has a good property in that the baseline RTT is available for all flows - in fact, it's an integral concept in fq_codel called the sparse flow optimization, and it's brought out even more in cake, which does "perfect" fq.
fair share between routed and locally served packets.


Except if you are gathering your initial RTT samples while everybody is in slow start?

Stay in phase.

There are three ways to fix this:

0) Live with it. In the real world, flows have natural pauses to them when
there's a server lookup, a disk seek, etc, etc. Honestly, I can live with 
that version!

1) have BBR randomly set it's initial RTT probe start phase to something
between 2 and 12 seconds - rather than "10". In the context of BBR's
deployment that doesn't seem necessary -

2) Change these flent tests to stagger starts. This is *hell* on the math and
statistics collection parts of flent, it would break our database of 100s of
thousands of tests, and let's not go there, ok?

3) Use a different flent test. Flent actually has several tests designed to
look at things like [the latecomer problem](fixme), with staggered start built
in - we don't use them as much as we should, but they are:

* tcp_up_square
* tcp_2up_delay

So in a future test series I'll toss those in. What can we figure out from what we
got?

Another good source of test tools is the TEACUP testbed, which also has a similar
phased test. One of their analysis papers that used that well, [is here](fixme)

* Doesn't respond to ECN marks as it should

It doesn't.

Dropping the MSS and increasing the rate would have a beneficial
effect on - it would induce tail loss on packet limited fifos - as described here

I quickly ran the [flent](https://flent.org) tcp_upload test, once for

Did it behave better when faced with cubic?

I am painfully aware that work on a middelbox soltuion
