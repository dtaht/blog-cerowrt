+++
date = "2016-05-11T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat", "ath9k" ]
title = "The 1ms wmm txop"
description = "1ms is quite a lot as it as... but 5.7ms is crazy"
+++

I have long advocated that some layer of the WIFI mac - not layer 3 - be configurable to [lose some darn packets](/post/talks/make_wifi_fast) when needed, to not treat [every packet as sacred and block ack them all](/posts/selective_unprotect) and also that people attempt to optimize for latency and maximimizing the issued txops to as many stations as possible, rather than bandwidth whenever possible. While exploring [the 802.11e VI queue lockout bug](/post/cs5_lockout), I explored what reducing the maximum size of a TXOP to 1ms could look like.

The first *surprising* result was this:

{{< figure src="" >}}

I'd set the maximum size of a txop down from an unspecified (0) (which should result in 5.7ms sized txops under some circumstances to the 

by adding this into my [hostapd.conf file](/flent/fixme).

```

```

Note: I did also change the location of the AP under test from this test
run to the others, which could have had some effect. It was only about
a foot, but...

BER is *a contract* between layer 2 and layer 3 of the network stack.

assumptions of the theorists that wifi actually has lossy behavior nowadays.
Time after time I've seen a paper that applies netem with a loss rate
of 1.5% . No... what you typically see is a large spike on L2 based delay.

In some tests I am seeing retry rates in excess of 15% ... and *zero* packet loss at the mac layer on the end resulting capture.


That the wifi standard itself says:

```
Another unresolved issue is how large a concatenation threshold the devices should set. Ideally, the maximum value is preferable but in a noisy environment, short frame lengths are preferred because of potential retransmissions. The A-MPDU concatenation scheme operates only over the packets that are already buffered in the transmission queue, and thus, if the CPR data rate is low, then efficiency also will be small. There are many ongoing studies on alternative queuing mechanisms different from the standard FIFO. *A combination of frame aggregation and an enhanced queuing algorithm could increase channel efficiency further*. 
```

Now, there is no reason why the latency at 300 mbit couldn't be at least
20x better than it is, aside from the very tight timings required to
achieve it.

{{< figure src="/flent/apu2d-400-200mbit/400mbit-cake-shaped.svg" >}}
