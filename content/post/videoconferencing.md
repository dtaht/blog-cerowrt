+++
date = "2016-03-30T18:02:58+01:00"
draft = true
tags = [ "cake", "bufferbloat" ]
title = "Videoconferencing"
description = ""
+++

Modern cameras behave differently - so what you get is a burst of 10
or so packets dumped into the network, all at once, spaced over the
total number of flows in the system.

This is a totally OK strategy for a wifi device.

But if you really want low latency videoconferencing, it would be better
to revert back to an old system - scan lines.

in blocks

ecn


variable bitrate


LOLA project
Single Queue AQM's (red,pie)use randomness to spread out

A flaw of most of the FQ liturature is that for expositional purposes

cake is the first thing I know of

fq-pie also

But it sucks if that person colliding is you

We're not even sure it is a problem - we achieve such low latency for
other applications.

Greedy vs non-greedy

pay no attention to congestion control at all - they just slam the
network
at a given rate and hope for the best.

If I had the time I would make two simple changes to your typical
videoconferencing system -

I'd mark the iframe as ecn capable - this is the most important frame
and losing any packets in it tends to create visible artifacts,
sometimes for seconds.

The second thing I'd do would be to put the voice and video on separate
tuples and measure the difference in arrival rates between the two
flows. FQ_Codel essentially provides a clock that can be used to measure
the amount of congestion on the link, and we could thus more rapidly
increase (or decrease) the frame rate until we start observing more
delay and loss than we can tolerate.

Note the usage of a second flow for voice

It makes lip sync *way* easier for example.

Another way to do it would be to have a third flow for the "clock"

see rrul_50_down with no offloads

dominated by tests done at very low bitrates.
