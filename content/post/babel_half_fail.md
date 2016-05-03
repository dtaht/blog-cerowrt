+++
date = "2016-04-29T14:02:58+01:00"
draft = true
tags = [ "routing", "babel", "lab" ]
title = "Failing over faster part 2"
description = "Routing asymmetry for 30 seconds... why?"
+++

Chasing this interesting performance problem in the babel routing daemon isn't
what I wanted to be doing.

What I wanted to be doing was showing "Better" behavior with short fq_codeled'
queues, so that a route change would not cause A) a flow reset, and
B) the flow would grab more of the link the sooner as it had more link, and C) back off faster when it switches to a worse link. Instead... well...

I changed 3 parameters this time.

I switched from a raspberry pi switching between wifi and ethernet to
 a [C.H.I.P](http://getchip.com) going from usb networking to wifi (because I'm bringing up everything in the [sflab](/tags/lab) and enjoy [massively changing the environment while searching for the real variable](/post/all_up_testing)...

The "chipzilla" box is connected via an interface-independent ipv6 address: fd99::23.  This stable identifier should make it possible to "stay up" even as
all the routes change from under it. 

adding that was:

```
ip -6 addr add fd99:23/128 dev lo
```

And telling babel to export it to the network. (simplest way is to run it
without a "redistribute local deny" line) 

...

In the [previous test run](/post/failing_over_faster) the ideal output below would have been to see latency stay relatively flat for the measurement flows.

Instead, what I saw then was the wifi link dropping offline entirely for
random reasons. I think we isolated it down to a previously unknown
issue with [multicast packet loss while in wifi powersave mode](/post/poking_at_powersave).

This time, I put up a repeating route flap on "chipzilla":

```
sleep 20; ifdown usb0; sleep 10; ifup usb0; sleep 60; ifdown usb0; sleep 20; ifup usb0
```

And tweaked the interface polling interval from 30 seconds to 1 second:

{{< figure src="/flent/babel_half_fail/babel_half_fail.svg" link="/flent/babel_half_fail/babel_half_fail.svg" >}}

If you squint, at T+60 to T+90. Why is that? Wifi is half duplex, so
using up less bandwidth in one direction gives more in the other - and
the throughput improvement here would be even greater if we weren't
suddenly sending 8x as many acks.

This is a case where a triangular routing scenario is actually a good thing.

At T+110 the usb interface comes up again. Roughly 60 seconds later
one side of the link notices and starts sending packets out that way.
30 seconds after that, the other side of the link notices and starts
sending out packets that way.

Why is this?

sensing. I had an up/down event, I know what to do. Everybody else
is sensing that there's a problem,

What to do? Explicitly saying there was an interface up event might be
an answer. 

eBDP

In my ideal non-bufferbloated world, you'd shed the load at T+20,
and never acquire athe load at T+50, nor T+70 to have such enormous delays.
It would all look like T+210, all the time, no matter how much
traffic was flowing through the link.

block half the traffic with iptables?

Paths fail in mysterious ways - 

look at the hop count metric?

Maybe the interface down has a long queue, all kinds of 
packets stored up, that haven't been delivered yet?

Metric is asymmetric - one side considers the link having a better
metric than the other side?

How do I fail the link? Packet loss in one direction.

so the 

But that depends on whether or not babeld is getting that down/up signal.

And only discovers the loss of connectivity from the hellos,
wires

wires - once half of the window of hellos recieved - n hellos must be
recieved - 

when a link goes back up, burst some hellos.

... 

what's the with notsentlowat portion.

I was also testing the notsentlowat sysctl option, which is disabled by default.
It helps! It is disabled because it hurts on virtualized environments, which
essentially need more buffering to get through from the virtualized host
to the bare hardware, and also tends to not drive wifi at high speeds on
some benchmarks.

Reducing it to 4096 helped quite a lot, but the real hope, and help, on the chip, is to get it running fq_codel as well as the rpi3 and odroid do, first.

Still on these hackerboards, probably a small value for this will help
a lot after a bit more testing.
