+++
date = "2016-08-28T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat" ]
title = "Oldest active queue first"
description = "Doing per station scheduling"
+++

#

Optimizing for wifi aggregation in an AP's scheduler I have seen
nearly no literature on the best ways to pack an aggregate. The WiFi
MAC is notoriously known to be inefficient with widely quoted
inefficiences of 90%. While the ongoing work on on fq_codel, airtime
fairness, and other driver-level optimizations contiues, these
inefficiencies dog wifi.

There remains - 10 years after the introduction of wireless-n and
wireless-ac, plenty of room for innovation.

But what about per station scheduling?

# Oldest Queue First

Both these queueing methods anticipate an infinate queue of arrivals
for each station, and in the real world, that is not the case. In the
case of TCP, a fixed number of packets will arrive at some rate,
and then stop, awaiting an acknowledgement. Videoconferencing will
typically bunch of 10 or more packets and then stop, for 16ms, at
60hz frame rate. GSO/TSO can accumulate 64K worth of packets, GRO,
24K. 

Now, this is essentially how older FQ methods such as SFQ and DRR
operate. Each new flow is queued to the tail of the list, and each
flow has a single (SFQ) or a quantum's worth of packets delivered per
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
inhernet downstream latency of 2ms and upstream of about 6ms
(depending). We'd worked hard on two promising techniques for making
wifi behave better, only to abandon them, when we realized that the
core problem was too much buffering in the driver itself.

bound by the number of packets that can be formed in the aggregate. An
aggregate consisting of 20 TCP acks takes essentially no more time
than one with a single one, and yet

It makes no sense to continue to defer scheduling a station if the known
aggregation limit (bytes or packets) is exceeded, so,

# Oldest Active Queue First

Has one fatal flaw - if the total service time for all stations
exceeds the sparse packet interval, then that station goes to the back
of the list. Delivering 42 voip packets all in a bunch would be very
bad.

While, in practice, if you have that many stations, you are fucked
anyway, moderating the imact of optimizing for aggregation in favor of
more airtime fairness is desirable.

So we can break up the time based scheduler into new/old concept, just like
fq_codel.

Softens the impact of the existing fq_codel new/old queue distinction,
while improving the potential aggregation opportunities.

# On patents, corporate and academia

I've been sitting on this idea now, for nearly 4 years. Only recently
have the tools arrived to be able explore wifi in adaquate simulation,
or in the real world on the ath9k hardware. Were I an academic, I'd
have gone and written a paper (and depending on the institution, filed
a patent). Were I in corporate america, that patent would have
happened, and then watch the idea die.

I could, if I wanted this idea to fall directly into the public domain
have written that paper, published it and the code in some dead-tree
publication (after waiting a year for it to be published)

There are other things that can be more effective in improving wifi
that can take place beforehand.

Increased BER, retries
