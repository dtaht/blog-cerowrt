+++
date = "2017-02-10T18:02:58+01:00"
draft = true
tags = [ "bufferbloat", "bugs", "flent" ]
title = "Bugs found by using Flent"
description = ""
+++

Modern networks are complex and handle a huge variety of traffic
simultaneously. Most network tests are relatively simple in comparison.
Flent's pioneering multi-variable stress test and analytical tools were
spurred by our advanced AQM and FQ research into building better
networks, but along the way it proved useful in finding and fixing a
multitude of bugs in device drivers and the network stacks themselves.
Here are a few examples.


The short period wifi glitch
----------------------------------

[Maddening short period wifi anomaly](/posts/disabling_channel_scans) - where
days of test data were *sometimes* permuted by a wifi channel scan and
only found by extending the length of the test to 5 minutes, from 1. It
sort of, kind of, showed up in the graphs, until I hit it longer and
found it was on a periodic interval, and tied to Network Manager's
default wifi scanning routine. It is now [fixed upstream](fixme) in
network manager and we should start seeing it appear in OSes in mid
2016, if not earlier.

It's kind of unknown how many other channel scanning daemons are broken
in this way. Perhaps the writers of such could run flent to find out.

Crypto-FQ bug
-------------

[fqbug](/posts/fq_bug)

Actually this bug defeated every tool we had available, and de-railed
the make-wifi-fast project for 4 long months.

Per Flow Lockout Bug on MVNETA
--------------------

The
[MVNETA multi-flow lockout bug](https://bugs.lede-project.org/index.php?do=details&task_id=294)
was a really good example of a bug that could only have been easily
diagnosed with flent. A simple single flow test would never
have found it. A multiflow test, that summarized the result, wouldn't
have shown it (one flow would have got all the bandwidth, the others
starved, but the test would have shown 1Gbit transfers)

So far as we know, it remains unfixed in millions of devices in
production hardware.

{{% figure src="https://bugs.lede-project.org/index.php?getfile=98" %}}

Analyzing GRO Impacts
---------------------

We *still* [have issues with GRO on at least one platform](fixme), and
still generally recommend it be turned off when trying to rate shape
ingress wherever it is an issue. Or more people could fix their GRO.

Measuring BQL improvements in the beaglebone
----------------------------

I tracked the improvements we made by
[Adding BQL to the beaglebone](/post/beaglebone_gets_bql) with flent.

{{% figure
src="http://snapon.lab.bufferbloat.net/~d/beagle_bql/bql_makes_a_difference.png"
%}}

The (ultimately 7 line!) patch went upstream and has been in the beaglebone ever since.
Sadly, most other arm and MIPs ethernet device maintainers have not been paying
attention to BQL.

Before:

{{% figure
src="http://snapon.lab.bufferbloat.net/~d/beagle_nobql/pfifo_nobql_tsq3028txqueue1000.svg"
%}}

After getting BQL to work and applying fq_codel, we increased total
throughput by a factor of 5, eliminated

{{% figure
src="http://snapon.lab.bufferbloat.net/~d/beagle_bql/fq_bql_tsq3028.svg"
%}}

You can generate your own flent comparison plots from grabbing the
pre-BQL data
[here](http://snapon.lab.bufferbloat.net/~d/beagle_nobql/) and the
post-data [here](http://snapon.lab.bufferbloat.net/~d/beagle_bql/)

http://snapon.lab.bufferbloat.net/~d/beagle_bql/pfifo_bql_tsq3028txqueue1000.svg

In

Mis-measuring Wifi Multicast
----------------------------------


WiFi Overbuffering on ath10k
----------------------------

QCA, in a dogged attempt to move everything into the firmware and
achieve the best possible benchmark result on the highest speeds...

... completely [destroyed network latency](fixme) in the low to medium speeds most users
can ordinarily achieve.

...

And that's why we mostly moved onto fixing the ath9k and mt72, which has
sufficiently thin firmware to make them work well at all rates normal
users can achieve.

Don't get me started on the current behaviors of other popular wifi chip
sets - the iwl and broadcom chips - the LTE chips - all the handheld
wifi chipsets - are horribly overbuffered for any but the fastest rates
they can achieve, with binary firmwares that we cannot fix.

An extremely simple technique -
[BQL](https://lwn.net/Articles/454390/) - is available to the designers
of all these firmwares to just buffer up enough to keep the hardware
busy at all rates, and punt the rest of the work to the OS, which can
manage things far more intelligently than you can do in firmware.

Wifi Airtime Fairness
---------------------


IPv6 instruction traps on MIPS
-----------------------

And spawned the still out of tree "unaligned access hacks".

IPerf3 UDP bursty bug
---------------------

While the ultimate analysis of this was not done with flent, the tcp
measurements it was contrasted with, were.


IPerf3 classification failure
-----------------------------


40 Gbit Linux Tuning
-----------------------------

ISP Overbuffering
=================


AQM and FQ analysis
-----------------------------

Not exactly bugs, but we comprehensively took apart every known AQM and
FQ system using various flent tests. This includes things like SFB, QFQ,
RED, ARED, SFQ, SFQ with various numbers of flows, SFQRED, Codel,
FQ_Codel and Cake.


Taking apart cable modem behaviors
------------------------------

{{% figure src="http://www.taht.net/~d/comcast_latency.png" %}} | {{% figure src="http://www.taht.net/~d/channel_scans_destroying_latency_under_load_for_10s.png" %}}

Flent was used to examine the behavior of a new generation of
cablemodems recently - but the hardware used to test it was too weak to
drive the tests!

Other research
==============

Evaluating Alternate TCPs
-------------------------

Examining the effects of increases in the TCP initial window
------------------------------------------------------------
