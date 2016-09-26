+++
date = "2016-09-24T22:02:58+01:00"
draft = false
tags = [ "lab", "wifi", "bufferbloat", "hackerboards" ]
title = "Pine64 hackerboard fails to rrul"
description = "Cheaping out too much for the sake of science"
+++

The pine64 hackerboard features a quad core processor and a 1Gbit
capable mac, which puts it in a class where it could compete, in my
testbed, with the odroid c2, for various benchmarking duties.
Unfortunately, it cannot crack 200Mbit up on the rrul test, and is
based on Linux kernel 3.10. So, it joins the ashbin of devices I
cannot trust for reliable network measurements.

As near as I can tell the network driver does not implement BQL, and 
it does soft (GSO) TCP segmentation offloads, rather than hard.

{{< figure src="/flent/pine64/rrul_fq_codel_poor.svg" >}}

It does quite a bit better on the rrul with pfifo, achieving 160+Mbits
worth of uploads:

{{< figure src="/flent/pine64/rrul_better_with_pfifo.svg" >}}

Still it struggles with uploads in general:

{{< figure src="/flent/pine64/upload_bbr_pine64.svg" >}}

Downloads are better but still weird:

{{< figure src="/flent/pine64/weird_download_fq_codel.svg" >}}

And: for giggles, I hit it on an upload with [tcp bbr](/tags/bbr).

{{< figure src="/flent/pine64/pine64_fq_codeled_bbr.svg" >}}

The odroid c2 is still the winner - but has problems, too, that I need
to write up - and I've mostly reverted to using an apu2 from pcengines
to get "reliable" benchmarks. That said - understanding the behaviors
of real devices in real situations in the field, is very important.

I am bugged - of all the [hackerboards](/tags/hackerboards) I've
evaluated, only one had a toslink port - which I need in order to feed
my stereo - and I could never get that one to boot. Feeding things
through hdmi is unsatisfying - the screen save kicks in, interrupting
the song - or I have to leave the screen *on* - when I just want to
listen to the song.
