+++
date = "2016-10-11T18:02:58+01:00"
draft = true
tags = [ "ath9k", "wifi", "bufferbloat" ]
title = "Finally the real ath9k results"
description = ""
+++

need: mcs14 vs mc14

Topology before:

laptop(AP) <-> Ath9k Wifi <-> OSX and Linux (ath10k)

Topology now:

odroid c2 <-> ethernet <-> laptop(AP) <-> Ath9k Wifi <-> OSX and Linux (ath10k)

{{< figure src="/flent/airtime-c2/osx-v-server-expected-totals.svg" >}}

This is a good 50Mbits better than what I was getting driving the tests directly from the AP, so we have work to do on some tcp stack interactions there.

figure Fixme

## Still... dancing!

But we are finally holding latencies below 20ms at the median for rates
varying from 6mbits to 150mbits on the ath9k!

{{< figure src="/flent/airtime-c2/latency_flat_at_all_mcs_rates.svg" >}}

At no cost in performance.

{{< figure src="/flent/airtime-c2/osx-v-server-expected-up.svg" >}}

At even the lowest rate.

fixme

Forgive me for cutting things off at the 98th percentile. I actually care
a lot about outliers, and why they happen, and at some point I'll return
to limiting retries and minstrel mis-behaviors.

## Latency flat at all rates

{{< figure src="/flent/airtime-c2/latency_flat_at_all_rates_cdf.svg" >}}

And we're regulating the stuff at the AP

{{< figure src="/flent/airtime-c2/os-v-server-expected-cdf-up.svg">}}

## Unmodified drivers - Down results

Both the client and osx box have unmodified ath10k drivers. The OSX box tends to go asleep and take a while to start up, so here you see the linux server getting started 5 seconds early, and then the OSX box kicking in.

{{< figure src="/flent/airtime-c2/osx-v-server-down-expected.svg">}}

We're still getting a benefit from the more fq_codeled driver in the
AP - but there's not much - and because the latencies have grown so large,
and there isn't enough fair queuing, there's ping packet loss.

{{< figure src="/flent/airtime-c2/osx-v-server-expected-down-cdf.svg" >}}

## Asymmetry

Most wifi connections are highly asymmetric. You might be getting mcs12 from the AP (because it has good antennas) and only mcs1 from the client (because they don't). Here you can clearly see the effect of asymmetry between the lowest and
highest rates on TCP. 

{{< figure src="/flent/airtime-c2/downloads_somewhat_bound_by_uplink_rate.svg" >}}

{{< figure src="/flent/airtime-c2/stilldontknowwhatosxdoesdifferent_down.svg" >}}

## Exploring bandwidth asymmetry

But I'll save that for another day. I'm going to savor this for a while.

## Aside

Well, let me return for a moment to an earlier plot.

{{< figure src="/flent/airtime-c2/would_that_be_so_bad.svg" >}}

Would it be *bad* to sacrifice 50% of your bandwidth (sometimes), in
order to get your wifi latency below 4ms? What if it was only 20%? or
10%? Or 70%?

In order to make mu-mimo work effectively we need to shorten the txops
anyway. What if we do that to wifi now?

The theory said it would. It did. Getting wifi down to consistent latencies
like this was my main goal for the make wifi fast project. And, I'm out
of funding, which means that taking this any further will have to rely
on the community.

Chart

## Ripping out latency can be fun!

Believe it or not, we can probably rip out another 4-6ms from this
with tighter code and/or better firmware, and, if we are willing to
sacrifice bandwidth in favor of latency another 10ms on top of that.
We could get things, overall, down, to an increment of no more
than 2ms per station actively transmitting. The host result shows we
can get to 4ms latency, and that's a *good thing*.

Rip out re-ordering

It will probably come at some sacrifice in bandwidth, but
which would you rather have.

Come rain, or movement, or interference, we should be able to hold
wifi latencies nearly constant - although there as yet a few edge
cases to explore with this code.


