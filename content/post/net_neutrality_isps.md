+++
date = "2016-04-24T22:02:58+01:00"
draft = true
tags = [ "lab", "wifi", "bufferbloat" ]
title = ""
description = "You've killed netr"
+++

Patiently waiting for the rest of the world to catch up.

After you finish burning billions on massive mergers, could you also
go and improve your networks? You have overbuffered uplinks, and
massively overbuffered downlinks. Your wifi implementations are
poor. Your supplied equipment is often insecure and too infrequently
updated. Most of you make insane amounts of money on modem rentals,
can you please invest money into making those modems better over time?

A lot of the furor and frustation expressed to you by your customers,
about network flakyness, and that awful "buffering" error message and
net nuetrality meme, far too often has been driven by those customers'
*misconception* that the problems occur on your backbone - and while
they sometimes do, most often the problem is in the last mile, or in
the last few feet of *their* link.

You can help educate them, by directing tests to the dslreports web site, and encouraging them to replace their routers with something better.

More importantly *Even if you move the bandwidth sucking services
in-house*, you *will retain* the underlying buffering problems across
your edge connections. Your network services will remain flaky.

PLEASE: In your next RFP for equipment you intend to supply, specify RFC8290. Feel free to try something lighter weight, like RFC. Reduce your buffering in your head-ends to something sane. In your bandwidth shapers, try "cake". In your wifi gear, see "ending the anomaly", and specify something like that. (hint, all you need is recent linux or freebsd kernels and an appropriately modified device driver) And: find ways to regularly update your deployed base to new, faster, more secure router software.

Thanks. The network you save may be your own.

PS you've claimed that ending network neutrality will spur research
and investment, and if that's the cause of the bufferbloat project
struggling for so long on so little... well, there are a ton of people
that have worked to give away these solutions to your problems that ache
for a chance to deploy them at scale, and by default, on your networks.

You can find us on the bloat, cake, and make-wifi-fast mailing lists.
