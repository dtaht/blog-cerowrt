+++
date = "2017-02-01T16:02:58+01:00"
draft = true
tags = [ "vpns", "bufferbloat", "fq_codel", "lede"]
title = "Smashing bugs with other bugs that have bugs"
description = "Sometimes I think the internet is designed to only work for 20 seconds"
+++

I am really good at pattern analysis. That said, I'd like to train an
AI to take over my job to try and find weird things before I do.

You only use your network for 20 seconds a day, right?

Sometimes it seems like the entire internet is engineered to the very short (less than 20 seconds) -

It's good! ship it!

Run a test for 22 seconds, and everything explodes.

This week - now that a lot of fixes all over lede's stack had landed and
things have stablized into the first release candidate, I decided to try
and take things for harder testing. First up, was merely to verify that
wireguard ipv6 -> ipv4 -> apu2 -> lede box -> cloud server 

was actually working. Prior to now I could get wireguard to hang after about 40seconds of stressing out the path like that.

What I try to do is inflict as much damage as I can in a minimal amount of time. If it blows up, sometimes working backwards is really, really difficult, and the last time I tried this, no less than 8 bugs raised their ugly heads - at the same time and finding and quashing them took weeks.


# 

Wait, see those spikes - 

Where are they coming from?

On a 60 download test, I see one *massive* one.

One 60 second upload test, there's a hint of one...

On a 300 second test, a pattern begins to emerge

{{%  figure src="/flent/wireguardtest/totallyperiodic.svg" %}}

bumpyride.svg       long_rtt_variance.svg  upload_too.svg
download_spike.svg 

On a 900 second test, it's clearly there.

This i

Next up is a long duration test like this, changing the default path in the middle, which should be "exciting". Wireguard is supposed to survive this. Heh. Heh. Heh. We'll see.

