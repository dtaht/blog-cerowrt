+++
date = "2016-10-12T10:02:58+01:00"
draft = false
tags = [ "ath9k", "wifi", "bufferbloat" ]
title = "Finally... the real net-next 4.8 fq_codel/airtime-fair ath9k results"
description = "Getting to this point took 4 long years..."
+++

When [experiments go awry](/post/mcs_rates/) - sometimes you learn
something. Doing the same thing over and over again expecting a
different result is a definition of insanity - doing a different thing
different ways, all the time, must be saner, right? Well, it was time
to try and more or less duplicate my original configuration, testing a
"genuine" fq_codel'd airtime fair AP, against the behavior of multiple
genuine WiFi clients, to see what happened.

My broken box is still borken! I pulled the odroid C2 out of
where it was, and made it the test driver, instead of the laptop. I've
proven to myself that I [get results out of it](/posts/odroid) that
are good to at least 200mbit, and that's all we need to test here. It
is running linux 3.14, which is a data point all in itself. Whenever I
get the other box repaired, we can go head to head with linux 4.4.

Topology before, where I was essentially testing the TCP path in the AP:

<pre>
laptop(AP) <-> Ath9k Wifi <-> OSX and Linux (ath10k)
</pre>
Topology now - where I'm testing an AP as a router:
<pre>
odroid c2 <-> ethernet <-> laptop(AP) <-> Ath9k Wifi <-> OSX and Linux (ath10k)
</pre>

## And... It works

{{< figure src="/flent/airtime-c2/osx-v-server-expected-totals.svg" >}}

~90Mbits at ~20ms latency is in line with other results I've had with
ath9k APs, also, (at HT20), so things look good here, and I can more
or less compare stuff with prior results with fewer qualms.

The results I'd got [using the AP as a server, last weekend](/post/mcs_rates) - are very dissimilar and puzzling. What this is is way more correct, now - in line with the theory, and in line with the experimental data.

{{< figure src="/flent/airtime-c2/would_that_be_so_bad.svg" title="AP station compared" >}}

Going back to that data, this AP as an AP test gets a good 40Mbits
more bandwidth than what I was getting driving the tests directly from
the AP. We have work to do on some tcp stack interactions
here. This result and those following, I think, begin to explain the
issues I was [having with OSX](/post/osx_unfairness) - using the AP as a
TCP target left bandwidth on the floor that OSX used up.

I hope there's something simple we can do to get bandwidth here back
in line with the AP result!

Still, I slide back in my chair and look at:

## Latency flat at all rates

{{< figure src="/flent/airtime-c2/latency_flat_at_all_rates_cdf.svg" >}}

