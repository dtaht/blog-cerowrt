+++
date = "2016-03-30T18:02:58+01:00"
draft = false
tags = [ "wifi", "bufferbloat" ]
title = "Selective unprotect"
description = "Some alternative approaches for losing more packets in a wifi aggregate when needed..."
+++

NOTE: 802.11 standard readers will think of "protection" as a frame being
encrypted. Below I am talking about the willingness to lose data, and
I ended up starting to revise this piece based on reading the 802.11n-2012
specification... sorry for the noise and notes.

For years now I've kept trying to get manufacturers, firmware writers,
device driver writers and OS makers to find ways to drop a couple
packets, when needed. Not enough have believed me. Their part of the stack MUST
BE PERFECT, even over massively unreliable transports like wifi and 3G. [Every Packet is Sacred](http://www.bufferbloat.net/projects/bloat/wiki/Humor), they sing....

I'm always willing to sacrifice throughput for low latency. Always.
Usually it pays off. If I had known that the wifi retry problem would
grow so out of hand, in [1998 I would have advocated for something else](http://www.rage.net/wireless/diary.html).
A little bit of retry went a long way back then. 1 retry at
the 802.11b mac layer was
enough to get a packet loss percentage of 1-3% and once we added
[wondershaper](http://www.bufferbloat.net/projects/cerowrt/wiki/Wondershaper_Must_Die)
into the mix, everything was fine. While there *was* [bufferbloat](/tags/bufferbloat)
back then, at least, queues were much smaller - 4 packets in the driver, 100 in the txqueue. We improved web things by using a squid
cache on the other side of the wifi link, also. The short RTTs made TCP
recover nicely... and since 1998 and the rise of CDNs, many important TCP based sites now have RTTs down in the 10-30ms range, today. And - I wish [mosh](http://mosh.mit.edu) and [QUIC](https://www.chromium.org/quic) had existed then and more people built on the ideas in them for things like RDP and X11.

Lastly... I never expected wifi device driver writers to up the retries to a fixed size of 10 (ath9k), or to infinity!

In the
[first ever fq_codel implementation for wifi](/post/fq_codel_on_ath10k), [I
showed](/post/rtt_fair_on_wifi/) that four upload streams had a codel induced loss rate of *25%*
at 6Mbits on a 2ms path, at no cost in throughput, for a net queue depth of
20ms.

You can say, as I did: *"YEA! codel works!"* But, honestly it would not
hurt to actually lower the retry rate on the wifi media when you are
experiencing congestion and drop a couple packets there instead - codel
won't have to work so hard - and latency - for your station - would go
down - and the number of stations you can service effectively - go up.

Modern TCPs are very aggressive, they'll recover. Believe me.

Furthermore I worry that as we increase the aggregate sizes (as in
802.11ac) that retries will go up even further than they already have,
and am certain as our networks get more dense and interference goes up
that we're going to have more issues there. Worse, your typical retry is
at a lower rate than the first attempt, which gives it even more
latency... sigh. just send another packet, later...

One of the reasons why I advocate for ECN support is that you cannot
convince some people that packet loss is GOOD, thus having some way to
do congestion control without loss seems like the only way forward. Not
that I care for ECN much.

Anyway...

I have come up with a few other ways besides codel to drop packets, by
getting the wifi retry rate down, *while* still saving the few packets
considered precious.

Instead of codel doing all the work, you could signal the lower layer of
the stack that it's ok to drop a few more packets... this is more
similar to how the native randomness in a RED or PIE based AQM would work,
although codel's drop scheduler and use of timestamping have other benefits
that also can be used.

## Selective Unprotect

I don't even know if this is possible. It is based on a half reading of
the relevant specs and some data sheets a few years ago, and I only just
remembered it. If it isn't possible today, perhaps I'll propose it for
some future wifi spec.

You can (maybe) mark *some* packets in a TXOP as "don't care if you
drop them, don't ask for a retransmit if they are corrupted".

Consider an aggregate consisting of different flows. Flow A has 4
packets, B, 8, C 1, D, 2...

So ship an aggregate formed like this - protecting the last 1-2 packets
in the flow.

A1,B1,C1,D1,A2,B2,D2,P A3, B3, P A4, B4, B5, B6,P B7, P B8.

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
and D1 first rather than round robin A,B,C,D. I have no data (yet) as to where
most interference happens nowadays, but this would be much like how
fq_codel's new and old queues function and force the receiver to respond
to and grow those flows first, grabbing a fairer share of the link.

update: The parameter I am talking about is QosNOack, which is in section
[6.2 of the standard](http://sci-hub.io/http://ieeexplore.ieee.org/xpl/articleDetails.jsp?reload=true&tp=&isnumber=4248377&arnumber=4248378&punumber=4248376).

6.1.1 has normal acknowledgement, block ack, and no ack as part of the 2 bits.

802.11n adopted this form of framing and it's unknown what happens. See 
also table 7.4 in the standard.

More notes:

It still isn't clear if you can do multiple ampdus in a single txop.

ESOP = end of service period. 7.1.3.5.5 is the Queue size

The Queue Size subfield is an 8-bit field that indicates the amount of buffered traffic for a given TC or TS at the non-AP STA sending this frame.  The Queue Size subfield is present in QoS data frames sent by STAs associated in a BSS with bit 4 of the QoS Control field set to 1.  The AP may use information contained in the Queue Size subfield to determine the TXOP duration assigned to non-AP STA.  The queue size value is the total size, rounded up to the nearest multiple of 256 octets and expressed in units of 256 octets, of all MSDUs buffered at the STA (excluding the MSDU of the present QoS data frame) in the delivery queue used for MSDUs with TID values equal to the value in the TID subfield of this QoS Control

AID field - 7.3.1.8 - the station id

DELBA Paramer - deletes the block ack 7.3.1.16

trigger enabling vs delivery enabling.

7.6.2.1

The traffic-indication virtual bitmap, maintained by the AP that generates a TIM, consists of 2008 bits, and is organized into 251 octets such that bit number N (0 ≤ N ≤ 2007) in the bitmap corresponds to bit number ( N mod 8) in octet number N / where the low-order bit of each octet is bit number 0, and the high order bit is bit number 7.  Each bit in the traffic-indication virtual bitmap corresponds to traffic buffered for a specific STA within the BSS that the AP is prepared to deliver at the time the Beacon frame is transmitted.  Bit number N is 0 if there are no directed frames buffered for the STA whose Association ID is N .  If any directed frames for that STA are buffered and the AP is prepared to deliver them, bit number N in the traffic- indication virtual bitmap is 1.  A PC may decline to set bits in the TIM for CF-Pollable STAs it does not intend to poll (see 11.2.1.6)

## Last packets first

There's another (crazier) alternative, which I call "last packets first".  The above approach has head of line blocking, and I suspect we'll see a lot more tail loss than head loss in future wireless networks. It's the nature of the beast - the more airtime you use, the more likelihood someone else is going to mess up your transmission.  Say you have 4 packets in flow A, 8 in flow B, 1 in flow C, and 2 in D.  You could ship A4,B8,C1,D2 first in the aggregate, and only protect those for the retransmit phase. TCP acks arriving out of order don't hurt, they just get ignored. (mostly).  TCP data arriving out of order will be compensated for by most modern TCPS. Bittorrent doesn't care at all. It will mess up voip if multiple packets get in an aggregate (unlikely), but video in most videoconferencing protocols should recover just fine.

But: Ghu help you if you have TWO routers actually acting this way. I'm
really tempted to do this experiment just because I don't know of any
good way to simulate what would happen!

More notes:

TPC Report availability?

The spec seems to require something like htb actually in the device driver
to regulate access to the vi and vo queues:

mean data rate, the peak data rate, and the burst size are the parameters of the token bucket model, which provides standard terminology for describing the behavior of a traffic source.  The token bucket model is described in IETF RFC 2212-1997 [B19] , IETF RFC 2215-1997 [B20] , and IETF RFC 3290-2002 [B24] .

9.1

The QoS AP announces the EDCA parameters in selected Beacon frames and in all Probe Response and (Re)Association Response frames by the inclusion of the EDCA Parameter Set information element.  If no such element is received, the STAs shall use the default values for the parameters.
"The management frames shall be sent using the access category AC_VO without being restricted by admission control procedures."

The AP may use a different set of EDCA parameters than it advertises to the STAs in its BSS.

9.2.2
MAC-Level acknowledgments The reception of some frames, as described in 9.2.8 , 9.3.3.4 , and 9.12 , requires the receiving STA to respond with an acknowledgment, generally an ACK frame, if the FCS of the received frame is correct.  This technique is known as positive acknowledgment.  Lack of reception of an expected ACK frame indicates to the STA initiating the frame exchange that an error has occurred.  Note, however, that the destination STA may have received the frame correctly, and that the error may have occurred in the transfer or reception of the ACK frame.  To the initiator of the frame exchange, this condition is indistinguishable from an error occurring in the initial frame. 

9.6 Multirate support
Some PHYs have multiple data transfer rate capabilities that allow implementations to perform dynamic rate switching with the objective of improving performance.  The algorithm for performing rate switching is beyond the scope of this standard, but in order to ensure coexistence and interoperability on multirate- capable PHYs, this standard defines a set of rules to be followed by all STAs. 

9.7 is violated by most drivers -

"admission control, in general, depends on vendors' implementation of the scheduler, available channel capacity, link conditions, retransmission limits, and the scheduling requirements of a given stream.  All of these criteria affect the admissibility of a given stream.  If the HC has admitted no streams that require
polling, it may not find it necessary to perform the scheduler or related HC functions."
 
## Simplest option: Protect/Retry less when overloaded

Another option is to just stop with the retransmit attempts (almost) entirely when your stack is backlogged. Quantum physics will do the rest of the work for you. This option is implementable today... in fact it was implementable 10 years ago and I thought then that was how we'd fix it! It's not optimal - you have some tricky interactions with [rate control](/post/minstrel),
you will lose some packets you don't want to lose, and - in the case of
the media or rate control acting perfectly - you still need some way of
dropping or marking packets further up the queue - but it would help.

Now - 10 years later, I've also realized that merely turning retries way
down until the backlog clears is overly damaging (you just need to do it
inside of an RTT), so you could apply the "lower the retry rate"
periodically triggered much like how pie works (codel would work too).

Having wifi rate control not aim for the perfect rate, but the slightly
less than perfect (and usually faster) rate that *ensures enough loss to keep the backlog small* seems fairly ideal... but hard.

You can also turn off requests for block acknowledgements on some aggregates.
If your media is being perfect, you can save som etime doing that... and
lose some darn packets....

## Ack thinning/Stretch acks

There's a well known technique for squeezing more bandwidth out of
highly asymmetric links - "Stretch Acks". It's most often used in TCPs (OSX uses it by
default), but more than a few routing devices will do deep packet
inspection to determine what are acks and selectively thin them out.

Eric Dumazet pointed out to me that, really, on a wifi client, all you
needed was the last TCP ack to get through, so instead of shipping, say, 42 acks
on a flow over wifi (and retrying until you got them all, and buffering
until you can ship them in order) you can just ship one - and make utterly
sure that gets through. That would cut the size of a typical TXOP from a
client enormously. (Clients run at lower rates and have lousy antennas,
so are more than half the problem).

With things like [TCP packet pacing](https://fasterdata.es.net/host-tuning/linux/fair-queuing-scheduler/) now heavily deployed, we've already
got away from ack clocking the return feed, anyway, so that single ack
will suffice to release a stream of packets in the other direction that
will behave properly. [Usually](https://tools.ietf.org/html/rfc2525#page-40).

There are other problems with stretch acks - a lot of the companies that
did DPI to find acks didn't recognize the timestamp option, or ipv6 - and
newer TCP-like protocols like QUIC wouldn't be handled - and the loss of
that single packet elsewhere on the network (think multiple wifi hops)
would be disasterous, but I suspect we'll see it more and more.

I do not have [any problem](https://tools.ietf.org/html/rfc2525) with *endpoints* making the stretch
ack decision, but [not much in favor of middleboxes](https://tools.ietf.org/html/rfc2525) doing it - and I 
tend to favor making AMPDSUs more efficient, but that's me. 

## Summary

You gotta drop packets on any form of network. Somewhere. Often enough
to give TCPs enough signal to not backlog the network. Period. Next
question: [Can DQL help](/post/dql_on_wifi)?
