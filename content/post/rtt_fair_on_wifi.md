+++
date = "2016-03-22T18:02:58+01:00"
draft = false
tags = [ "wifi", "bufferbloat" ]
title = "Analyzing ath10k's current behavior"
description = "We have a long way to go as yet..."
+++

[Bufferbloat](http://www.bufferbloat.net). It's bad everywhere, and as ISP speeds crack 35Mbit on more
and more connections, it shifts to the wifi, and despite headline
bandwidths there touted by manufacturers as hundreds of megabits, real
rates are often 20mbits or less. Triggered by [discussions at the netdev
1.1](https://www.youtube.com/channel/UCribHdOMgiD5R3OUDgx2qTg) conference, multiple developers are attempting to apply the same
techniques we successfully applied to ethernet to reduce latency there
to wifi, but it's harder - individual stations have wildly varying
rates, it's a shared medium, devices have no good feedback loops and there's 10 years of accumulated cruft
in the stack to excise.

I looked over the first rtt_fair_up tests at the lowest rate (6mbits)
on the
[current work](https://github.com/kazikcz/linux/tree/fqmac-rfc-v2) on
adding fq_codel to the ath10k driver:

{{< figure src="/flent/wifi/rtt_fair_on_wifi/kaboom.svg" title="Wifi: Peaking at 2.5 sec of latency before going haywire" >}}

It peaks at 2.5 seconds of latency. After finally dropping a packet
somewhere in the stack at T+13, there's 3sec (T+18) before it sort of
recovers, but that gets worse with all the accumulated backlog - in fact
throughput drops to a low ebb, and the test itself eventually fails, and
times out, by the end, and the wifi link is essentially unusable until
the queues drain...

So we have a bit of a ways to go before we get to an algorithm that has
some bite here, on wifi.

## A baseline "good" result

In discussing this, I thought, first, I'd point to a good result, on
ethernet:

{{< figure src="/flent/wifi/rtt_fair_on_wifi/pi_good.svg" title="Rasberry pi3 configured with the sqm-scripts for 5.5mbit down, 500k up, for fq_codel" >}}

Admittedly this test is not half duplex (hard to do except at 10mbit),
there's no retries, but... the latency is 3 orders of magnitude lower,
and tcp doesn't collapse.

How do we get this result? TCP relies on loss or markings to reduce it's
rate. There is an astounding amount of loss and marking to get to this
level of latency - and all that loss *doesn't matter*, there is always
enough packets in flight to transfer all the data.

I'd actually run the above test twice, once with ecn, once with. The ecn
behavior is "smoother", but the overall throughput roughly the same.
What was actually going on at the packet level was this:

## Packet loss is good

### NO ECN, loss rate of ~23%
```
qdisc htb 1: root refcnt 2 r2q 10 default 10 direct_packets_stat 0 direct_qlen 32
 Sent 37986258 bytes 26779 pkt (dropped 6208, overlimits 58740 requeues 0)
 backlog 0b 0p requeues 0
qdisc fq_codel 110: parent 1:10 limit 1001p flows 1024 quantum 1514 target 5.0ms interval 100.0ms ecn
 Sent 37986258 bytes 26779 pkt (dropped 6208, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
  maxpacket 1514 drop_overlimit 0 new_flow_count 1250 ecn_mark 0
  new_flows_len 0 old_flows_len 2
```
### With ECN - mark rate of ~91%
```
qdisc htb 1: root refcnt 2 r2q 10 default 10 direct_packets_stat 0 direct_qlen 32
 Sent 38002966 bytes 26818 pkt (dropped 2, overlimits 52774 requeues 0)
 backlog 0b 0p requeues 0
qdisc fq_codel 110: parent 1:10 limit 1001p flows 1024 quantum 1514 target 5.0ms interval 100.0ms ecn
 Sent 38002966 bytes 26818 pkt (dropped 2, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
  maxpacket 1514 drop_overlimit 0 new_flow_count 1153 ecn_mark 24510
  new_flows_len 0 old_flows_len 2
```

Key here is that a packet loss rate of 25% or a packet mark rate of 90%
is to be expected on the rtt_fair test at *this speed and RTT on
ethernet. There is (almost) always a tcp packet behind the one you
dropped, the data got through, and while the packet is retransmitted,
the hole is filled quickly - so you don't notice.

A net latency figure for wifi, thus, would be somewhere the low side
of 1.2ms vs 2600ms at the lowest rate. ( :) )

Since wifi data is noisy, I tried to recreate the first wifi plot above
on ethernet.

The closest thing to a comparison I can come up with for a simulation of
what's going on here is the behavior of the pi, rate limited to the same
speed, but using a 1000 packet pfifo buffer instead of fq_codel.

{{< figure src="/flent/wifi/rtt_fair_on_wifi/pfifo_collapse.svg" width=640px title="Rasberry pi3 configured with the sqm-scripts for 5.5mbit down, 500k up, for pfifo w/1000 packets" >}}

Ugh!

## Some thoughts

Definitely keep testing for 40 seconds or more. Too many tests don't
test long enough.

In terms of seeing an effect in holding latency low on wifi and it's
relation to throughput, instead of using any of these fancy schmancy aqm
algorithms, try just dropping (or mark) all packets older than 20ms. Hit
it with a hammer, try to get closer to the pi result.

Another thought... for holding a smoother bandwidth estimate, is to
limit retries based on the rate - at the lowest rate retry, at most,
once - scale up a bit for higher speeds and bursts where the rate
controller is actually going to try more than one speed. Feedback as to
how long a given txop took to finish and the actual rate on completion
would be better...

## Testing multiple stations

In the test data supplied me - it hadn't occurred to me to consistently
use the rtt_fair_up tests as tests against 1,2 or 4 stations!

I especially like the idea of using rtt_fair_up to test two stations,
one slow, one fast.

This test with the new code is actually pretty encouraging - the fast
station has high throughput and low latency, the slow one, low
throughput and high latency.

{{< figure src="/flent/wifi/rtt_fair_on_wifi/encouraging_fast_slow.svg" title="fast_slow test newmac" >}}

If we can get to low throughput and low latency on the slow station,
while keeping the other station fast, we're winning.

## Why reducing latency matters

I like very much the idea of focusing on isolating all the variables
needed to get the lowest possible latency at the lowest possible
rate(s), and not caring about peak throughput at the highest, for a
while... for long enough to smash things down to 20ms... but that's me.

Or I'd say it was me, only if I didn't think long term behaviors this
bad, were, well, very bad for users and the internet itself.

Classic tcp benchmarking has a tendency to last 10 or 15 seconds, and
inside of those 15 seconds you can, indeed deliver a few more packets if
you buffer excessively, and never drop any.

The end result of this is like running a dragster far enough off the
drag strip so that the engine explodes. Back to using the pi in
emulation again:

{{< figure src="/flent/wifi/rtt_fair_on_wifi/compared.svg" title="Kaboom!" >}}

What you want is stable tcp behavior at *all timescales* - not zero to
10 seconds, but zero to infinity.

Some innate features of the flent test suite limit the maximum test
duration to 20 minutes...  and I'm always worrying that there will be
some bug that only happens at at T+21 minutes. I'll run tests overnight
overlapping, for this reason. (this also tends to take advantage of
more spectrum available at 4AM than at 8PM). I have found innumerable
bugs in drivers by doing this - most recently the mwl wifi driver will
hang completely inside of 25-40 minutes of this level of stress testing.

Everybody else wants the highest possible throughput... even if the
network (engine) explodes at the end of the test. Why all this
buffering?? "For THROUGHPUT!", they cry...

Well, here is a comparison of the total throughput of the pi emulated
with a pfifo as above (2.2 sec of buffering) vs the total throughput of
the pi+fq_codel emulation (1ms of buffering) over the full 60 second
test run.

{{< figure src="/flent/wifi/rtt_fair_on_wifi/twice_as_much_real_data_transferred.svg" title="low latency for tcp leads to 2x more real data transferred" >}}

The explosions taking place after buffers are filled are extremely
damaging to actual long term throughput, all caused by excessive latency
in this portion of the stack.

And (sigh) this sort of behavior is so darn common because nobody runs
benchmarks long enough to see the pieces spread across the end of the track.

Maybe if I go rant about the tcp_square wave tests in flent, and how
they provide insight into how congestion control actually should work,
that will help. (next up).
