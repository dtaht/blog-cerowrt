+++
date = "2016-05-07T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat", "ath9k" ]
title = "Exploring wifi mcs rates with fq_codel"
description = ""
+++

We are trying to land a bunch of interrelated fixes for the ath9k portion
of the stack. We are trying to break the current, fixed relationship,
in wifi latency to the speed it is running at.

I don't really trust anyone elses test tools. I make enough mistakes using
flent to not trust me, and I spend a maddening amount of time trying to
figure out ways to test no more than two variables in isolation.

Some positives:

Comfortably above the lower limits where we've seen codel misbehave.

{{< figure src="">}}

Normally for me, I have a delay box. Here I have no delay configured, but the
"server" box is one ethernet hop further than the the delay box.

## Postive note #1 

Exhibits bounded latency

I'd really love to believe this result, but for all I know we're leaving potential bandwidth on the floor. The 3.6-6ms of latency induced at the higher rates
seems too small - although seeing bounded latency when some other traffic
enters the link, and it changing rapidly to adjust is a good sign:

{{< figure src="">}}

What can this particular box do? Are we seeing the change in tcp small queues,
or the softirq change? or is codel doing the right thing?

(Well, no. The box I had been using didn't survive the fire, when I set it up
again it looks like one antenna had got disconnected internally and I'll
have to rip it out of the stack)

I was fiddling with BBR - was that on? Nope. Ecn? Off.

## Steps forward

But! Performance is NOT being regulated by the fqbug anymore and for that
I'm grateful - all flows are pretty fair, there are no gaps, bandwidth is consistent.

* HT20 mode
*

Is there an interaction between codel? 
