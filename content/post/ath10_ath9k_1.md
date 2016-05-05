+++
date = "2016-05-04T18:02:58+01:00"
draft = false
tags = [ "wifi", "ath10k" ]
title = "Sanity testing all the wifi pieces makes for slow progress"
description = "So many things are borken in wifi!"
+++

I am attempting to do [all up testing](/post/all_up_testing) on the
[make-wifi-fast](/tags/wifi) pieces we've assembled so far. I'm using a
Nuc configured with an ath9k chip with Tim Shepard's fq_codel patches...
which is talking to an ath10k also with michal's [latest fq_codel patches](/tags/ath10k). Merely getting past bugs is the first thing that needs to be done.

To me, this was the exciting bit! How *good could wifi get* with both
sides fq_codeled? How many more bugs could there be? Sigh: Plenty.

First up I'd wanted to use IBSS mode and a few other features that [Candelatech](http://www.candelatech.com/) had long been producing in their [custom build of QCA's ath10k firmware](http://www.candelatech.com/ath10k.php) - it has many bugs removed and multiple useful features added. I thought I'd start by testing that, then move to the mainline with this series of tests. Then move to ath10k to ath10k, and try other rates.

Well, I broke their 10.2.X release earlier today and had to revert to testing their 10.1.X release. They were *very* helpful in trying to debug it...

Let's complexify things still more. I have an odroid C2 (on x.y.z.130),
configured to use fq_codel as a qdisc. The other test target - a
[pcengines apu2d4](http://www.pcengines.ch/apu2c4.htm) - is using
sch_fq. sch_FQ is "interesting" as it attempts to do packet pacing to
fill the queue, rather than be strictly reliant on TCP acks. I wanted to
A) see if the c2 was a viable target for tests, and B) see if there was
any advantage or disadvantage to using the different qdiscs on the
hosts. Pacing, in some minds, is a bad idea when aggregation is in
play - pacing is universially good in my mind, as no matter how paced,
currently, we end up with at least a 10ms backlog in the driver and thus
plenty of paced packets could "fit".

Topology was nuc <-> wifi <-> apu2 <-> - switch - apu1, c2

## Summary of results

Single TCP flows got 110Mbis on a path capable of 110 or so.

{{< figure src="/flent/ct-10.1/tcp_downloads_good.svg" title="Good Download" >}}

I was told current kernels have issues on ath10k with single cubic flows
cracking 30Mbits. I didn't see that. I was told reno fixed it - but
unless my quick and dirty flent patch](/fixme) enabling reno is wrong, I
don't see much difference between reno and cubic. At one level, I'd be
happy, if 30mbits tops were true, a single tcp flow cannot congest this
link.... but I got the same performance with single flows and multiple -
and still did not congest the link, which is better.

*Multiple* flows did really, really well, about 105Mbit of throughput and 30ms
latency.

{{< figure src="/flent/ct-10.1/cubic_burp.svg" title="Cubic Burp" >}}

I need to repeat the test as there was a catastrophic fall in cubic througput partially through the test. Interference? noise? An interrelationship between acks and latency? The new AMDSU code acking up?

{{< figure src="/flent/ct-10.1/cs6boom.svg" title="The diffserv CS5 (VI queue) and CS6 (VO queue) tests were horrible " >}}

