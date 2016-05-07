+++
date = "2016-05-06T18:02:58+01:00"
draft = false
tags = [ "wifi", "bufferbloat", "ath10k" ]
title = "Anomalies on wifi"
description = "On trying not to delude myself, or others..."
+++

[All month](/tags/bufferbloat), I've been evaluating all-new hardware
for the [sflab](/tags/lab), and I was blind-sided by
[Michal Kazor](/authors/fixme) actually producing a set of
[patches that worked](/post/fixme),
[on hardware I didn't have](/tags/ath10k), and I've had to scramble to
duplicate them. The results were (mostly) beautiful - and I allowed
myself to [believe](/post/fixme) [all](/post/fixme)
[the good ones](/post/fixme)... but... after the excitement of actually
getting a variety of tests last week done died down however, it was time
to tear apart the anomalies this weekend.

Note: This post isn't finished yet, I have a ton of links to add and graphs.

## Wifi Powersave

Powersaving messes up the plots and estimates as you'll see spikes in
the 120ms-1second range at the start or end of the test. Turning it off
universally is a good idea for testing - but powersave on or off had a
massive difference in bandwidth shown on [this test](/post/poking_at_powersave), and
thus needs to be considered as a problem to be solved in the real world.

{{< figure src="/flent/powersave/banddiff.svg" >}}

And:

On the other hand, sometimes those latency spikes are real.

{{< figure src="/fixme" >}}

I'm pretty sure, at this bandwidth, that the 2 second spike at this RTT
is an artifact of slow start going wildly out of control at the default
buffer size on the chip.

## Periodic Bumps may have been a bug

I assumed the
[120s bumps in throughput here](/post/predictive_codelling) were related
to a channel scan on the Linux hardware I was using.

I was wrong. The [OSX results](/flent/osx-qca-10.2-fqmac35-codel-5)
didn't have that. Later on I observed a process eating 100% of cpu for
long periods, periodically, on several of the Linux based test targets.

Furthermore the baseline tests had a periodic spike in latency, not a decline.

## How much room is there in a TXOP?

I don't have good (even theoretical) data on how 802.11n and 802.11ac
*could* behave at various TXOP sizes! Inter-frame spacings, AMPDUs,
AMDSUs, retries, rate control, OS latency, driver latency, and the
implementation of the more hairy aspects of the 802.11 standard (you
can, for example, wedge real packets into a reply to a sender's txop
that still has room in it), all factor into the spreadsheet.

All most people (including me) "know" is that wifi never gets close to
the rated throughput of the related standard.

At best you get somewhere between half and 1/4th that, on stupid single
station/single AP benchmarks. The real world results are vastly worse
than that.

## Do more multi-station tests

Wifi benchmarks (including mine) that don't test for performance with
multiple stations present should be depreciated.

With more than one station present, you can, should, and must reduce
inter-station service time.

This will reduce the headline bandwidth by... don't know. What's a
desirable result?

It would be nice if stations noticed they were not getting much airtime
and reduced their attempts to get it (applying congestion control to
themselves), and optimized the size of their TXOPs and the size of their
requests dynamically.

* If it is taking 10ms to get the media, take 5ms to accumulate some
packets to wedge into that txop.

* If you already have a txop in the hardware and you know utterly it's
  going to take 3ms to transmit it on a good day with a tailwind, don't put in any more for 2.5ms.

APs have means to adjust the EDCA parameters dynamically, making it
possible to enforce these limits on stations paying attention to it. I
believe some enterprise APs do twiddle with this in the beacon.

This does not help in IBSS mode where the game theory is like the
prisoners game, if you ask for less, you lose compared to the greedy
prisoner, but if all the prisoners ask for the max, everybody loses.

As near as I can tell the intent of the 802.11 wg standard was to
but nobody could agree on a correct implementation, waved hands, and
moved on.

Section X.Y.Z of the standard says

```
fixme
```

(italics mine)

## Driving tests directly was bad

When I tried to fire up flent directly on the AP, results plummeted from
100s of megabits to 16. Sure, running tests directly on the typically
very cpu and cache limited AP is stupid, but...

## Lower Throughput vs lab results

Flent has a long standing problem with not counting the measurement flows, nor tcp acks,
as part of the result. The size of the measurement flow *matters* at low
rtts or in comparisons with higher rtts.

Early results indicated dql's estimator takes too long - order 10s of
seconds - to find the right size at higher bandwidths.

This was in stark contrast to an earlier patch set that actually did
better in the first startup of a flow - what was done differently there?

## CPU over-usage

This sparked off a huge discussion on the mailing list, culminating with
2 major modifications to fq_codel itself to make it better able to
handle udp floods on cheap hardware.

## Two station tests

The mac achieved 280 Mbits of throughput under load, the competing Linux
box, only 3-4Mbit. This contrasts badly to the 90+Mbits the same ath9k
Linux station could achieve on an un-congested channel. (On the other
hand it should make OSX 802.11ac users happier).

What is the "right" answer? A simplistic one would be each station
should get half of what they got before, minus the difference in
overhead due to framing. So 30-40Mbit for the slow station seems more
like a "right" answer, and 120-150Mbit for the fast one in this case.

... but I don't know what the framing overhead number is, nor why the
osx box out-competed the Linux one so much. Yet. A simple test, first
reducing the max txop from 5.7ms to 5,4,3,2,1,and as low as it can go,
for each technology, would be helpful.

## [802.11e was broken on the ath10k 10.1 firmware](/post/cs5_lockout)

It worked semi-ok on the [10.2 firmware](/flent/qca-10.2), but still borken.

## UDP Flood management

A tester hit a major problem with udp floods going from 800mbit to
30mbit.

I've never hit that limit - unable to crack 300mbit in the general case-
nor in my universe - had I thought much about the impact of massively
in-elastic traffic (mae culpa) on these algorithms.

We've come up with some ways to make
[aqm's respond more sanely to fragmented packets](/fixme-mailinglist), and
[drop more aggressively on overload to save on cpu](https://github.com/lede-project/staging/pull/11),
and tuned openwrt to suit.

It was a good week, that way. I wish we'd got around to it last year.

Simulating fragments was easy - it's iperf's default mode for udp!

```
iperf3 -u -l 1450 doesn't fragment
iperf3 with no -l does - and that result was fascinating
```

## Station service times

Wifi APs MUST try to provide a modicum of service to all stations in
minimum time. They don't.

[Candelatech's tests](/fixme) showed 4 seconds to service each of 64 stations. Even if you assume it's
6ms of backlog per station and 4 RTTs that still seems way out of wack.

In fact stations that have not asked for service in a while should get a
disproportionate number of slices in order to get into flow balance with
the others. Most of the time, on, for example, web traffic, that station will then
"go away" for seconds or minutes.

## Better show what better congestion control means

In one string of the "good" tests, I'd forgotten completely that there
was a test running, and went off surfing the web and my gf also started
watching netflix on an AP on the same channel at one point... and the
low latency and congestion control was so good *I didn't notice the
tests were running*. :)

While these random events are hard to test for - they are great examples
of typical usage of wifi, and should get incorporated into more tests.

note: We used to use the chrome web page benchmarker for web stuff, but
it broke. Maybe they fixed it?

Note: Add in the tcp_square_wave tests to the next round. Maybe add a 3
flow test like Grenville is using.

Note: Test with a steady netflix like background load on another channel.

Most flows are NOT greedy for long times

I'm making the same mistakes others make by focusing on bandwidth,
rather than per-service time, but baseline results for all this new
hardware were needed to get a grip on things like cpu usage and genuine
bugs. I still need to get up to 800mbits, somehow, incorporate 3x3
antennas, catch up on devices that are trying to add MU_MIMO capability,
but we have a long way to go as yet.

## Some better tests in the future

* use the chrome web page benchmarker again
* add tcp square wave tests to show the improved congestion control better
* add isochronous ping
* disable powersave
* DON'T use wmmm in future tests

# Summmary

we're showing that we can reduce queue-ing latency on wifi by 100ms or
more at 100mbits/sec. In fact, we can hold it to 20ms at 6,100, or
300mbits, in the testing so far.

I think it is important to try everything possible to get it below 2ms, at the relevant cost
in throughput, in order to vastly improve inter-station service times.
Only way I know how to get there is with carefully managing all txops,
transmit and receive, with something like
[airtime deficit round robin](/post/airtime_deficit_round_robin) and
per-station scheduling.