... Looking at it... I have to wipe away a tear. When I first
started working on (what became) wifi, [back in 1996](http://www.rage.net/wireless/wireless-howto.html) - by 2002 we'd got
its latency and jitter were roughly in the same bounds (using SFQ),
typically under 15ms, and we thought [the answers so obvious](https://www.bufferbloat.net/projects/cerowrt/wiki/Wondershaper_Must_Die/)
that everybody would use them by default, and we never published the
work due to various contractual constraints. I wish I had plots and
packet captures from those days, not just a few blogs and legal
documents.

(Please forgive me for cutting things off at the 98th percentile. I
actually care a lot about outliers, and why they happen, and at some
point I'll return to talk of limiting retries, multicast and the
minstrel mis-behaviors.)

But, just sit with me, and admire that plot above for a while. (TODO: I need to
redo the tests with Linux 4.4, same configuration, for a comparison)

100s of millions of crappy APs have shipped since we started the
bufferbloat project. Billions of WiFi devices, also. 4 years ago, we'd
mostly worked out how to fix them, three years ago we went seeking
funding, two years ago good infrastructure started landing, and this
year...

We're finally regulating the stuff at the AP, again, properly.

{{< figure src="/flent/airtime-c2/os-v-server-expected-cdf-up.svg">}}

OK, enough navel gazing. What didn't we fix? Well, while we are
showing that the AP can regulate the behavior on the down from the AP,
the up from the clients can still be quite poor.

## Unmodified drivers - from the client results

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

At some future point - perhaps in the near future - I can bring the
new code online for a few clients, as well, to see what happens.

(I've already seen what happens. It's *lovely*. Trust me.)

## Side note: the effects of bandwidth asymmetry

Most wifi connections are highly asymmetric. You might be getting
mcs12 from the AP (because it has good antennas) and only mcs1 from
the client (because they don't). Here you can clearly see the effect
of asymmetry between the lowest and highest rates on TCP.

{{< figure src="/flent/airtime-c2/downloads_somewhat_bound_by_uplink_rate.svg" >}}

{{< figure src="/flent/airtime-c2/stilldontknowwhatosxdoesdifferent_down.svg" >}}

This is only testing a rate change on the AP, not the clients, but
further exploring bandwidth asymmetry will have to wait for another
day.

## Still... dancing!

{{< figure src="https://media.giphy.com/media/26BoElcdr7OiEHmfu/giphy.gif" >}}

We are finally holding latencies below 20ms at the median for Wifi rates
varying from 6mbits to 150mbits on the ath9k!

{{< figure src="/flent/airtime-c2/latency_flat_at_all_mcs_rates.svg" >}}

And this shows it, at no cost in bandwidth, and perfect sharing between two different wifi clients.

{{< figure src="/flent/airtime-c2/osx-v-server-expected-up.svg" >}}

Getting wifi down to no more than 30ms induced latency for four
stations was *my main goal* for the make wifi fast project. We've done
it! And: with hopefully (knock on wood) only a few bugs left to solve,
the code can all move upstream over the next two kernel releases.

I'm nearly out of funding, and very tired. I am massively grateful to
everyone on the make-wifi-fast mailing list and the bufferbloat
project members for all their help in getting this far - and huge kudos
belong to Toke, Felix, Tim, Michal, Johannes, who together, finally
figured out how to make the theory work.

There's still an [awful lot worthwhile left to do in the make-wifi-fast project](https://docs.google.com/document/d/1Se36svYE1Uzpppe1HWnEyat_sAGghB3kE285LElJBW4/edit#heading=h.3ankl68j6jjo)...

Toke's giving a talk on all this at the [openwrt summit this week](http://openwrtsummit.org/).

And I'm doing [the same at Linux Plumbers this november](https://linuxplumbersconf.org/2016/ocw/proposals/3963). See you there!

As happy as I am with these results, there's still the problems identified here to solve, we need to test at the lowest 2.4ghz rates, and with ht40 and adhoc mode, at the very least, over the next few weeks. There's tons more plots that can be pulled out of the flent datasets, as well - the [mcs stuff is here](/flent/mcs), and the [airtime tests are here](/post/airtime-c2).

The unofficial patch set that applies on top of net-next is [here](http://www.taht.net/~d/airtime-8/), which also has pre-built .deb files for ubuntum 16.04 LTS.

...

## Can we rip out even more latency than this from modern WiFi?

Let me return for a moment to an earlier plot.

{{< figure src="/flent/airtime-c2/would_that_be_so_bad.svg" >}}

Would it be *bad* to sacrifice 50% of your bandwidth (sometimes), in
order to get your wifi latency below 4ms? What if it cost only 20% of
your bandwidth, to get 4ms latency?

In order to make mu-mimo work effectively we need to shorten the txops
anyway. What if we do that to the ath9k first?

## Ripping out latency can be fun!

Believe it or not, we can probably rip out another 4-6ms from this
with tighter code and/or better firmware, and, if we are willing to
sacrifice bandwidth in favor of latency another 10ms on top of that.
We could get things, overall, down, to an increment of no more
than 2ms per station actively transmitting. The host result shows we
can get to 4ms latency, and that's a *good thing*.

That said, the earlier results show there's something wrong on
the local tcp stack's interface to wifi, and we have to poke into that.

