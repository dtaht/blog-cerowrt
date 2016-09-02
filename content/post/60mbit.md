+++
date = "2016-08-30T12:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat", "ath9k", "osx" ]
title = "What happens if WiFi is NOT the network bottleneck?"
description = "WiFi"
+++


OSX is showing 4ms median latency under load with a "long" tail of only 2ms!
I haven't a clue how they achieved this! (I can start tearing apart
captures).

Well, if it were me, and I'd noticed a large proportion of bidirectional
traffic, I'd start clamping the maximum size of a txop to values less
than 4ms - 2ms strikes me as a good number - and take the bandwidth
hit shown here, vs a vs the predominantly up or download traffic shown
earlier in this blog entry.

This reduces the probability of having to retransmit (due to errors),
and shaves a good 10ms off the median and 30ms off the worst case
Linux result on the same test.

{{< figure src="/flent/fq_codel_osx/perfect_upload_download_result.svg" >}}

Still, I mean: *wow*.

The OSX folk are *very* sensitive to latency and jitter, due to their
heavy presence in video and audio marketplaces, common use of
videoconferencing services like facetime, focus on user experience,
and so on. They also have a staff, of about 1000 people, working on
various aspects of the wireless stack, with access to specifications
and to deep chip internals.

Most of the Linux folk (not me!) tend to be more sensitive
to achieving the best bandwidth possible, at any cost in (usually
unmeasured) latency, and have no such deep access to specs. :(.

I expect Apple is implementing the same or better algorithms we are,
in their next generation APs and wifi drivers, but Stuart's not
talking.

On the other hand, the wifi chip in the macbook air box is 802.11ac,
with very good antennas - at any given distance, an 802.11ac chip can
usually achieve one higher MCS rate, as the DSPs are better - even
when talking to 802.11n wifi.

I'll repeat this test with a ath10k enabled AP and client, but that
code seems to be moving backwards lately.

Lastly, the regular rrul result is one of the best I've ever seen.

{{< figure src="" >}}

