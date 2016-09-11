+++
date = "2016-09-11T12:02:58+01:00"
draft = false
tags = [ "ath9k", "wifi", "bufferbloat" ]
title = "Oldest Active Queue First"
description = "Optimizing for wifi aggregation in an AP's scheduler..."
+++

I have seen nearly no literature on the best ways to pack an aggregate. The WiFi MAC is notoriously known to be inefficient with widely quoted inefficiencies of 90%. While the ongoing work on on fq_codel, airtime fairness, and other driver-level optimizations continues - we already have really massive improvements in airtime usage! - these inefficiencies dog wifi. There remains - 10 years after the introduction of wireless-n and wireless-ac, plenty of room for innovation.

Our early attempts at eliminating the excess latency in the ath9k driver have succeeded:

* we are exhibiting flat latency at a variety of rates.

* with per station queuing we've dramatically improved bandwidth and aggregation

* with airtime fairness we are servicing more stations, with less latency

* Some benchmarks have shown enormous improvements in airtime efficiency

So in the middle range - the sweet spot - what normal users would care about - we're winning, big time.

Our problems have moved to the very low end (very low rates vs aqm),
and high end (very high rates vs CPU scheduling), and also waxing
philosophical about how much service something should get.

There are so many variables! As for per station queuing - 
We're using an [airtime fair scheduler](https://blog.tohojo.dk/2016/06/fixing-the-wifi-performance-anomaly-on-ath9k.html) derived from the "fq" part of "fq_codel". Newer stations get a bit of a boost. Perhaps that boost is too much.

Can we do better there?

## Oldest Fair Queue First

Most queuing methods anticipate an infinite queue of arrivals
for each station, and in the real world, that is not the case. In the
case of TCP, a fixed number of packets will arrive at some rate,
and then stop, awaiting an acknowledgment. Videoconferencing will
typically bunch of 10 or more packets and then stop, for 16ms, at
60hz frame rate. GSO/TSO can accumulate 64K worth of packets, GRO,
24K. 

Now, this is essentially how older FQ methods such as SFQ and DRR
operate. Each new flow is queued to the tail of the list, and each
flow has a single (SFQ) or a quantum's worth (DRR) of packets delivered per
round.

Newer FQ methods (QFQ, SQF, DRR++, fq_codel), attempt to give some
priority to new flows entering the system. This pushes new flows to
faster parity with older ones, drives applications to respond to short
flows earlier, and overall gave a 25% boost in network performance over
straight AQM methods in mixed traffic.

BUT: These techniques were pioneered on switched ethernet, which is a
full-duplex medium, with a minimum media access time measured in usec
(or nsec in the case of 10Gbit ethernet).

The next set of major tests was on cable modems, which have an
inherent downstream latency of 2ms and upstream of about 6ms
(depending on other factors).

We'd worked hard on two promising techniques for making wifi behave
better, only to abandon them, when we realized that the core problem
was too much buffering in the driver itself. OK, we've fixed that.
We've induced not enough latency. 

Here, we are adapting the techniques to apply to whole stations, not
flows.

WiFi framing overhead *costs* and station selection induces LARGE
random delays and jitter, much larger and more apparent now that we
just eliminated excessive buffering from the driver itself, and
started using airtime more efficiently than before.

A TXOP is bound by the number of packets that can be formed in the
aggregate. An aggregate consisting of 20 TCP acks takes nearly no more
time to transmit than one with a single one, and yet that txop
overhead is largely unaccounted for - the goal in that part of the code
is to fill 4ms of airtime. (elsewhere I've argued it should aim for
less airtime as more stations need service. And you only need the last
ack, not 20)

Getting a TXOP is a matter for the scheduler - but is also arbitrated by
trying to access the media. No matter if you have one packet or a dozen,
once you are in there fighting for access, you'll get a slot - eventually.

## How can we fill the available TXOPs better?

So I've long had two ideas for doing aggregation and wifi fairness better
that maybe we'll explore. What we got already *is pretty darn good*, but
I project a nearly infinite number of attempts to get this more right,
by lots of folk, eventually.

# Oldest Active Queue First

The fq bit in fq_codel has one flaw - if the total service time for all stations
exceeds the sparse packet interval, then that station goes to the back
of the list. Delivering 42 voip packets all in a bunch would be very
bad.

While, in practice, if you have that many stations, you are screwed
anyway, moderating the impact of optimizing for aggregation in favor of
more airtime fairness is desirable.

And packets tend to arrive in bursts, as hard as we've tried to break that
up with fq. And those bursts *end*, eventually, in most cases.

Why not wait til you've accumulated more of that burst, if you are already
congested the media? And schedule those first that have (apparently) "ended"?

We can break up the airtime based scheduler into new/old concept, just
like fq_codel, but schedule stations per the queue with the least
recent active arrivals (it's stale), and still schedule the others
otherwise normally.

So the new/old distinction becomes "stale/less stale". We still try to
service each station per "round" (to eliminate starvation), and we
still have to basically feed a station when we've got close to our
ideal aggregation limit, but that's otherwise it.

This softens the impact of the existing fq_codel new/old queue
distinction, while improving the potential aggregation opportunities,
while possibly improving "needed" service times - while costing some
latency for short transactions to "new" stations.

## Packet Pair scheduler

This idea I meant to patent, long ago, because I think it's genuinely
unique. ENOTIME (and lest you think I've got greedy, I'd assign the
patent to oin)... but I'll only write up a brief description of it here.

You can determine from the ratio of packets in to packets out, to 
make a prediction for when you "have enough" to keep the flow going.

I like it a lot, because it's a lot closer to an ideal fluid model,
and there IS some stuff in the lit (flowlets) that comes
close to describing it. But although I've got most of it written 
down, the opportunity to go and implement it hasn't arisen yet - 

and frankly we still have other problems elsewhere to deal with.

## On patents, corporate and academia

I've been sitting on these ideas now, for nearly 4 years. Only recently
have the tools arrived to be able explore wifi in adaquate simulation,
or in the real world on the ath9k hardware. Were I an academic, I'd
have gone and written a paper (and depending on the institution, filed
a patent). Were I in corporate america, that patent would have
happened, and then I'd watch the idea die without adequate testing,
or means to deploy a product based on it, and looked gloomily at
that plaque on the wall...

I could, if I wanted this idea to fall directly into the public domain
have written that paper, published it and the code in some dead-tree
publication (after waiting a year for it to be published). I have
some hope that with git and archive.org being more widely accepted 
as sources of prior art, that I'll avoid patent problems in the future.

And it's only a couple lines of code, and the only way to figure out
if they work or not is to try it out.

# Conclusion

There are other things that can be more effective in improving wifi
that can take place, notably in the minstrel rate controller, and limiting
retries. AND: getting a version of codel that scales properly - is partially
impacted by the scheduler, but also by the simplex nature of wifi,
and THAT's become a major headache.

