+++
date = "2016-03-30T18:02:58+01:00"
draft = false
tags = [ "wifi", "bufferbloat" ]
title = "Selective unprotect"
description = "Some alternative approaches to losing more packets in a wifi aggregate"
+++

For years now I've kept trying to get manufacturers, firmware writers,
device driver writers and OS makers to find ways to drop a couple
packets, when needed. Nobody believes me. Their part of the stack MUST
BE PERFECT, even over massively unreliable transports like wifi and 3G.

I'm always willing to sacrifice throughput for low latency. Always.
Usually it pays off. If I had known that the wifi retry problem would
grow so out of hand, in [1998 I would have advocated for something else](http://www.rage.net).
Probably. A little bit of retry went a long way back then.

In the
[first ever fq_codel implementation for wifi](/post/fq_codel_on_ath10k), I
showed that four upload streams had a codel induced loss rate of *25%*
at 6Mbits, at no cost in throughput.

You can say, as I did: *"YEA! codel works!"* But, honestly it would not
hurt to actually lower the retry rate on the wifi media when you are
experiencing congestion and drop a couple packets there instead - codel
won't have to work so hard - and latency - for your station - would go
down - and the number of stations you can service effectively - go up.

Modern TCPs are very aggressive, they'll recover. Believe me.

Furthermore I worry that as we increase the aggregate sizes (as in
802.11ac)that retries will go up even further than they already have,
and am certain as our networks get more dense and interference goes up
that we're going to have more issues there. Worse, your typical retry is
at a lower rate than the first attempt, which gives it even more
latency... just send another packet, later...

One of the reasons why I advocate for ECN support is that you cannot
convince some people that packet loss is GOOD, thus having some way to
do congestion control without loss seems like the only way forward. Not
that I care for ECN much.

Anyway...

I have come up with a few other ways besides codel to drop packets, by
getting the retry rate down, *while* still saving the few packets
considered precious.

Instead of codel doing all the work, you could signal the lower layer of
the stack that it's ok to drop a few more packets... this is more
similar to how the native randomness in a RED or PIE based AQM would work.

## Selective Unprotect

I don't even know if this is possible. It is based on a half reading of
the relevant specs and some data sheets a few years ago, and I only just
remembered it. If it isn't possible today, perhaps I'll propose it for
some future wifi spec.

You can (maybe) mark *some* packets in an aggregate as "don't care if you
drop them, don't ask for a retransmit if they are corrupted".

Consider an aggregate consisting of different flows. Flow A has 4
packets, B, 8, C 1, D, 2...

So ship an aggregate formed like this - protecting the last 1-2 packets
in the flow.

A1,B1,C1,D1,A2,B2,D2,P A3,D4, P A4, D5,D6,P D7, P D8.

Even if you lose all the packets besides the protected ones, it is
guaranteed that the TCP rates on the other side will only halve inside
that RTT.

Furthermore, interference based loss tends to be bursty. If you are fair
queuing the flows, as per the above, you spread the damage across all of
them, and thus need to retry less, and get a bigger slowdown as a result.

In general you do want the sparser flows to be preserved - DNS in
particular is very sensitive to loss, it's bad to lose more than 2-3
voip packets in a row, losing syn and syn/ack are bad, and arp requests
block everything... So go ahead, protect those *to some extent*! and
otherwise... feel free to drop some darn packets!

You could even do [shortest queue first](http://www.internetsociety.org/sites/default/files/pdf/accepted/4_sqf_isoc.pdf) within the aggregate, shipping C1
and D1 first rather than round robin A,B,C,D. I have no data as to where
most interference happens nowadays, but this would be much like how
fq_codel's new and old queues function and force the receiver to respond
to and grow those flows first, grabbing a fairer share of the link.

## Last packets first

There's another (crazier) alternative, which I call "last packets first".

The above approach has head of line blocking, and I suspect we'll see a
lot more tail loss than head loss in future wireless networks. It's the
nature of the beast - the more airtime you use, the more likelihood
someone else is going to mess up your transmission.

Say you have 4 packets in flow A, 8 in flow B, 1 in flow C, and 2 in D.

You could ship A4,B8,C1,D2 first in the aggregate, and only protect
those for the retransmit phase. TCP acks arriving out of order don't
hurt, they just get ignored. (mostly).

TCP data arriving out of order will be compensated for by most modern
TCPS. Bittorrent doesn't care at all. It will mess up voip if multiple
packets get in an aggregate (unlikely), but most videoconferencing
protocols should recover just fine.

But: God help you if you have TWO routers actually acting this way. I'm
really tempted to do this experiment just because I don't know of any
good way to simulate what would happen!

## Third option: Protect/Retry less when overloaded

Another option is to just stop with the retransmit attempts (almost)
entirely when your stack is backlogged. Quantum physics will do the rest
of the work for you. This option is implementable today... in fact it
was implementable 10 years ago and I thought then that was how we'd fix
it!

It's not optimal - you have some tricky interactions with rate control,
you will lose some packets you don't want to lose, and - in the case of
the media or rate control acting perfectly - you still need some way of
dropping or marking packets further up the queue - but it would help.

Now - 10 years later, I've also realized that merely turning retries way
down until the backlog clears is overly damaging (you just need to do it
inside of an RTT), so you could apply the "lower the retry rate"
periodically triggered much like how pie works.

## Ack thinning

There's a well known technique for squeezing more bandwidth out of
highly asymmetric links - it's most often used in TCPs (OSX uses it by
default), but more than a few routing devices will do deep packet
inspection to determine what are acks and selectively thin them out.

Eric Dumazet pointed out to me that, really, on a wifi client, all you
needed was the last ack to get through, so instead of shipping, say, 42 acks
on a flow over wifi (and retrying until you got them all, and buffering
until you can ship them in order) you can just ship one - and make utterly
sure that gets through. That would cut the size of a typical TXOP from a
client enormously.

With things like TCP packet pacing now heavily deployed, we've already
got away from ack clocking the return feed, anyway, so that single ack
will suffice to release a stream of packets in the other direction that
will behave properly. Usually.

There are other problems with this idea - a lot of the companies that
did DPI on acks didn't recognize the timestamp option, or ipv6 - and
newer TCP-like protocols like QUIC wouldn't be handled - and the loss of
that single packet elsewhere on the network (think multiple wifi hops)
would be disasterous, but I suspect we'll see it more and more.

I tend to favor making AMPDUs more efficient, but that's me.

## Summary

You gotta drop packets on any form of network. Somewhere. Often enough
to give TCPs enough signal to not backlog the network. Period. Next
question?
