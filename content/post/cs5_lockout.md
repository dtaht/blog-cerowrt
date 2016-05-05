+++
date = "2016-05-05T10:02:58+01:00"
draft = false
tags = [ "wifi", "ath10k" ]
title = "Turning on wifi QoS often creates worse QoS"
description = "Lies, damn lies... and QoS"
+++

When I [specified](/fixme) the [flent](https://flent.org) [rrul test](/fixme) - I designed it to break
everything I knew *then* was wrong in wifi. In particular, it breaks
most 802.11e QoS implementations, thoroughly. For four years now, in
nearly every presentation, I kept showing graphs showing the horrific
impact of flooding all four queues, on every OS (windows, mac, linux),
but I've never got around to thoroughly explaining all the bad behavior
I was showing. I'm still not going to do that here, I'm going to show a
"new" bug that happens merely when trying to use 4 flows through the
802.11e VI queue.

{{< figure src="/flent/cs5lockout/cs5.png" title="120 seconds locked out">}}

This test is supposed to start all 4 flows *simultaneously*. Instead
they start, then 3 get locked out with the VI queue in use. (the
diffserv CS5 marking is mapped to the VI queue in Linux). It sure is a
pretty plot, though! Unintentional art.

This doesn't happen so much on the CS0 (best effort) queue, where if you
squint you can see all the flows startup at the same time and getting
roughly their fair share of the bandwidth, 'cause if it did, someone
would have noticed and fixed it!

{{< figure src="/flent/cs5lockout/cs0.png" title="CS0 (best effort) behavior is sane" >}}

I surmise that most test tools that try setting the TOS bits on wifi
send one flow through it, verify that the right queue was used, and move
on, rather than subject it to the same range of tests the best effort
(CS0 queue) gets.

The loss in throughput and increase in latency periodically every 2
minutes is also interesting in the CS0 plot. Beacon? Scan? Related??

(All of these tests are a reminder that other factors can mess up short
duration tests, and while a 40 or 60 second test is often "good enough",
we should always do something for 6-10 minutes to make sure we are
getting consistent results. As for shooting myself in the foot, for
example, I just did a whole bunch of tests that were 5 minutes long,
that would not quite catch this period, most of the time. I am now bumping up my
more exhaustive tests to 10 minutes, universally.)

...

Here you can see more closely those flows starting, then one flow
grabbing all of the queue.

{{< figure src="/flent/cs5lockout/cs5_lockout.png" title="5 sec good - rest bad" >}}

This test was against the current mainline QCA firmware:

```
[    6.317121] ath10k_pci 0000:04:00.0: firmware ver 10.2.4.70.9-2 api 5 features no-p2p,raw-mode crc32 b8d50af5
```

with this [hostapd configuration file](/flent/cs5_lockout/hostapd.conf).

My theory here is that the rate controller or something else is not
calculating the size of the VI TXOP properly.

I've seen behavior like this before, elsewhere. It could also very well
be [the ath9k on the other side getting out of sync](https://lists.bufferbloat.net/pipermail/make-wifi-fast/2016-April/000506.html), too...

I'm going to run a [test of the factory firmware](/post/ath10k_ath9k_2) overnight, disabling the
gnarly CS1,CS5,CS6 tests until I can watch over them..

This test series [started here](/post/ath10k_ath9k_1). Test result data for
this run is [here](/post/flent/cs5_lockout/). The overall thrust of what
we're tackling is [here](/tags/ath10k).
