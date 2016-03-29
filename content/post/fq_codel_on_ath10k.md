+++
date = "2016-03-24T18:02:58+01:00"
draft = false
tags = [ "wifi", "bufferbloat", "ath10k" ]
title = "FQ_codel on ath10k"
description = "Initial results so beautiful I cried..."
+++

Here's Michal Kazior's [current work](https://github.com/kazikcz/linux/tree/fqmac-rfc-v2) on
adding fq_codel to the ath10k driver:

Let's start with [where we were yesterday](/post/rtt_fair_on_wifi):

{{< figure src="/flent/wifi/rtt_fair_on_wifi/kaboom.svg" title="Kaboom with 2.5 sec of latency at 6mbit" >}}

Vs today: 6mbits of clean throughput (4 streams going here), with less than 20ms latency.

{{< figure src="/flent/wifi/rtt_fair_on_wifi/enormous_improvement.png"
title="First ever fq_codel implementation on wifi results" >}}

*This is the first time I have ever seen a wifi card behave sanely in
over a decade* at low rates, outside of experiments and simulations. I
was so happy to see this result on a real card in real conditions, I got
really emotional, every time I showed someone in the bufferbloat project
the graphs....

5 years of work...
[theory](https://datatracker.ietf.org/doc/draft-ietf-aqm-codel/?include_text=1)...
[simulation](https://www.nsnam.org/wiki/AQM_enhancements)...
[standardization](https://tools.ietf.org/html/draft-ietf-aqm-fq-codel-06/?include_text=1)...
and [preaching](/tags/talks)!!!  until this moment. *wow*.

Michal's proof of concept even works fine at the highest rates, with better
convergence for each flow, due to the FQ, AND there appears to be faster
usage of the initial bandwidth in the first 3 seconds of the test which
bodes *really well* for web traffic. There's a "free" extra 60mbits
shown here:

{{< figure src="/flent/wifi/rtt_fair_on_wifi/waybetterconvergence.svg" title="Throughput similar, convergence better" >}}

There are still many issues left to resolve, but there's light! Light!
at the end of the tunnel. This work may well apply to other major
chipsets like ath9k and iwl. It'll help, even if only one side (e.g.
your laptop) has the updated drivers.

## Testing multiple stations

In the test data Michal supplied me - it hadn't occurred to me to
consistently use the [flent](https://flent.org)'s rtt_fair_up tests as
tests against *1*,2 or 4 stations! I'd always used it for just 2 or 4.
This will give comparable data across all tests, and isolate the tests
to just the upload side (so the card on the other side of the test does
not need to have an updated driver).

I especially like the idea of using rtt_fair_up to test two stations,
one slow, one fast, which is what he's doing...

This test with the new code is actually pretty encouraging - the fast
station has high throughput and low latency, the slow one, low
throughput and high latency.

{{< figure src="/flent/wifi/rtt_fair_on_wifi/encouraging_fast_slow.svg"
title="Two stations at different rates" >}}

If we can get to low throughput and low latency on the slow station,
while keeping the other station fast, we're winning.

3 out of 4 ain't bad.

And it seems plausible that he can get even more bandwidth into the fast
station while still servicing the slow one, with a bit more work.

## What's with these spikes early and late in the test?

Wifi has "power-save", so when output is very sparse (flent spends 5
seconds at the begining and end of the test merely pinging), power save
kicks in and we see long delays. This is totally ok, expected behavior,
although it is not at all what you see on ethernet.

Next up - [Some alternative approaches to codel on wifi](/post/selective_unprotect)...

and after then I'll try to tackle [Michal's experiments with using DQL](/post/dql_on_wifi),
which is a simpler technique for measuring available bandwidth than
looking directly at wireless's rate control is. DQL was designed for
ethernet, can it be extended to wireless?
