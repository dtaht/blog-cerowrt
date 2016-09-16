+++
date = "2016-05-01T12:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat" ]
title = "Ripping out the reorder buffer"
description = "Most TCPs can recover from reordering. APs don't need to worry about it"
+++

I'd like to sit down to prove - once and for all - or not! - that once we had small, fq_codeled queues, having a reorder buffer in the AP or client
was a futile waste of energy for at least two OSes - Linux and OSX. That: Having a reorder buffer was a symptom of having overlarge queues in the first place.

The Linux [mac80211 stack does a metric ton of work to *not* reorder frames](http://lxr.free-electrons.com/source/net/mac80211/rx.c),
scheduling to clean up things on a jiffy timer, and... it's not needed. Or so I think.

In browsing through that file I also went looking for how or if QoSNoAck could work the way I wanted. :whew: What a nightmare of a read.

I expect a completely uphill battle on both of these fronts. There was a [long thread about it, in 2011, here](http://www.spinics.net/lists/linux-wireless/msg66013.html) worth reading. My interpretation, years later, was that the wifi stack was so overbuffered that TCP was misbehaving anyway, and that the reordering
would have cleared inside of 2 txops.

Enterprise APs tend to work better, because most don't bother to handle
reordering, and windows versions prior to 10 back off. It's an AQM of 
sorts!

And everybody else is happier - the weak station makes less demands on the
overall system.

I have looked at a lot of 802.11 packet captures since. You typically DO lose
a bunch of packets in a burst. Just like tail drop, no tool I know of
accurately captures this behavior of wifi.

## Bittorrent

## The effects of FQ

## TCP RATT

## Other means
