+++
date = "2016-04-02T18:02:58+01:00"
draft = false
tags = [ "wifi", "bufferbloat", "ath10k" ]
title = "Adapting DQL to wifi"
description = "Can the dynamic queue limits infrastructure in linux be adapted to wifi?"
author = "Michal Kazior"
+++

[This patch](https://www.mail-archive.com/linux-wireless@vger.kernel.org/msg21594.html)
implements a very naive dynamic queue limits on the flat HTT Tx in the
ath10k driver. Some information on
[how DQL works is here](https://lwn.net/Articles/469651/). It is
currently used effectively as part of [BQL](https://lwn.net/Articles/454390/) for many ethernet, not
wifi, drivers.

...

In some of my tests (using flent) it seems to reduce induced latency by orders of magnitude (e.g. when enforcing 6mbps tx rates 2500ms -> 150ms). But at the same time it introduces TCP throughput buildup over time (instead of immediate bump to max). More importantly I didn't observe it to make things much worse (yet).

I'm not sure yet if it's worth to consider this patch for merging per se. My motivation was to have something to prove mac80211 fq works and to see if DQL can learn the proper queue limit in face of wireless rate control at all.

Here's the
[flent data for dql on wifi experiment]( http://kazikcz.github.io/dl/2016-04-01-flent-ath10k-dql.tar.gz) if you would like to poke around the dataset.

Here's a short description what-is-what test naming:
```
- sw/fq contains only txq/flow stuff (no scheduling, no txop queue limits)
- sw/ath10k_dql contains only ath10k patch which applies DQL to driver-firmware tx queue naively
- sw/fq+ath10k_dql is obvious
- sw/base today's ath.git/master checkout used as base
- "veryfast" tests TCP tput to reference receiver (4 antennas)
- "fast" tests TCP tput to ref receiver (1 antenna)
- "slow" tests TCP tput to ref receiver (1 *unplugged* antenna)
- "fast+slow" tests sharing between "fast" and "slow"
- "autorate" uses default rate control
- "rate6m" uses fixed-tx-rate at 6mbps
- the test uses QCA9880 w/ 10.1.467
- no rrul tests, sorry Dave! :)
```
*april 11, note* - I am in progress in regenerating the graphs, excuse
the broken links below. The [original plots can be found here](http://imgur.com/a/TnvbQ)

Dave commented that "testing with rrul is pointless as yet. Although
interesting to have as a baseline, [rrul](http://www.bufferbloat.net/projects/codel/wiki/RRUL_Rogues_Gallery) will end up stressing
out the unchanged wifi card's driver more than what you are actually testing".

## Observations / conclusions:

{{< figure src="/flent/dql_on_wifi.svg" >}}

 - DQL builds up throughput slowly on "veryfast"; in some tests it
doesn't get to reach peak (roughly 210mbps average) because the test
is *too short*.

{{< figure src="/flent/dql_on_wifi.svg" >}}

 - DQL shows better latency results in almost all cases compared to
the txop based scheduling from my mac80211 RFC (but I haven't
thoroughly looked at *all* the data; I might've missed a case where it
performs worse)

{{< figure src="/flent/dql_on_wifi.svg" >}}

 - latency improvement seen on sw/ath10k_dql @ rate6m,fast compared to
sw/base (1800ms -> 160ms) can be explained by the fact that txq AC
limit is 256 and since all TCP streams run on BE (and fq_codel as the
qdisc) the induced txq latency is
$ 122ms = 256 \times {(1500 \over {(6 \times 1024 \times 1024 \over 8)) \over 4)} $

which is pretty close to the test data (the formula ignores
MAC overhead, so the latency in practice is larger). Once you consider
the overhead and in-flight packets on driver-firmware tx queue 160ms
doesn't seem strange. Moreover when you compare the same case with
sw/fq+ath10k_dql you can clearly see the advantage of having fq_codel
in mac80211 software queuing - the latency drops by (another) order of
magnitude because now incoming ICMPs are treated as new, bursty flows
and get fed to the device quickly.

{{< figure src="/flent/dql_on_wifi.svg" >}}
 - slow+fast case still sucks but that's expected because DQL hasn't
been applied per-station

{{< figure src="/flent/dql_on_wifi.svg" >}}
 - sw/fq has lower peak throughput ("veryfast") compared to sw/base
(this actually proves current - and very young least to say - ath10k
wake-tx-queue implementation is deficient; ath10k_dql improves it and
sw/fq+ath10k_dql climbs up to the max throughput over time)

To sum things up:
 - DQL might be able to replace the explicit txop queue limiting
(which requires rate control info)
 - mac80211 fair queuing works!

[Let's look closer](/post/dql_on_wifi_2) at the effects of each part of the patch - dql, fq, and fq_codel.
