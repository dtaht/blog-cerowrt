+++
date = "2016-04-05T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat" ]
title = "Minstrel Wifi Rate Control"
description = ""
+++

The fundamental [minstrel](/papers/minstrel_sigcomm.pdf) paper never saw
academic publication.

Even if had been published, very few today seem to understand the
problems it addressed, how those problems have morphed over time, and
how new problems have arisen.

The minstrel related algorithms (minstrel-ht and minstrel-blues) have
seen continuous tweaks to update it for each new technology (it
pre-dates 802.11n), without much analysis.

Most research into wifi rate control has died, in part due to
inaccessabilty of the basic statistics about wifi transmit rates from
most proprietary firmwares.

I don't know how many 100s of millions of machines it's deployed on now,
and so far as I know it (well, minstrel-ht, the successor) still beat
most vendor rate control algorithms (It still seems better than
everything else I've looked at closely (for example, it's certainly
better than what's in marvell's usb wifi firmware based on some recent
testing)

The paper (which Andrew McGregor doesn't mind being distributed but
still hopes to publish) fills in some missing blanks as to how to do
wifi rate control better that so far I haven't seen in the liturature.

Recently the linux kernel gained support for exporting minstrel stats to
interested userspace applications and those are being used by batman and
others.

Minstrel's development pre-dates 802.11n aggregates, it pre-dates the
advances in queue theory led by [codel], and has long been in dire need
of an update to match modern conditions with massive numbers of clients
and interfering access points.
