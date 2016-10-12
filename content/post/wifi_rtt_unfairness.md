+++
date = "2016-05-07T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat", "ath9k" ]
title = "RTT unfairness"
description = "RTT unfairness for longer paths"
+++

Has a large "WTF" component. Delivery rates to the second wifi hop is
wildly variable (but still within bounds, so that's good), and
bandwidth to it... is higher.

Usually on ethernet tests against fq_codel, we see some negative flow
unfairness start to arise at about 150ms differences, but here we are
jumping around at between 1 and 30ms, with the wifi second hop
outperforming the ethernet second hops! The baseline latency of the
path should be around 12ms (on average) when loaded, but...

I've been cutting flent's sampling interval to 50ms (--step-size=.05),
and that's still well above anything nyquist would recommend. We can
take apart actual packet captures at a finer level of detail using
wireshark and tsde.

The client is a uap-lite, running lede - with the ath10k driver being
pre-softirq fix, pre-airtime-fairness, no fq_codel, no powersave, the stack
running cubic...

That's probably part of it, but it's an example of how these things
might interact today, and a useful data point, for whenever more new
stuff lands for that chipset. I have a few other chipsets worth testing
against, but for now I'm going to ignore this and move onto finding out
how much bandwidth we're leaving on the floor.

