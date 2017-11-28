+++
date = "2017-11-28T18:02:58+01:00"
draft = false
tags = [ "bufferbloat", "tcp", "cake" ]
title = "Adding ack-filtering to cake"
description = "Ack-filtering might make the internet better"
+++

I'd never seen what the potential benefit was of doing ack-filtering,
particularly on interfaces with really poor (50x1) Download/upload ratios, until
now.

A few months back Google asked me to add new features to netem. The first of
those has already landed, with a primitive "slotting" feature that is intended
to emulate the kind of behaviors bursty macs (like wifi, lte, and cable)
actually have.

Next up after that was to add ack-filtering based impairments to netem. I don't
want to go into how TCP ACKs work today. What they provide is a continuous
"clock" to the TCP sender with the sum number of packets received so far, and
indicators such as SACK to indicate what packets need to be retransmited, and a
whole lot more. The important thing to note is that the default mechanism (one
small ACK packet per two TCP packets) is very robust, and can tolerate a lot of
loss.

It was really hard to come up with possible ways of doing it wrong without first
trying to come up with an ack-filter that did it entirely right. Available
models for such on the web (such as wondershaper's) were horribly broken. We
explored the solution space for a month, with a close reading of the relevant
RFCs, and a reluctance to "break the internet" by even trying.

I kvetched about this to the cake mailing list, and Ryan Mounce showed up a few
weeks later with a pretty decent ack-filter that covered all the corner cases we
were aware of, and we wedged two variants into our mondo fq_codeld, shaped,
(cake)[https://www.bufferbloat.net/projects/codel/wiki/CakeTechnical/] code for
testing.

There are *many* compelling arguments against putting ack-filtering into your
home router: It makes TCP run better at the expense of other protocols, like
QUIC. It cannot help VPN traffic, either. It can trigger hidden bugs in TCP's
ack processing. And worst of all, a bad filter might cause TCP weirdness.

But TCP commands well over 90% of traffic, and there are tons of (mostly bad)
ack filters in the field, and Dave Reed mentioned that he had a real, live link
with a 1Gbit/20Mbit link, so I set up an emulated link like that via netns, with
100ms round trip delay to see what would happen.

Using the rrul_be test (which starts 4 upload and 4 download streams):

{{% figure src="/flent/ack_filter/1Gbit-20Mbit-rrul_be.png" %}}

Wow. At T+10 we get twice the upload throughput of the non-ack-filtered case, and
Download throughput is 20-60% better.

At T+30 upload throughput falls to only 50% more than before, (don't know why, I
think it might be due to cake's "sparse flow optimization" on the now thinned
ack flows not queuing more acks to be filtered) - but at T+30 we are getting
twice the download throughput than the unfiltered stream! 791Mbit vs 410Mbits!

The long time it takes for this to ramp is due to the long (100ms) RTT. Also
the long, slow ramp of the download is due to the codel congestion control
algorithm starting to drop acks itself.

At some point, after this settles, I have to get back to adding all the possible
impairments to netem. I think they may be more useful than I thought!

flent data is (here)[/flent/ack_filter].