The link totally lost sync and I had to manually restart. It probably
was babel retracting the route - or so I thought - but might have been
some other bug
[involving losing track of what packets needed to be retransmitted](https://lists.bufferbloat.net/pipermail/make-wifi-fast/2016-April/000506.html).
The VI and VO queues are terribly undertested in Linux production
hardware, which is too bad - although mapping CS6 (network control) into
an VO queue is a terrible idea (even if it is multicast, it still gets
stacked up behind other traffic, currently. AND: in 802.11n (not ac) VO
cannot aggregate). The VI queue has some properties I really like - it
enforces short TXOPs AND also grabs the media more rapidly than standard
traffic does. IF VI worked right, it would give us an easy way to test
how short TXOPs could work better.

{{< figure src="/flent/ct-10.1/CS1_behaving_badly.svg" title="CS1 also exhibits bad behavior, starving out one flow completely for a long time." >}}

People have often asked me about enabling QoS (802.11e "WMM" mode) or
not, and it is generally a good idea on most wifi hardware to just leave
it (wmm) off due to [inadequate admission control](/fixme). But I'm a
glutton for punishment, and with such an easily reproducible test case,
perhaps I'll find someone that can make it better. Too bad it ships on
most devices, "on", and
[dscp to 802.11e queue mappings is in the process of being formally standardized](https://tools.ietf.org/html/draft-szigeti-tsvwg-ieee-802-11e-01),
and their being some uptake in the webrtc working group.

I later ran some longer tests against the CS5 queue
[with some surprising results](/post/cs5_lockout).

As for sch_fq vs fq_codel on the hosts? Too early to tell. I'd like to
believe it was better, but this is well within error bars. And there
were other problems elsewhere. Wifi data is NOISY! (And we are here
today, to just break as many things as fast as we can to get caught up
on current developments). It does look like the odroid c2 is good to
100+ mbit as a target, so far.

{{< figure src="/flent/ct-10.1/toonoisytothinkfqwins.svg" title="Is sch_fq better over wifi?" >}}

My principal intent was to test the ath10k driver by driving it with the known, well tested, well debugged, ath9k driver. But there is a new bit to the ath9k patch (adding fq_codel), and this is what 3 different test runs looked like.

{{< figure src="/flent/ct-10.1/whattheheckisath9kdoing.svg" title="ath9k wtf?" >}}

Like the sith, there are always two sides in wifi, differently broken.

The flent data from  this series is [here](/flent/ct-10.1.tgz), individual files, [here](/post/ct-10.1/).

## Flent test script

```
#!/bin/sh

S=172.26.128.1
S0=172.26.128.1
S1=172.26.16.130
S2="-H $S -H $S -H $S1 -H $S1"
T='CT-10.1'
# Make sure we're alive

fping -c 3 $S $S1

flent -H $S0 -t "$T-fq" tcp_12down
flent -H $S1 -t "$T" tcp_12down
flent -H $S0 -t "$T-fq" tcp_12up
flent -H $S1 -t "$T" tcp_12up
flent -H $S0 -t "$T0-fq" tcp_upload
flent -H $S1 -t "$T" tcp_upload
flent -H $S0 -t "$T-fq" tcp_download
flent -H $S1 -t "$T" tcp_download

for i in CS0 CS1 CS5 CS6
do
flent --swap-up-down $S2 --test-parameter=cc=cubic --test-parameter=dscp=$i,$i -t "$T-$i-cubic-down" rtt_fair_up
flent --swap-up-down $S2 --test-parameter=cc=reno --test-parameter=dscp=$i,$i -t "$T-$i-reno-down" rtt_fair_up
done
# The last test tends to blow up babel
fping -c 3 $S $S1
sleep 30
fping -c 3 $S $S1

flent -H $S2 -t "$T-up" rtt_fair_up
flent -H $S2 -t "$T" rtt_fair4be

# stress tests

flent -H $S -t "$T"  rrul_be
flent -H $S1 -t "$T" rrul_be
flent -H $S -t "$T" rrul
flent -H $S1 -t "$T" rrul

flent -l 300 --swap-up-down $S2 --test-parameter=dscp=CS0,CS0 -t "$T-$i-down-long" rtt_fair_up
```

I'm going to run a [test of the factory firmware](/post/ath10k_ath9k_2) overnight, disabling the
gnarly CS1,CS5,CS6 tests until I can watch over them..

Then I need to go back to a stable baseline, no patches at all, with
the default kernels and firmware. I could be delusional, fooling myself -
achieving less throughput than what can be achieved with normal kernels....
