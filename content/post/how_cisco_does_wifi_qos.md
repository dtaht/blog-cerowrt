+++
date = "2016-04-07T22:02:58+01:00"
draft = false
tags = [ "wifi", "bufferbloat" ]
title = "How Cisco does Wifi QoS"
description = "There's more than one way to do Wifi Qos and linux gets it very wrong"
+++

The best wifi I've ever experienced has been at the IETF conferences. Cisco provides enterprise grade APs and professional management there, and until now, I had not found any good documentation on how [Cisco Wifi Qos](http://mrncciew.com/2013/12/23/3850-qos-part-2-queuing-models/) actually works.

Linux gets it very wrong, but I'm out of time to write more on that than this this week.

Let's start with how the [IEEE 802.11n folk thought how aggregation should work](http://sci-hub.io/http://ieeexplore.ieee.org/xpl/articleDetails.jsp?arnumber=4454703).

```Another unresolved issue is how large a concatenation threshold the devices should set.  Ideally, the maximum value is preferable but in a noisy environment, short frame lengths are preferred because of potential retransmissions. The A-MPDU concatenation scheme operates only over the packets that are already buffered in the transmission queue, and thus, if the CPR data rate is low, then efficiency also will be small.  There are many ongoing studies on alternative queuing mechanisms different from the standard FIFO. *A combination of frame aggregation and an enhanced queuing algorithm could increase channel efficiency further*.
```

(bold mine)

The need for better queuing models was *baked into the 802.11n standard*,
but how they should they work - *left unspecified*, in 2008.

Wisps and wifi companies that "got it" jumped all over this with patents and proprietary code.

But linux limped along with a bare minimum of investment. Developers concentrated on bringing up a "representative" model of providing access to the 802.11e
queues, and not at all on how these queues would actually be used.

This was partially because wifi was misunderstood, but also because enforcing
some sort of behavior of the underlying queues smelled of "policy" not
"mechanism". 

Since mechanism was documented, and policy, not... we ended up with the 
mess we have today where typical 802.11e WMM usage makes things worse, rather than better, on low end Linux based APs and typical clients.

Oops.

Meanwhile... the lowest cost providers of wifi in the race to the bottom
completely ignored the queuing implications of not controlling EDCA right,
merely shipping hardware with 802.11e enabled and telling consumers that
they "Now had QoS!"

Those that did "get it" - chortled all the way to the bank. For a while.

