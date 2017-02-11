+++
date = "2017-02-11T19:02:58+01:00"
draft = true
tags = [ "bufferbloat", "bugs", "flent" ]
title = "Bugs found by using Flent"
description = "You too, can build better networks by using better
diagnostic tools"
+++

I've long hoped that more system administrators and developers began to
adopt [Flent](https://flent.org) - the "Flexible Network Tester", as a
new tool in their toolbox to diagnose their network problems.

Modern networks are complex and handle a huge variety of traffic
simultaneously. Most network tests are relatively simple in comparison,
and only test one variable at a time, rather than as many as possible in
a repeatable way. Flent's pioneering multi-variable stress test and
graphical analytical tools were spurred by our advanced AQM and FQ research into
building better networks, but along the way it has proved useful in
finding and fixing a multitude of bugs in device drivers and the network
stacks themselves.

Here are a few examples of bugs we've found and fixed, using flent. We
have a metric ton of data using flent published [here](/flent/). If you
have the flent plug-in installed in your browser, click away!

Per Flow Lockout Bug on MVNETA
--------------------

The
[MVNETA multi-flow lockout bug](https://bugs.lede-project.org/index.php?do=details&task_id=294)
was a really good example of a bug that could only have been easily
diagnosed with flent. A simple single flow test would never
have found it. A multiflow test, that summarized the result, wouldn't
have shown it (one flow would have got all the bandwidth, the others
starved, but the test would have a total 1Gbit transfer. Ship it!)

{{% figure src="https://bugs.lede-project.org/index.php?getfile=98" %}}

So far as we know, it remains unfixed in millions of devices in
production hardware - things like the linksys ac1200 series.

The short period wifi glitch
----------------------------------

The [maddening short period wifi anomaly](/post/disabling_channel_scans)
comes to mind. *Years* of test data were *sometimes* permuted by a wifi
channel scan. I only found the problem later by comprehensive review of
the (by then enormous) flent dataset and by extending the length of the
test to 5 minutes, from 1.

{{% figure src="http://blog.cerowrt.org/flent/channel_scan/channelscan.svg" %}}

This sort of, kind of, showed up in the graphs sometimes. In the end -
[admittedly after some ranting](https://plus.google.com/u/0/107942175615993706558/posts/WA915Pt4SRN) -
the bug  wasn't the device driver, or OS - we tied to Network Manager's default
wifi scanning routine. It is now
[fixed upstream](https://bugzilla.gnome.org/show_bug.cgi?id=766482) in
Network Manager and we should start seeing it appear in OSes in mid
2016, if not earlier.

While you might consider this as: "oh a just bug in the science
experiment" - even though *we* fixed it, by re-running our experiments -
this channel scan behavior is nasty in the real world.... It's not so
much "oh that bug messed up my experiment" - than - "oh, *that's* one of
the bugs messing up the wifi world"!

It's kind of unknown how many other channel scanning daemons are broken
in this way. There are probably more than a few wifi drivers that do it
badly too. Perhaps the writers of such could run flent for long tests to
find out?


The Crypto-FQ bug
-------------

The [fqbug](/post/crypto_fq_bug) defeated every tool we had available, and
de-railed the make-wifi-fast project for 4 long months, despite tons and
tons of flent tests. We validated we got it right by comparing WPA2 crypted
and unencrypted test runs, using flent. (the data is around here somewhere)

In the future, if ever you see a tcp loss and seqno reordering plot like
this:

{{% figure src="http://localhost:1313/flent/crypto_fq_bug/tsde.png" %}}

Say wisely: "I think your WiFi crypto IV is out of order".

-- You'll come across like a *genius*.

Analyzing GRO Impacts
---------------------

GRO - Generic Receive Offload - is a less than well-conceived network
optimization method that applies mainly to single flow benchmarks - not
the real world of multiple flows. I tend to think that the mad spread of
GRO - especially software GRO - is driven by people running single flow
benchmarks. It imposes serious constraints and complexity on the receive
path and has been the source of more bugs than I care to remember.

And yet, it's still helpful at higher speeds in some scenarios. At lower
speeds - well,
[cake](https://www.bufferbloat.net/projects/codel/wiki/CakeTechnical/)
was developed in part by our desperate attempt to mitigate the impact of GRO in our
IW10 world on slow internet links.

We *still*
[have issues with GRO on at least one platform](https://forum.lede-project.org/t/issue-with-ipv6-6in4-and-sqm/1348),
and still generally recommend it be turned off when trying to rate shape
ingress wherever it is an issue. Or more people could fix their GRO.

There are now options in Linux that allow for limiting GRO sizes on a
per interface basis.

Route flaps and triangular routing
--------------

I still haven't returned to looking at [this](/post/babel_half_fail) in
more detail. We had multiple other bugs to deal with at the time. But it
was interesting to watch how the bandwidth available for various paths evolved
through flent's load tests:

{{% figure
src="http://blog.cerowrt.org/flent/babel_half_fail/babel_half_fail.svg" %}}

More system admins should look at what happens to their backup link
when the primary one fails over to it, long before it fails. Flent's
rtt_fairness tests are really good for this.

Blowing up the BattleMesh Network
=================================

2 years ago, we thoroughly blew up the
[Battlemesh](http://battlemesh.org/) V8 conference network with flent:

{{% figure src="http://docs.battlemesh.org/_images/8-streams-cdf.svg" %}}

We showed that bufferbloat effects in "modern" wifi [violated the
assumptions of every mesh network routing protocol that exists](http://docs.battlemesh.org/v8/3-blowing-up-the-network.html),
as well as the tcp stacks themselves. It was great fun.

I look forward to going back again this year, now that wifi has been so
vastly improved. I'm sure we'll break even more stuff, differently, this
time!

Mis-measuring Wifi Multicast
----------------------------------

One of the tools ("airtime-pie-chart") we used for measuring multicast - when combined with
the data from flent - and packet captures - didn't seem to be accurate enough.

It turned out it was filtering out multicast probes and beacons as
unimportant. Well, filtering them out left 10% of the data unaccounted
for, and over 60% in some other tests we did! Multicast in wifi is a BIG
problem, that people have been filtering out as "noise" - or trying
desperately to eliminate useful multicast entirely....

This is improved in this
[airtime-pie-chart repo upstream](https://github.com/dtaht/airtime-pie-chart),
but we need to do a lot more work to look at multicast in wifi better
with stress tests like uftpd, mdns, and so on.


WiFi Overbuffering on 802.11ac ath10k chipset
----------------------------

QCA, in a dogged attempt to move everything into the firmware and
achieve the best possible benchmark result on the highest speeds...

... completely [destroyed network latency](/post/rtt_fair_on_wifi/) in the low to
medium speeds most users can ordinarily achieve.



While we developed the make-wifi-fast fixes to address this, and could
well be addressed in future versions of their firmware, so far, they
have not...

And that's why we mostly moved onto fixing the ath9k and mt72, which has
sufficiently thin firmware to make them work well at all rates normal
users can achieve.

It's not just QCA getting it so wrong...

don't get me started on the current behaviors of other popular wifi chip
sets - the iwl and broadcom chips - the LTE chips - all the handheld
wifi chipsets - and all the DSL chipsets - are horribly overbuffered for
any but the fastest rates they can achieve, with binary firmwares that
we cannot fix.

Seemingly, every other wireless benchmark in the field today thinks
servicing 100 stations with 10 seconds of latency is desirable. They
look at the summary data (the bandwidth average) and not to the
increasing uselessness of the link.

{{% figure src="/flent/drr/10tothe5.svg" %}}

Measuring BQL improvements in the Beaglebone Black
----------------------------

An extremely simple technique -
[BQL](https://lwn.net/Articles/454390/) - is available to the designers
of all these firmwares to just buffer up enough to keep the hardware
busy at all rates, and punt the rest of the work to the OS, which can
manage things far more intelligently than you can do in firmware.


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
throughput by a factor of 3, and reduced induced latency and jitter by a factor of 20.

{{% figure
src="http://snapon.lab.bufferbloat.net/~d/beagle_bql/fq_bql_tsq3028.svg"
%}}

You can generate your own flent comparison plots from grabbing the
pre-BQL data
[here](http://snapon.lab.bufferbloat.net/~d/beagle_nobql/) and the
post-fix-data [here](http://snapon.lab.bufferbloat.net/~d/beagle_bql/).


Wifi Weirdnesses overall
------------------------

I don't want to get into all the other weird behaviors we found in wifi. [Here](/post/anomolies_thus_far/).

Wifi Airtime Fairness
---------------------

There is so much written on this subject at this point that I'll just
point you at the [lwn article](https://lwn.net/Articles/705884/) and
[Toke's blog](https://blog.tohojo.dk/), and back at the
[tags](/tags/wifi) on this blog for it.

All (of the 10s of thousands) of the flent test data runs will be
[here](https://tohojo.hotell.kau.se/airtime-fairness/) after the paper
is published. Maybe, in poking at it, you'll find something wrong in
wifi that we didn't. Boy... Wifi data is noisy, and we found it
necessary to make 30+ test runs of every possible variable - and
parallelize flent to handle looking at all those test runs at the same
time!

All that speed Toke added to flent makes using flent to browse your
results a real joy, especially on multicore architectures. Also the
keyboard accellerators came out of that effort, so you can switch
between datasets and plot types rapidly, and combine data from hundreds
of tests if you so choose without having to wait an eternity.

There is yet more to come while Toke takes apart wifi rate control.

We could *never* have done this level of work without flent.

IPv6 instruction traps on MIPS
-----------------------

I have a long story and data about the months we spent on kicking the
last unaligned access traps out of the mips architecture in the network
stack. This spawned still out of tree "unaligned access hacks" in
openwrt, lede, and elsewhere.

Found by running flent while observing the "burps" the unaligned
accesses were causing on the flow. The data on this, unfortunately, is
on some hard drive somewhere I can't find.

IPerf3 UDP bursty bug
---------------------

There was a nasty mis-conception of how to flood with udp correctly for tests
buried deep in iperf3, and no doubt other tools that use udp flooding.
Aaron Wood went deeply into the
[Millabursts in IPerf3](http://burntchrome.blogspot.com/2016/09/iperf3-and-microbursts.html)
in a wonderfully enlightening string of blog entries.

While the ultimate analysis of this was not done with flent, the TCP
measurements it was contrasted with, were.

He's also posted many blogs of his attempts to optimize his ISP's link,
and explore various AQM technologies. Here's [a four-parter](http://burntchrome.blogspot.com/2014/05/fixing-bufferbloat-on-comcasts-blast.html).

IPerf3 classification failure
-----------------------------

For 5 years I have been perpetually confronted by people doing
benchmarks in iperf claiming that their QoS worked... when I was doing
flent tests showing they were wrong. I finally got fed up and poked into
iperf3 myself, to find that you could *specify* QoS values - but how you did so
was confusing, and in versions of iperf prior to the one just released jan 2016,
didn't set actually the TOS value at all - and in the version just released -
only sets it on the local server, not the remote.

Flent has *always* had a QoS test that worked, that set the TOS correctly on
both sides, using netperf.

After the next version of Iperf comes out, hopefully those that think
their QoS implantation actually works, will be half enlightened.

In the meantime, here's [this patch for iperf3 that at least makes
specifying a QoS value saner](https://github.com/esnet/iperf/pull/508).
I haven't looked into how to set it correctly on both sides yet.

40 Gbit Linux Tuning
-----------------------------

Jesper has used flent extensively in trying to rip nanoseconds out of
the
[Linux receive path](http://netoptimizer.blogspot.com/2014/10/unlocked-10gbps-tx-wirespeed-smallest.html),
although I can't find the specific blog post with flent graphs here.

ISP Overbuffering
=================

Much of our earlier work on overbuffered networks was benchmarking the
ISPs (google for netperf-wrapper or flent). We moved to fixing
individual network cards, and most recently, wifi.

AQM and FQ analysis
-----------------------------

Not exactly bugs, but we comprehensively took apart every known AQM and
FQ system using various flent (then called netperf-wrapper)tests. This
includes things like SFB, QFQ, RED, ARED, SFQ,
[SFQ with head drop](https://www.bufferbloat.net/projects/cerowrt/issues/332/,
)SFQ with various numbers
of flows, and later on SFQRED, Codel, FQ_Codel and Cake.

Especially, we had a lot of data on how htb was misbehaving on
GRO/TSO/GSO at the time in linux kernel 3.3, and what life was like
before BQL.

Most of this earlier data was lost when the [lab got stolen](/tags/lab).
:( At the time we were using packet captures rather than flent traces,
and had hundreds of gbytes of data that needed to be stored... somewhere.

Taking apart cable modem behaviors
------------------------------

{{% figure src="http://www.taht.net/~d/comcast_latency.png" %}}

Flent was used to examine the behavior of a new generation of
cablemodems recently - but the hardware used to test it was too weak to
drive the tests properly!


Conclusion
==========

You can find out *really* interesting things about your network by using
[flent](https://flent.org). Give it a shot. You won't regret it.

The network you save might be your own.
