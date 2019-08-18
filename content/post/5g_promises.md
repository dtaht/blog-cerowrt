+++
date = "2016-08-28T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat" ]
title = "5G's promises and potentials"
description = ""
+++

laboring in the dark, trying to bring in old, broken ideas that preserve existing business models.

TCP takes a few seconds to ramp  up.

so, which is the right number? the beguinning? the middle? the end? The average?

And this is usually shorter than any typical web transaction, which usually lasts less than 2 seconds.

Why do we see this particular behavior, 

treating udp and tcp equivalently. UDP is a very good test to see what the actual system capacity is, but 

and what you are actually testing is the system's abilility to discard packets efficiently. There 

As it turned out, that we did things gently, rather than 

Eric Dumazet came up with a very efficient - drastic - sort of patch -
to cope with this sort of overload condition effeciently, which
brought things back under control, but I missed - for years now,
something that would improve matters more regularly. One line of code
to bring codel's signal strength up.



how long does the test run for? One of the causes for the rise of bufferbloat in the world was the usage of speedtest.net's tuning - where the test ran for under 15 seconds, and thus people tuned their buffer sizes to never have a drop during that time.

to be sure that they optimized out any opp

The basic form of wifi testing that I most strongly desire is for a
family of four - one uploading a big file to youtube, another doing basic browsing, another in a videoconference, and the last playing a twitch game. 

That is the most common - you could add another one - bittorrent - but
bittorent itself is basically fading in predomance in favor of streaming.

But nobody's test tools do that - not even the ones we have. Another scenario worth optimizing

I'd love it if someone picked up their fancy new wifi AP and plunked it down in a nearby coffee shop, and observed what actually happened there. With 20 or 30 other radios present in a small apartment complex. Or took a look at behaviors in your typical office - I've been to both google's and comcast's HQs, and the wifi there is darn near unusable.

Would result in focusing more on what really

The UDP test IS valuable, you can

However hammering something with a gbit worth of traffic - you are basically testing the performance of the discard
path far more than the

there is never one flow - there are 15, with a baseline RTT measured in the 20-60ms range.

in this l

DSLK interleaving essentially doubles the baseline latency from 10 to 20ms (cable is roughly 8, fiber, about 2)
dsl is s a noisy technology, and a good reason to use interlaving is t

fill a hole for about 18ms.
this is pretty nice. we can do better than

short local rtts this pushes congestion control out into the internet and out fo the last 15 feet.

generally inperceptable. ECN going cost to coast - being able to surviv a congestion control signal
over a path that long is a goodness.

duration of this 30 second trace there were 8 loss events, which

which is enough time for a packet to exit the router, over ethernet, and come back,

think about it incorrectly - there are bunch of

you should just accrue stuff and figure out what to

for example, you can actually send packets bi-directionally within a txop.
You have to have packets ready to go, you

rate over range

where we could have a direct mapping of stations to dma areas, but nobody does that.

nearly every new access medium includes packet aggregation as part of how it transports packets. And use a UDP style test
to justify their design choices and shake their hads sadly at how inefficiently TCP actually fills those.

One of the best ways to improve TCP's performance is to have the shortest possible RTT. This helps it quickly
ramp up, or quickly ram down, in response to changing conditions.

publication of the dslreports speedtest, that the off-the-shelf test tools used by network hardware designers would
actually evolve to include tests for latency.

rather 

measuring the amount of sent, rather than recived data, in that interval.

Assigning equal weights to UDP traffic vs TCP traffic.
