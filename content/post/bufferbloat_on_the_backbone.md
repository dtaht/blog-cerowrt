+++
date = "2017-11-12T08:02:58+01:00"
draft = false
tags = [ "bufferbloat", "backbone" ]
title = "Bufferbloat on the Internet backbone"
description = "Excessive queuing delay IS everywhere"
+++

On November 6th, the Net
experienced
[90 minutes of bgp outage](https://dyn.com/blog/widespread-impact-caused-by-level-3-bgp-route-leak/),
caused by a misconfiguration of BGP at Level3.

It's not every day you can blame the Internet for how bad your network is
behaving. As this outage happened I had a videoconference scheduled with some
folk in London and South africa. The frame rates dropped to 1 every 5
seconds for one participant with really terrible audio quality for all.

Just prior to the call, I'd lost connectivity to nearly all my servers in
the [flent cloud](https://www.flent.org), and I'd gone nuts determining if my
network was ok, (rebooting everything on my local path) and having narrowed it
down to something outside of the comcast network, I gave up, and just did the call.

I was afraid at the time, that the callers present would think me a charlatan
for claiming the internet was busted, and not my code!

The most disturbing thing about my tests was:

*Uploads* were fine, I got my normal 10Mbit.
*Downloads* went to hell - I got speeds in the few "k" per second on links capable of 200Mbit.

Take a look at the baseline and spike of RTTs through Level3:

{{< figure src="https://dyn.com/wp-content/uploads/2017/11/measurements_to_comcast-2.png" >}}

Median RTT latencies jumped by 30ms, which in part was how this outage was
noticed.  Not only that - look at the outliers on the second graph - distinct
spots at this resolution where even the lowest latency baseline link experiences
500ms or more delay, even when not loaded.

[Dave Reed](https://en.wikipedia.org/wiki/David_P._Reed) writes:

````

While the whole Internet was under excessive load, the latency could have
been reduced substantially if the proper signals were getting through to TCP
endpoints, resulting in better sharing of the overload capacity, without adding
such huge queueing delay.

I happened to be active on the Internet during those 90 minutes, and measured a
lot of paths from my home and also from my cloud servers and from the TidalScale
endpoints.

What I saw was that NO PACKETS WERE BEING DROPPED on the laggy routes. Nor ECN
signals being added.

This suggests to me that we might want to take a look at the routers that
operate at that backbone layer. I did observe similar excess delays on all
routes - about 450 msec. rather than normal < 100 msec. ping times.

That makes me have a hunch. To wit, the outbound queue depth on all models of
routers interconnecting level 3 to the world around it has a bandwidth-delay
product of 400 msec. or so.

That's unacceptable - it's way too big.

````

I have long feared that TCP's behaviors in the mass are no longer governed by
loss, but by the senders exceeding there minimum or maximum window, that
congestion control, as we knew it, is broken everywhere, even along the internet
backbone.

Also: Level3 has a lot of asymmetric traffic, and one thing that I'd like to see
more measurement sites do is measure one way delays, not just RTT, through various
providers. We have tools to do this -
notably [owamp](http://software.internet2.edu/owamp/) - and a new bufferbloat
project one called [irtt](https://github.com/peteheist/irtt).

Few public services monitor OWD. I'd suspect, based on my admittedly limited
tests - that the extra delay induced by this outage was all one way. And, if I
dared dream of the day where the products of
the [ietf AQM working group](https://tools.ietf.org/wg/aqm/),
notably, [fq codel](https://tools.ietf.org/html/draft-ietf-aqm-fq-codel-06), and
fq-pie, were one day widely deployed - on future outages such as this - delays
would stay flat and packet loss and ecn markings would go up - and the network
as a whole would silently adjust to the reduced capacity in milliseconds, not 90
minutes!

That internet would carry voice, gaming and video traffic far better than the
one we have. It would be far more resilent to all sorts of outages, and
rerouting - not just from bgp mistakes but wars and the like.

But, what if the "the network is slow today" signal vanishes - how would we
notice what had gone wrong?  What could you do?

Dave Reed, again:

````
The proper signal to the rest of the internet that something is wrong would be
dropped packets/sec or ECN marks/sec. or something of that sort.

But even that is not quite right. What one should be seeing is total number of
full-share flows on the outbound link, or something like that. That clearly went
up in this case because of the routing leak into L3.

An interesting design question as to how to properly measure virtual overload
when each TCP backs off properly during overload, in order to manage queuing
delay, don't you think?

I think that's also worth thinking about for making wifi fast - how to diagnose
throughput degradation.

Ther definition of "full-share flow" would be a flow that is getting its 1/N of
the link capacity, and therefore would probably send faster if it were allowed
to.  If there's a better term, let me know.

One need not use "flows" precisely - you can use fairness buckets in statistical
FQ.

````

I'd like to be solving that problem, but we are still a long, long way before
effective fair queuing and aqm techniques are applied along the backbone. But -
if layer 3 is 400+ ms overbuffered - I'd argue they'd provide a much better
service if they cut it to 50ms. I wish I knew who to ask.
