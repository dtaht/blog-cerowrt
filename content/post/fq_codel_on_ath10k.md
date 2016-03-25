+++
date = "2016-03-24T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat" ]
title = "FQ_codel on ath10k"
description = "Initial results so beautiful I cried..."
+++

[current work](https://github.com/kazikcz/linux/tree/fqmac-rfc-v2) on
adding fq_codel to the ath10k driver:

{{< figure src="/flent/wifi/rtt_fair_on_wifi/enormous_improvement.png" title="First ever fq_codel implementation results" >}}

{{< figure src="/flent/wifi/rtt_fair_on_wifi/waybetterconvergence.svg" title="Throughput similar, convergence better" >}}


## Testing multiple stations

In the test data supplied me - it hadn't occurred to me to consistently
use the rtt_fair_up tests as tests against 1,2 or 4 stations!

I especially like the idea of using rtt_fair_up to test two stations,
one slow, one fast.

This test with the new code is actually pretty encouraging - the fast
station has high throughput and low latency, the slow one, low
throughput and high latency.

{{< figure src="/flent/wifi/rtt_fair_on_wifi/encouraging_fast_slow.svg"
title="Two stations at different rates" >}}

If we can get to low throughput and low latency on the slow station,
while keeping the other station fast, we're winning.

## What's with these spikes?

Wifi has "power-save", so when

##

All behaving badly. Watching at least a billion devices ship with a
sub-optimal wifi
