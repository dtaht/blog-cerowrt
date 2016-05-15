+++
date = "2016-05-04T18:02:58+01:00"
draft = true
tags = [ "wifi", "ath10k" ]
title = "Trying the QCA8860 10.x. ath10k firmware"
description = "The latest code is less borken but slower"
+++

Note: self: visit the ct-10.1 and stock dirs and rewrite similarly
to the other post.

## Summary of results

Single TCP flows got 90Mb on a path capable of 110 or so.

{{< figure src="/flent/ct-10.1/tcp_downloads_good.svg" title="good download" >}}

I was told current kernels have issues with single cubic flows cracking 30Mbits. I didn't see that. I was told reno fixed it - but unless my test enabling it is wrong, I don't see much difference between reno and cubic. At one level, I'm happy, if 30mbits tops were true, a single tcp flow cannot congest this link.... but I got the same performance with single flows and multiple - and still did not congest the link. 

*Multiple* flows did really, really well, about 105Mbit of throughput and 30ms
latency.

{{< figure src="/flent/ct-10.1/cubic_burp.svg" title="Cubic Burp" >}}

I need to repeat the test as there was a catastrophic fall in cubic througput partially through the test. Interference? noise? An interrelationship between acks and latency? The new AMDSU code acking up?

{{< figure src="/flent/ct-10.1/cs6boom.svg" title="The diffserv CS5 (VI queue) and CS6 (VO queue) tests were horrible " >}}

The link totally lost sync and I had to manually restart. It probably was babel retracting the route - or so I thought - but might have been some other bug [involving losing track of what packets needed to be retransmitted](/fixme). The VI and VO queues are terribly undertested in production hardware, which is too bad - although mapping CS6 (network control) into the VO queue is a terrible idea (even if it is multicast, it still gets stacked up behind other traffic, currently), and the VI queue has some properties I really like - it enforces short TXOPs AND also grabs the media more rapidly than standard traffic does. IF VI worked right, it would give us an easy way to test how short TXOPs could work better.

{{< figure src="/flent/ct-10.1/CS1_behaving_badly.svg" title="CS1 also exhibits bad behavior, starving out one flow completely for a long time." >}}

People ask me about enabling QoS (802.11e "WMM" mode) or not, and it is generally a good idea on most wifi hardware to just leave it (wmm) off. But I'm a glutton for punishment, and with such an easily reproducable test case, perhaps I'll find someone that can fix it. Too bad it ships on most devices, "on".

As for sch_fq vs fq_codel on the hosts? Too early to tell. I'd like to believe it was better, but this is well within error bars. And there were other problems elsewhere. Wifi data is NOISY! (And we are here today, to just break as many things as fast as we can to get caught up on current developments)

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
