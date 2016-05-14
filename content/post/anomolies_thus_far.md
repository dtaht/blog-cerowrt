+++
date = "2016-05-06T18:02:58+01:00"
draft = false
tags = [ "wifi", "bufferbloat", "ath10k" ]
title = "Anomalies on wifi"
description = "On trying not to delude myself, or others..."
+++

[All quarter](/tags/bufferbloat), I've been evaluating all-new hardware
for the [sflab](/tags/lab). I was blind-sided by
[Michal Kazior](/author/Michal%20Kazior) actually producing a set of
[fq_codel patches that beat bufferbloat](/post/fq_codel_on_ath10k) on wifi at the right layer,
[on hardware I didn't have](/tags/ath10k), and I've had to scramble to
duplicate them on that hardware. The results were (mostly) beautiful -
and I allowed myself to [believe](/post/fq_codel_on_ath10k) [all](/post/ath10_ath9k_1)
[the good ones](/post/)... and not [all](post/cs5_lockout/) of
[the](/post/ath10_ath9k_1/) [bad](/post/ath10_ath9k_2) but... after the
excitement of actually getting a variety of tests last week done died
down however, it was time to tear apart the anomalies this weekend.

## Wifi Powersave

Powersaving messes up the plots and estimates as you'll see spikes in
the 120ms - 1 second range at the start or end of the test. Turning it off
universally is a good idea for testing - but powersave on or off had a
massive difference in bandwidth shown on [this test](/post/poking_at_powersave):

{{< figure src="/flent/wifi_powersave/symmetry2.svg" >}}

and thus needs to be considered as a problem to be solved in the real world.

And: On the other hand, sometimes those latency spikes are real.

{{< figure src="/flent/chip/reallatencyspike_probably.svg" >}}

I'm pretty sure, at this bandwidth, that the 2 second spike at this RTT
is an artifact of slow start going wildly out of control at the default
buffer size on the host.

I really hate what these spikes do to the automatic graph smoothing
algorithms in [flent](https://flent.org)... but I'd hate it even worse
if they were smoothed out entirely, as other researchers do. In
networking, and in wifi, especially, [the anomalies are important](/post/talks/engineering/)! It's
[the edge cases](/post/talks/engineering/) that are the most interesting.

## Periodic Bumps may have been a bug

I assumed the
[120s period bumps in throughput here](/post/predictive_codeling) were related
to a channel scan on the Linux hardware I was using.

I was partially right. The [OSX upload results](/flent/osx-qca-10.2-fqmac35-codel-5)
didn't have those *at all*, Linux is messed up.

{{< figure src="/flent/osx-qca-10.2-fqmac35-codel-5/noosxspikesupload.svg" >}}

Later on I observed the "accounts-daemon" process eating 100% of CPU for
long periods, periodically, on several of the Linux based test targets.
I'll have to go and disable that, but next time I plan to also be taking
some aircaps to "hear" what's going on in the air, also. It sure looks like
spikes on the AP side, though:

{{< figure src="/flent/osx-qca-10.2-fqmac35-codel-5/beaconsorchannelscaneor.svg" >}}

Furthermore the baseline tests had a periodic spike in latency, not a
decline in bandwidth.

*Update*: It's [due to the channel scan](/posts/disabling_channel_scans).

I disabled the accountsservice daemon universally anyway. There is no reason why it should eat so much cpu to do as little as it does.

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

Early results indicated [dql's estimator takes too long](/post/dql_on_wifi) - order 10s of
seconds - to find the right size at higher bandwidths.

This was [in stark contrast to an earlier patch set](/post/fq_codel_on_ath10k) that actually did
better in the first startup of a flow at higher rates - what was done differently there? [That
patch](/post/fq_codel_for_ath10k) used *rate control statistics* to get it's capacity estimate, which the author had to fake as
the ath10k has no easily available ones. The ath9k, and many other drivers, could use [minstrel](/post/minstrel)'s comprehensive statistics. To get these
into the fq_codel implementation for wifi would be easy - there's life in 802.11n yet!

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

I'd hoped to merely stress out the VI queue to get 1ms timings. [No such
luck](/post/cs5_lockout).

## [802.11e was broken on the ath10k 10.1 firmware](/post/cs5_lockout)

It worked semi-ok on the [10.2 firmware](/flent/qca-10.2), but still borken.

## UDP Flood management

A tester hit a major problem with udp floods going from 800mbit to
30mbit.

I've never hit that limit - I'm unable to crack 300mbit in the general
case.

Nor: in my universe - had I thought much about the impact of massively
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

[Candelatech's tests on the original drivers](http://www.candelatech.com/examples/ventana/ventana-tcp-codel-dl_1462569548/)
showed 4-10 seconds to service each of 64 active stations. Even if you
assume it's 6ms of backlog per station and 4 RTTs that still seems way
out of whack.

Michal did a bit of work on this, basically duplicating the service time problem::

{{< figure src="/flent/drr/10tothe5.svg" title="Driving 100 stations with baseline drivers = 10 sec of latency" >}}

He then had a go at adding a fq_codel like algorithm to manage per station service times much better:

{{< figure src="/flent/drr/newcode.svg" title="100 stations with alternate scheduler = 250ms of latency" >}}

In fact stations that have not asked for service in a while should get a
disproportionate number of slices in order to get into flow balance with
the others. Most of the time, on, for example, web traffic, that station will then
"go away" for seconds or minutes.

Getting the service time for 100 stations below 250ms kicked off a long discussion on the mailing list. 70ms to service this
many stations seamed feasible, but objections were raised as to the cost in bandwidth it would take.

## Better show what better congestion control means

In one string of the "good" tests, I'd forgotten completely that there
was a test running, and went off surfing the web... and my gf also started
watching Netflix on an AP on the same channel at one point... and the
low latency and congestion control was so good *I didn't notice the
tests were running*. (and neither did she!) :)

While these random events are hard to test for - they are great examples
of typical usage of wifi, and should get incorporated into more tests.

note: We used to use the chrome web page benchmarker for web stuff, but
it broke. Maybe they fixed it? 

Update: No. Dang it. Need to update the bug.

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

# Summary

We're showing that we can reduce queue-ing latency on wifi by [100ms or
more at 100mbits/sec](/post/ath10_ath9k_1). In fact, we can hold it to [20ms at
6mbits](/post/fq_codel_on_ath10k/),at [100mbits](/post/ath10_ath9k_1), or
[300mbits](/flent/osx-qca-10.2-fqmac35-codel-5), in the testing so far.

I think it is important to try everything possible to get it below 2ms,
at the relevant cost in throughput, in order to vastly improve
inter-station service times and make gaming and videoconferencing a more
pleasant experience on wifi. Only way I know how to get there is with
carefully managing all txops, transmit and receive, with something like
[airtime deficit round robin](/post/airtime_deficit_round_robin) and
per-station scheduling.

Why? [Because once you have bad latency, you're stuck with it](https://www.internetsociety.org/blog/2012/11/its-still-latency-stupid).
