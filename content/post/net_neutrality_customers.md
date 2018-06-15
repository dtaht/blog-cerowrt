+++
date = "2016-04-24T22:02:58+01:00"
draft = true
tags = [ "lab", "wifi", "bufferbloat" ]
title = "Net Neutrality is dead. Can you fix your networks now?"
description = ""
+++

fq_codel (RFC8290) is a uniquely "American" algorithm. It gives the
"little guy" a little boost to achieve parity with other flows from
other sources. this means 

show achieved uplink bandwidths
show 

Maybe you've thought it could be solved by politics, not technology.

It usually isn't.

I've longed for the day where a comedian like Kimmel - and
identified bufferbloat as the cause. I've longed for the day where
anyone in the debate at all, actually investigated 

Paid prioritization doesn't work. It puts you in control of your
own traffic, and you in

After you finish burning billions on massive mergers, could you also
go and improve your networks? You have overbuffered uplinks, and
massively overbuffered downlinks. Your wifi implementations are
poor. Your supplied equipment is often insecure and too infrequently
updated. Most of you make insane amounts of money on modem rentals,
can you please invest money into making those modems better over time?

A lot of the furor and frustation expressed to you by your customers,
about network flakyness, and that awful "buffering" error message, far
to often has been driven by those customers' *misconception* that the
problems occur on your backbone - and while they sometimes do, most
often the problem is in the last mile, or in the last few feet of
*their* link.

*Even if you move the bandwidth sucking services in-house*, you will
retain the underlying buffering problems across your edge
connections. Your network services will remain flaky. While we in the
bufferbloat project have worked hard to make

PLEASE: In your next RFP for equipment you supply, specify RFC8290. Reduce your buffering in your head-ends to something sane. In your bandwidth shapers, try "cake". In your wifi gear, see "ending the anomaly", and specify
And: find ways to regularly update your deployed base to new, faster, more secure router software.

Thanks. The network you save may be your own.

PS you've claimed that ending network neutrality will spur research
and investment, and if that's the cause of the bufferbloat project
struggling for so long on so little... well, there are a ton of people
that have worked to give away these solutions to your problems that ache
for a chance to deploy them at scale, on your networks.



