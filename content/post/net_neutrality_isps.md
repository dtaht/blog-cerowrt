+++
date = "2018-06-19T22:02:58+01:00"
draft = false
tags = [ "network neutrality", "wifi", "bufferbloat" ]
title = "ISPs: Please deploy bufferbloat fixes"
description = "Network neutrality is dead. Can we have a better network now?"
+++

Dear ISP industries:

After you finish burning billions on massive mergers, could you also
go and improve your networks? You have [overbuffered uplinks](http://www.dslreports.com/speedtest/results/bufferbloat?up=1), and
[massively overbuffered downlinks](http://www.dslreports.com/speedtest/results/bufferbloat). Your [wifi implementations are
poor](https://www.usenix.org/system/files/conference/atc17/atc17-hoiland-jorgensen.pdf). Your supplied equipment is [often insecure and too infrequently
updated](https://www.krackattacks.com/).

Most of you make insane amounts of money on modem rentals, can you
please invest into making those modems better over time?

A lot of the furor and frustation expressed to you by your customers,
about network flakyness, and that awful "buffering" error message and
[corresponding net nuetrality meme](https://www.youtube.com/watch?v=bEFqwmqAvYE), far too often has been driven by
those customers' *misconception* that the problems occur on your
backbone - and while they sometimes do, often the problem is in
the last mile, or in the last few feet of *their* link.

You can help educate them, by directing tests to the [dslreports web site](http://www.dslreports.com), and encouraging them to replace their routers with something better.

More importantly: *Even after you move more bandwidth sucking services
in-house*, you *will retain* the underlying buffering problems across
your edge connections. Your network services will remain flaky under load.

PLEASE: In your next RFP for equipment you intend to supply, specify
[RFC8290](https://tools.ietf.org/html/rfc8290). Feel free to try something lighter weight, like [SFQ](https://pdfs.semanticscholar.org/c577/0612bfaa1dff4daf2b0cfe56b79627dddc9c.pdf), or [RFC8033](https://tools.ietf.org/html/rfc8290). Reduce
your buffering in your head-ends to something sane. In your bandwidth
shapers, try [cake](https://arxiv.org/abs/1804.07617). Get something like [BQL](https://www.coverfire.com/articles/queueing-in-the-linux-network-stack/) into your ring buffers, particulary on slower speed devices like DSL. In your wifi gear, see [Ending the Anomaly](https://www.usenix.org/system/files/conference/atc17/atc17-hoiland-jorgensen.pdf), and
specify something like that.

Many third party manufacturers have already adopted many of the network buffer management techniques created by the bufferbloat projects. All you need to do is ship them by default.

The bufferbloat project has made it easy for you to just adopt this
stuff and eliminate a lot of customer complaints, and build a better Internet,
for everyone.

Thanks. The network you save may be your own.

PS you've claimed that ending network neutrality will spur research
and investment, and if that's the cause of the bufferbloat project
struggling for so long on so little... well, there are a ton of people
that have worked to *give away* these solutions to *your problems* that ache
for a chance to deploy them at scale, and by default, on your networks.

You can find us on the [bloat, cake, and make-wifi-fast](https://lists.bufferbloat.net) mailing lists.
