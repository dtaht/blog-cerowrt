+++
date = "2016-10-11T18:02:58+01:00"
draft = false
tags = [ "ath9k", "wifi", "bufferbloat" ]
title = "Finally the real ath9k results"
description = ""
+++

When experiments go awry - sometimes you learn something. Doing the
same thing over and over again expecting a different result is a
definition of insanity - doing a different thing different ways, all
the time, must be saner, right? Well, mental health aside, it was time
to try and more or less duplicate my original configuration, testing a
"genuine" fq_codel'd airtime fair AP, against the behavior of multiple
genuine WiFi clients, to see what happened.

But the broken box is still borken! I pulled the odroid C2 out of
where it was, and made it the test driver, instead of the laptop. I've
proven to myself that I [get results out of it](/posts/odroid) that
are good to at least 200mbit, and that's all we need to test here. It
is running linux 3.14, which is a data point all in itself. Whenever I
get the other box repaired, we can go head to head with linux 4.4.

Topology before. where I was essentially testing the TCP path in the AP

<pre>
laptop(AP) <-> Ath9k Wifi <-> OSX and Linux (ath10k)
</pre>
Topology now - where I'm testing an AP as a router:

<pre>
odroid c2 <-> ethernet <-> laptop(AP) <-> Ath9k Wifi <-> OSX and Linux (ath10k)
</pre>

## And... It works. Yes, Ghu! It's Working! It's actually working!

{{< figure src="/flent/airtime-c2/osx-v-server-expected-totals.svg" >}}

~90Mbits at ~20ms latency is in line with other results I've had with
ath9k APs, also, (at HT20), so things look good here, and I can more
or less compare stuff with prior results with fewer qualms.

{{< figure src="fixmecatdancing" >}}

The results I'd got [using the AP as a server, last weekend](/post/fixme) - are very dissimilar - and way more correct, now - in line with the theory, in
line with the experimental data.

{{< figure src="/flent/airtime-c2/would_that_be_so_bad.svg" title="AP station compared" >}}

Yet - that's a good 40Mbits more bandwidth than what I was getting
driving the tests directly from the AP, however. We have work to do on
some tcp stack interactions here. This result and those following, I
think, begin to explain the issues I was [having with OSX](/post/osx_winning).

I hope there's something simple we can do to get bandwidth here back
in line with the AP result!

I go back to this one, though:

## Latency flat at all rates

{{< figure src="/flent/airtime-c2/latency_flat_at_all_rates_cdf.svg" >}}

... And looking at it... I have to wipe away a tear. When I first
started working on (what became) wifi, back in 1996 - by 2002 we'd got
its latency and jitter were roughly in the same bounds (using SFQ),
typically under 15ms, and we thought the answers so obvious that we never
published the work. I wish I had plots and packet captures from
those days, not just a few blogs and legal documents.

(Please forgive me for cutting things off at the 98th percentile. I
actually care a lot about outliers, and why they happen, and at some
point I'll return to talk of limiting retries, multicast and the
minstrel mis-behaviors.)

But, just sit with me, and admire this for a while.  This is Linux 4.4,
same configuration.

fixme: mcs-old-driver

100s of millions of crappy APs have shipped since we started the
bufferbloat project.  4 years ago, we'd mostly worked out how to fix
them, three years ago we went seeking funding, two years ago good
infrastructure started landing, and this year...

We're finally regulating the stuff at the AP, again, properly.

{{< figure src="/flent/airtime-c2/os-v-server-expected-cdf-up.svg">}}

OK, enough navel gazing. What didn't we fix?

## Unmodified drivers - Down results

Both the client and osx box have unmodified ath10k drivers on these
tests, so getting a good set of results for those will help for
comparison when fixes land for those. (unless the lab changes
drastically again)

{{< figure src="/flent/airtime-c2/osx-v-server-down-expected.svg">}}

The OSX box tends to go asleep and sometimes take a while to start up,
so here you see the linux server getting started 5 seconds early, and
then the OSX box kicking in.

We're still getting a benefit from the more fq_codeled driver in the
AP - but there's not much - and because the latencies have grown so large,
and there isn't enough fair queuing, there's ping packet loss.

{{< figure src="/flent/airtime-c2/osx-v-server-expected-down-cdf.svg" >}}

## Asymmetry

Most wifi connections are highly asymmetric. You might be getting mcs12 from the AP (because it has good antennas) and only mcs1 from the client (because they don't). Here you can clearly see the effect of asymmetry between the lowest and
highest rates on TCP. 

{{< figure src="/flent/airtime-c2/downloads_somewhat_bound_by_uplink_rate.svg" >}}

{{< figure src="/flent/airtime-c2/stilldontknowwhatosxdoesdifferent_down.svg" >}}

This is only testing a rate change on the AP, not the clients, but further exploring bandwidth asymmetry will have to wait for another day.

I'm going to savor this for a while.

## Still... dancing!

We are finally holding latencies below 20ms at the median for Wifi rates
varying from 6mbits to 150mbits on the ath9k!

{{< figure src="/flent/airtime-c2/latency_flat_at_all_mcs_rates.svg" >}}


And this:

At no cost in bandwidth, and perfect sharing between two different
wifi clients.

{{< figure src="/flent/airtime-c2/osx-v-server-expected-up.svg" >}}

At even the lowest rate.

fixme


## Can we rip out even more latency from modern WiFi?

Let me return for a moment to an earlier plot.

{{< figure src="/flent/airtime-c2/would_that_be_so_bad.svg" >}}

Would it be *bad* to sacrifice 50% of your bandwidth (sometimes), in
order to get your wifi latency below 4ms? What if it was only 20%? or
10%? Or 70%?

In order to make mu-mimo work effectively we need to shorten the txops
anyway. What if we do that to wifi now?

The theory said it would. It did. Getting wifi down to consistent latencies
like this was my main goal for the make wifi fast project. And, I'm out
of funding, which means that taking this any further will have to rely
on the community.

Chart

## Ripping out latency can be fun!

Believe it or not, we can probably rip out another 4-6ms from this
with tighter code and/or better firmware, and, if we are willing to
sacrifice bandwidth in favor of latency another 10ms on top of that.
We could get things, overall, down, to an increment of no more
than 2ms per station actively transmitting. The host result shows we
can get to 4ms latency, and that's a *good thing*.

Rip out re-ordering

It will probably come at some sacrifice in bandwidth, but
which would you rather have.

Come rain, or movement, or interference, we should be able to hold
wifi latencies nearly constant - although there as yet a few edge
cases to explore with this code.

cdf plot of the ap latency across mcs rates