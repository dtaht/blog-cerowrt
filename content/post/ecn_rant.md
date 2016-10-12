+++
date = "2016-08-27T12:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat", "ath9k", "osx" ]
title = "On the utility of explicit congestion notification (ECN)"
description = "ECN sparks passions, but does it really matter?"
+++

ECN - "Explicit congestion notification" - is a means to do congestion
control withou packet loss. It requires support in the routers,
clients, and servers - and despite being enabled in most servers, is
not on most routers, and disabled on most clients. It's got *problems*
of a theorist derived origin.

I pulled the first part of this post out of the otherwise factual
[FQ_Codel on OSX post](/post/fq_codel_on_osx) - as the rant grew so
long that I decided to break it out here. To reiterate, a bit of that
post, here, and then move onto the rant:

## ECN can be *lovely*

Rather than just supply pretty pictures, here are packet captures of
the same test [without ecn](http://www.taht.net/~d/2flows-iv-bug-fixed.cap.gz) and [with ecn](http://www.taht.net/~d/2flows-iv-fixed-ecn.cap.gz). Feel free to take them apart with your tool of choice. For this section, I am using tcptrace and xplot.org to generate the plots, rather than [flent](https://flent.org).

{{< figure src="/flent/fq_codel_osx/perfect_ecn.png" >}}

It's *perfect*. Not a single loss. Perfect congestion control,
completely bounded latency...

{{< figure src="/flent/fq_codel_osx/perfect_zoomed.png" >}}

Absolutely *perfect*. [Girlgenius-level coffee machine perfect!](http://www.girlgeniusonline.com/comic.php?date=20070618) (please read 4 panels!)

Where we would have had loss and a retransmit before, we now get a CE
marking and drop the rate. We got results this good 5 years ago, on
dsl, ethernet, and cable, and have been trying to get deployment ever
since.

I got a beef with him though. Once you reduce the bufferbloat
inflicted RTT nightmare with an aqm like codel, even without ECN

{{< figure src="/flent/fq_codel_osx/loss_sacked.png" >}}

on this local test with the new code it only takes 25ms to have a loss
and recovery that fills the hole and allows forward progress to continue.

There's also only ~30 loss events in the entire 30 second trace (there
would be more at a lower rate, less at a higher one).

{{< figure src="/flent/fq_codel_osx/sacked_zoomed.png" >}}

This amount of delay for an infrequent loss is basically inperceptable
to humans, and the overall delays so dramatically (10-1000x) lower
than what we see today on most networks, that my conclusion was that
waiting for ecn support on the clients was a waste of time, and we
should deploy what we had, starting in 2012.

Aside from a few early adopters, we still haven't crossed that chasm.

For example the pie implementation in the upcoming DOCSIS 3.1
standard lacks ecn support. Devices for that have not yet begun to ship.

Instead, well, IMHO, the ECN + aqm debate is slowing down
deployment. The perfect is the enemy of the good.

Admittedly 0 packet loss, especially on longer paths, is *nice*, but
to have to fix the clients, servers, and routers all at the same time
seemed like a big task way back then.

Note: Astute observers of this data might note that - why does TCP take
25ms to recover when the path delay flent is measuring is only 8ms?

Well, what we are measuring in flent is the FQ-induced delay for
sparse flows. The aqm component that codel is allows for quite a
bit more queuing for the tcp flows. It's VERY important to track how
well the aqm is actually working against TCP, but the only good way we
have to do so with the tools we currently have are via packet captures,
tcptrace, and xplot.org.

The sparse flow optimization in the fq_codel implementation sometimes
helps the replacement packet shoot to the front of the queue.

## On the ECN debate

It's one of those wet paint ideas. 

The ECN debate breaks down into 5 contingents.

1) 99.999% of the networking universe does not care.

The other .001% is divided into four argumentative groups that regularly
duke it out and fail to agree on anything, now, for over a decade.

2) Congest

3) Treating a mark as equivalent to a drop

But aqms like RED did not deploy. Fq_codel, codel, pie, and all the mainline
TCP's treat marks and drops as if they were the same thing.

3) Treating a mark as an earlier signal than a drop

DCTCP pioneered this approach (with

I have gradually come around to this point of view. But nobody can
agree on when that "earlier" signal should happen, or how often it
should happen, or what it should means when it happens!

Then there's a philosophical difference.

0) Packets should be dropped at the point of congestion, period

Drop has worked fine for 40 years, why change it?

1) ECN on TCP! ECN on ALL TCPs! ECN always.

ECN's basic appeal is that you can do congestion control without losing
packets. It allows for "closed-form" solutions where things currently
bifurcate into chaos.

I'm always strongly encouraging the ECN on TCP folk to look at the nature of
other non-TCP traffic, and make sure they aren't going to mess that up, and
worry a whole lot more about what potential DDOS attacks can do.

In particular, watching out for what happens when you have a non-responsive
ECN-capable sender. Recently [BBR](/tag/bbr) arrived - without support for ECN,
and the simplest, cleanest example of what that can do to other traffic is here:

{{< figure src="mybbrthingfixme" >}}

2) 

3) The third contingent (which includes myself) think that ECN should
be used very sparsely, under limited circumstances, particularly NOT
at low rates, and only by applications that actually need it. Anything
that can tolerate a loss and still recover should keep doing so.

The one place where worldwide ECN support really matters is for
circumstances where ECN has not deployed at all yet - where we barely
have designs for it yet: video conferencing and more generally, high
speed interactive video delivery. (:cough: Virtual and Augmented
Reality) These are extraordinarily hot markets, and I hope the demands
of these make ecn-enabled fq and aqm techniques like fq_codel on the
routers and clients - ubiquitous.

There hasn't been enough work on Trust. I think the "earlier signal than drop" idea makes for gaming ECN to be a non-starter.

Maybe Stuart's been right to push for full ECN support in the AQM
deployment, that aiming for the perfect will work better than merely
the good. I don't know, I'll get back to you in 5 years. Try it!

Regardless... fq_codel has had good ECN support since May 5th,
2012. Catbird seat - the ECN implementation in fq_codel is superior to
anything else except maybe cake and L4S.

Anyway, back to the rest of the tests.

If they back off hard enough, we end up with fq_codel's sparse flow optimization taking over, and they'll get *0* induced queue delay.

More power to 'em.

That leads me free to futz with wifi.