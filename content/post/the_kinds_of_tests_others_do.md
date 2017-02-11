+++
date = "2016-10-11T18:02:58+01:00"
draft = true
tags = [ "bufferbloat", "benchmarks" ]
title = "The kinds of tests others do"
description = "I really should do more of these"
author = "Dave Taht & Aaron Wood"
+++

There are some common network tests that I don't do as often as I
should, because I'm mostly interested in what happens in the big bad
ugly, real, world, for some value of "real". The common tests
that I'm going to talk about today all have problems of their own.

* small, medium, big packets test
* iperf udp tests
* videoconferencing tests

## The small packet problem (PPS)

Recently a new tester put htb+fq_codel [through the wringer](http://community.ubnt.com/t5/EdgeMAX/Cake-compiled-for-the-EdgeRouter-devices/td-p/1679844/page/2) using
tcp at various packet sizes on the edgerouter:

````
Packet size (MSS)	1460 bytes	512 bytes	64 bytes
QoS'ed throughput	541 Mbit/s	183 Mbit/s	19.7 Mbit/s
CPU utilisation		    93-99%	86-92%		88-93%
````

Fidding with the MSS size is good, but that last result was pretty
horrible. It's horrible because you can't fit much data into 64 bytes,
in part - we aren't measuring the actual bandwidth used here, but the
ratio between payload and packet! What was the PPS?

## The PPS problem

The small packet problem is a big one. One solution on the host side
has been "GRO" - generic receive offload - where the driver or nic
attempts to bunch up all packets on the same tuple and diver that as a
"superpacket" to the rest of the stack - where it can be all handled
in a bunch in userspace for an application, or

But - GRO only works in single threaded tests and is nearly useless
elsewhere. (One side effect of fq_codel, though, is at the common
quantums (300, 1514) there is a small bunching of acks that you can
see on a trace, which might make for better GRO usage on the other
side of the link.)

Still, what happened was - on devices like the armada 385 and
edgerouter - they added software GRO - in a form that can hit 64k on
any kind of packet so long as the tuple is shared - and that first
impulse of IW10 at 1Gbit HURTS if you want to ship it out at
1Mbit. That's 130ms of induced latency from ONE TCP flow at that
speed.

We saw that, and fixed it in [cake](fixme), and TBF, and there have
been other attempts at moderating GRO's impact elsewhere in the stack.

Nowadays GRO is everywhere and I now flat out disbelieve all modern
industry benchmarks of packet forwarding rates for small packets. If
you could show me a PPS test that didn't make GRO kick in - one that
ships packets on hundreds of different tuples - that I'd believe
in. Got one?

Side note: I've increasingly advocated for smaller MSS sizes at speeds
below 10Mbits. Bittorrent used to do it. I wish it still did. I wish
WAY more things did. IW2 + 584 byte MTUs works so much better on slow
links.

## Videoconferencing

Videconferencing over the internet is heavily in flux and hard to test against.

[fixme](fixme) congestion control paper
Which was otherwise a very good paper - limited itself to a range of 1-2Mbits.
I got a beef:

It's merely better because they were willing to accept 300ms of latency
at 2mbits, and that's not my target. SFQ - with the default 127 packets -
is at one mbit, 165ms latency to a flow that wants to eat it.

...

In my world, I'd always have voice and video on a different tuple -
this gives you a useful clock to measure delays within a RTT, when
working against a fq'd system. At least in webrtc videoconferencing
systems today, we see it all on one tuple - one good reason for it is
that port space is not cheap - punching a reliable hole through a
firewall costs - and another is that having it all as one flow
simplifies the processing somewhat. I keep hoping for someone to try
the dual clocking idea against a fq'd system, but so far, no luck.

I'd also really like to see ecn tried, especially on the Iframe.

## UDP flooding

Recently Aaron Wood [posted two great articles on iperf3](http://burntchrome.blogspot.com/2016/09/iperf3-and-microbursts.html)'s udp burst behaviors under
OSX were "broken", in that they injected a huge flood of packets every 100ms in order to achieve the desired "rate" of the test. At 50 mbits - he got 8mbits from that udp flood, where TCP was happly using all 50Mbits.

{{< figure src="https://3.bp.blogspot.com/-fSwmDFWdS-U/V-GjSSNWwnI/AAAAAAAAdXI/S-tZNgN7u44OjypS52EjYqAU-hb8vpEEgCLcB/s1600/iperf3_microbursts_100ms.png" title="Millabursts, not microbursts!">}}

He fixed the osx code to pace the packets at 1ms, rather than 100ms,
intervals, to get the desired bandwidth measurement, and is keeping
the patches [here](https://github.com/woody77/iperf/tree/pacing_timer). I suspect the same problem exists on windows as well.

{{< figure src="https://3.bp.blogspot.com/-zRBp_39g7lY/V-GqvRO2OQI/AAAAAAAAdXs/IW4LWvr0QlQhb9OAQwGkfBYMzukWzrwPQCLcB/s640/iperf3_microbursts_100ms_vs_1ms.png">}}

He later on, improved that still further.

His conclusion was (please read the article!):

"Know what your tools actually do.  Especially in networking where rate limiting is really an exercise in pulse-width modulation."

BUT: Iperf's behavior - before this was fixed - *was a perfectly valid
test* - it just wasn't testing what the users were expecting.  Fixing
what happens when you inject bursts like that into the network is
exactly what all the work to improve shallow buffer performance in
[bbr](/tags/bbr) and in so much else of the network stack has been all about!

Now there's a whole generation of iperf-on-osx tests that I can safely
ignore, and an issue I can raise any time someone points to a iperf
udp result as "bad". Assuming the upstream default changes to the new
code you can see what used to happen via "--max-pacing-rate 100". If
it doesn't change upstream, well, use --max-pacing-rate 1000 and
document what setting you used in your next paper!

UDP floods - used carefully - are a pretty decent way to determine the
one way bandwidth of a link, but in order to get something accurate, it
needs to be well-paced, and respond to loss intelligently.

There's another problem with udp flooding in general, in that if you push
1gbit into a 100mbit path, what you end up testing is the speed at which
your OS can throw away packets, more than the "normal" behavior of the card
and driver itself.

Again: this is a totally valid test - in today's DDOS soaked internet
you DO need to throw away packets a lot.

... but it's not normal behavior, and it is worth optimizing for, so long as you conceptualize it separately.

All sorts of work is going into throwing away packets sooner.

I'm going to save the rant on how to measure tcp properly to another
day.
