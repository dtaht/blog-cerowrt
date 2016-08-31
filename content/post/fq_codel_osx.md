+++
date = "2016-08-29T12:02:58+01:00"
draft = false
tags = [ "wifi", "bufferbloat", "ath9k", "osx" ]
title = "FQ_codel'd WiFi intermediate queues verses OSX Mavericks"
description = "We got the best results ever with the new code, with OSX, with one glaring exception..."
+++

We do an awful lot of bufferbloat testing via Linux clients, nearly none with Windows, and only a little with OSX. Testing android, iOS devices, and chromebooks also, is on the agenda, as are a dozen other wifi chips - but we have limited resources, and generally hope that by widely publishing the concepts and code, others will join in. Here's a few tests using a Macbook Air (802.11ac wifi card) as a WiFi client of the [new fq_codel for ath9k wifi code](/tags/ath9k) running on an a positively ancient wndr3800 Access Point. If you haven't already seen the Linux <-> Linux results, they are [here](/post/a_look_back_at_cerowrt_wifi).

## Download throughput and latency from 1-24 streams

{{< figure src="/flent/fq_codel_osx/bandwidth_latency_bar.png">}}

Downloads were spectacular. I've never got >200Mbit wifi TCP downloads out of the wndr3800 hardware over the air before, and certainly not with an 8ms median RTT. I am writing off the falloff of the more intensive tests to random noise in the environment for now, but it could be some interaction with TCP reno.

{{< figure src="/flent/fq_codel_osx/ping_latency.svg" >}}

The "long tail" of delay variance was spectacular, also. On the 24
flow test I got a truly outstanding 31 packets in the WiFi aggregate -
also a new record. That's over 75% percent utilization of the basic
WiFi mac. I'd like to take this code and see what nastyness LTE-U will do to it.

## Uploads: slightly less spectacular

{{< figure src="/flent/fq_codel_osx/upload_ping_cdf.png">}}

(but they don't have fq_codel yet, and this is OSX Mavericks I'm testing with, which is very much out of date)

## A Quick set of comparisons with an ath9k Linux client

It also shows off how easily we can compare results using
[flent's](https://www.flent.org) data. Before flent existed, we'd have
had to pull apart captures, process data with awk, spit the results
into gnuplot, and hope for the best. The process for a single test
used to take *days*, now it's minutes.

(unfinished, sorry - it only takes minutes to compare the tests, but we're sorting out a bug as I write. Please check back later)

## Testing ECN worked out well

The TCP/ECN analytic portion of this post got so long I ended up putting
it into two other blog entries, one on the [factual ECN results](/post/ecn_fq_codel_wifi_airbook), and another [that devolved into an opinionated rant on the great ECN debates](/post/ecn_rant).

Net result: massive goodness. If you don't know what ECN is, you
aren't missing much, except maybe augmented reality, awesome
videoconferencing, and a possible perfect future of the Internet.

## Bi-directional fairness: WTF??

This result was so bad that I have no idea what to think.

{{< figure src="/flent/fq_codel_osx/rrul_be_sucks.svg" >}}

WTF?

{{< figure src="/flent/fq_codel_osx/rrul_be_wtf.svg" >}}

I'm going to put this one down and not think about it for a while. The
rrul test was the nastiest test I could devise in 2011. It was
expressly designed to blow up wifi - and it does - but this result was
totally unexpected, and I don't know the cause. Certainly we get badly
assymmetric behavior with Linux, also, regularly.

And the main rrul test - which tests the wifi hardware queues, hard,
sucks on everything I've ever tried - which we have a design to fix,
if not an implementation as yet.

It could be the new fq_codel code is broken somehow. It could be
Mavericks is broken somehow. In either case I need to go back and redo
a lot of A/B comparisons that I don't have time for right now - or
upgrade to a modern OSX like the darn thing nags me to do every day.

Maybe someone else will test OSX for me...

...

Now that we've shown tremendous improvements in wifi performance, with this
one glaring exception, under lab conditions, on both
[Linux](/post/a_look_back_at_cerowrt_wifi) and OSX, let's take a look
at [what happens when you have a lower wifi rate](/post/new_code_lower_rates_more_filling). To me, this is the most important set of benchmarks, because they reflect the kind of performance real users get in the real world.

Another digression: [What happens if you are bound by your ISP's rate, not the wifi rate?](/post/60mbit)

