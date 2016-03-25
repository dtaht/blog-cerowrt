+++
date = "2016-03-25T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat" ]
title = "Adapting DQL to wifi"
description = "Can the dynamic queue limits infrastructure in linux be adapted to wifi?"
author = "Michal Kazior"
+++

[This patch](https://www.mail-archive.com/linux-wireless@vger.kernel.org/msg21594.html) implements a very naive dynamic queue limits on the flat HTT Tx in the ath10k driver.

In some of my tests (using flent) it seems to reduce induced latency by orders of magnitude (e.g. when enforcing 6mbps tx rates 2500ms -> 150ms). But at the same time it introduces TCP throughput buildup over time (instead of immediate bump to max). More importantly I didn't observe it to make things much worse (yet).

I'm not sure yet if it's worth to consider this patch for merging per se. My motivation was to have something to prove mac80211 fq works and to see if DQL can learn the proper queue limit in face of wireless rate control at all.

Here's the [flent dataset for dql on wifi experiment](/flent/wifi/dql_for_wifi/dql.tar.tgz)

Here's a short description what-is-what test naming:
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

## Observations / conclusions:

 - DQL builds up throughput slowly on "veryfast"; in some tests it
doesn't get to reach peak (roughly 210mbps average) because the test
is too short

 - DQL shows better latency results in almost all cases compared to
the txop based scheduling from my mac80211 RFC (but i haven't
thoroughly looked at *all* the data; I might've missed a case where it
performs worse)

 - latency improvement seen on sw/ath10k_dql @ rate6m,fast compared to
sw/base (1800ms -> 160ms) can be explained by the fact that txq AC
limit is 256 and since all TCP streams run on BE (and fq_codel as the
qdisc) the induced txq latency is 256 * (1500 / (6*1024*1024/8.)) / 4
= ~122ms which is pretty close to the test data (the formula ignores
MAC overhead, so the latency in practice is larger). Once you consider
the overhead and in-flight packets on driver-firmware tx queue 160ms
doesn't seem strange. Moreover when you compare the same case with
sw/fq+ath10k_dql you can clearly see the advantage of having fq_codel
in mac80211 software queuing - the latency drops by (another) order of
magnitude because now incomming ICMPs are treated as new, bursty flows
and get fed to the device quickly.

 - slow+fast case still sucks but that's expected because DQL hasn't
been applied per-station

 - sw/fq has lower peak throughput ("veryfast") compared to sw/base
(this actually proves current - and very young least to say - ath10k
wake-tx-queue implementation is deficient; ath10k_dql improves it and
sw/fq+ath10k_dql climbs up to the max throughput over time)

To sum things up:
 - DQL might be able to replace the explicit txop queue limiting
(which requires rate control info)
 - mac80211 fair queuing works!

A few plots for quick and easy reference:


