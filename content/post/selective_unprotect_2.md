+++
date = "2016-03-30T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat" ]
title = "Selective unprotect seems feasible"
description = "Some alternative approaches for losing more packets in a wifi aggregate when needed..."
+++

Going back the the [/post/selective_unprotect) idea, I spent the week
reading the 802.11 standards from cover to cover. 802.11-2002 is a 2793 page document... so it took a while.

But I basically found the genesis of the core idea in the QoS control field
and how AMPDU's are formed on page 866.

The QoS Control field is a 16-bit field that identifies the TC or TS to which the frame belongs as well as various other QoS-related, A-MSDU related, and mesh-related information about the frame that varies by frame type, subtype, and type of transmitting STA. The QoS Control field is present in all data frames in which the QoS subfield of the Subtype field is equal to 1 (see 8.2.4.1.3). Each QoS Control field comprises five or eight subfields, as defined for the particular sender (HC or non-AP STA) and frame type and subtype.  The usage of these subfields and the various p 

NOTE: 802.11 standard readers will think of "protection" as a frame being
encrypted. Below I am talking about the willingness to lose data.


9.7 Multirate support
9.7.1 Overview
Some PHYs have multiple data transfer rate capabilities that allow implementations to perform dynamic rate
switching with the objective of improving performance. The algorithm for performing rate switching is beyond
the scope of this standard, but in order to provide coexistence and interoperability on multirate-capable PHYs,
this standard defines a set of rules to be followed by all STAs.

Bingo:

9.12 A-MPDU operation
9.12.1 A-MPDU contents
According to its context (defined in Table 8-283), an A-MPDU shall be constrained so that it contains only
MPDUs as specified in the relevant table referenced from Table 8-283.
When an A-MPDU contains multiple QoS Control fields, bits 4 and 8–15 of these QoS Control fields shall be
identical.

Bits 5 and 6 are the Block Ack control fields - Immediate, deferred, NoAck.

In other words, you can turn off acks at the mac layer

A digression. Was *heresy*. But it was the only way to get then current
TCPs to scale up *at all* - so as a hack that worked, doing the acks
at the mac layer became

Here I am, being heretical again.

9.1

The QoS AP announces the EDCA parameters in selected Beacon frames and in all Probe Response and (Re)Association Response frames by the inclusion of the EDCA Parameter Set information element.  If no such element is received, the STAs shall use the default values for the parameters.
"The management frames shall be sent using the access category AC_VO without being restricted by admission control procedures."


The AP may use a different set of EDCA parameters than it advertises to the STAs in its BSS.

9.2.2
MAC-Level acknowledgments The reception of some frames, as described in 9.2.8 , 9.3.3.4 , and 9.12 , requires the receiving STA to respond with an acknowledgment, generally an ACK frame, if the FCS of the received frame is correct.  This technique is known as positive acknowledgment.  Lack of reception of an expected ACK frame indicates to the STA initiating the frame exchange that an error has occurred.  Note, however, that the destination STA may have received the frame correctly, and that the error may have occurred in the transfer or reception of the ACK frame.  To the initiator of the frame exchange, this condition is indistinguishable from an error occurring in the initial frame. 

9.6 Multirate support
Some PHYs have multiple data transfer rate capabilities that allow implementations to perform dynamic rate switching with the objective of improving performance.  The algorithm for performing rate switching is beyond the scope of this standard, but in order to ensure coexistence and interoperability on multirate- capable PHYs, this standard defines a set of rules to be followed by all STAs. 

9.7 violated

dmission control, in general, depends on vendors' implementation of the scheduler, available channel capacity, link conditions, retransmission limits, and the scheduling requirements of a given stream.  All of these criteria affect the admissibility of a given stream.  If the HC has admitted no streams that require
polling, it may not find it necessary to perform the scheduler or related HC functions.
 
## Simplest option: Protect/Retry less when overloaded Another option is to just stop with the retransmit attempts (almost) entirely when your stack is backlogged. Quantum physics will do the rest of the work for you. This option is implementable today... in fact it was implementable 10 years ago and I thought then that was how we'd fix it! It's not optimal - you have some tricky interactions with [rate control](/post/minstrel),
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
