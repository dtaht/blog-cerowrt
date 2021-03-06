+++
date = "2018-01-15T12:02:58+01:00"
draft = false
tags = [ "wifi", "bufferbloat", "ath9k" ]
title = "UDP flood testing can be problematic"
description = "UDP floods can be harmful"
+++

Network theorists spend way too much time thinking about circumstances
where everything is behaving nicely and according to spec, and not
enough time thinking about how nasty the real world can be. The need
to discard packets is so bad and so frequent on the Internet itself
that companies like Cloudflare *make a living doing it*, and the earliest
efforts on bpf for linux promoted techniques that can do it at the earliest
moment possible - in the core receive path of the ethernet driver
itself!

## Getting clobbered by UDP floods

When you flood a device like this you are no longer testing the speed
of the hardware, media or driver, you are testing the speed of the
discard part of the path, rather than anything else. Real networks
don't have floods like this... except that generated by test tools,
broken software and DDOS attacks. A ping -s 1400 -f somewhere sufficies.

## Fixing fq_codel

So, after a few years of deployment, someone created a test that would
thoroughly stress out fq_codel with an unresponsive flood, and noticed
that it ate low end cpus for breakfast.

After a long debate, Eric Dumazet jumped in with a drastic patch hat
would drop up to 64 packets in a row from a misbehaved queue under a
single lock, under this overload condition. That sped up the code
*enormously* when under attack and it went immediately into linux mainline.

This right answer was much like what is being proposed in the IETF
[circuit breakers drafts](https://tools.ietf.org/html/draft-ietf-tsvwg-circuit-breaker-15), except that this one needed to enter the fq_codel qdisc in order to
make it behave sanely on an overload like this. The updated algorithm made
the fq_codel [RFC8290](https://tools.ietf.org/html/rfc8290).

I don't know if this change migrated into the wifi codebase
for fq_codel or not, or got backported into openwrt! I'd burned
out on following all the patch sets at that point, and all I was lugging
was a laptop with a tiny screen I can't see or multitask anything on.
