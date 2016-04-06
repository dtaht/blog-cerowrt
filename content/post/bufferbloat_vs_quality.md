+++
date = "2016-04-04T18:02:58+01:00"
draft = false
tags = [ "bufferbloat" ]
title = "Beating bufferbloat with home routers"
description = "The next generation of home routers can do > 85Mbits right"
+++

Nearly 4 years ago we had finally beaten bufferbloat on ethernet, dsl,
cable modems, and fiber by putting another router in front of the mis-behaving devices to control them better. 

Time went by... the hope has long been that these new fq/aqm technologies would
make it into the next generation of devices... but, as ISP bandwidths cracked 60Mbits on a more regular basis, we ran out of CPU on common low end home routers to do the job right.

Starting about 2 years ago, we've worked on improving the speed of the code, using a new variant of htb+fq_codel we call [cake](http://www.bufferbloat.net/projects/codel/wiki/CakeTechnical).

{{< figure src="http://www.dslreports.com/speedtest/3527835.png" link="http://www.dslreports.com/speedtest/3527835" >}}

Today I took the latest openwrt for a spin at 85Mbits/5.5Mbits, on an old tp-link router that used to flat-line at about 60Mbits. The first result was the usual horrific for this particular cablemodem (an Arris WBM600A) and CMTS in san francisco - peaking at over 2 seconds while downloading and over 600ms of latency on the upload. 

So I turned on cake via the [sqm-scripts](https://wiki.openwrt.org/doc/howto/sqm), which let you automatically configure
pie, fq_codel, or cake to correct this. We lose a little bandwidth but the
induced latency stays below 12ms in both directions over the course of these tests.

{{< figure src="http://www.dslreports.com/speedtest/3527810.png" link="http://www.dslreports.com/speedtest/3527810" >}}

But: the total cpu used on the router was still nearly everything.  Better hardware is needed to successfully rate control and codel cable at these new, higher rates. Arguably we could have stopped coding for 2 years and just waited for new hardware to arrive. :(

The next generation of devices has taken a long time to roll out, but things
are beginning to look up.  I recently started working with the linksys 1200ac, which under test, is easily cracking over 300Mbits of shaping capability with cake. Being a newer product, there are inevitable bugs elsewhere in that preclude me from wanting to foist it or stuff similar to it (like the Turris Omnia) on more
normal users, as yet. Well, x86 is good to go...

To see if you are experiencing bufferbloat, try the [dslreports](http://www.dslreports.com/speedtest) test.

DSLreports has now collected over [3.5 million samples across the internet](http://www.dslreports.com/speedtest/results/bufferbloat?up=1), showing 
the size of the epidemic.

Now, I have a bone to pick with this test, [in that it equates "Quality" with
low packet loss](https://www.dslreports.com/faq/17930), and unfortunately that is simply not true. At low rates
especially, you can have high packet loss, low bufferbloat, and good through
put. Certainly a link [can have high quality with high packet loss](/post/rtt_fair_on_wifi) - What matters is *which* packets you lose and when you lose
them. I'd actually never noticed how the quality rating was calculated before
now. And you can certainly have bad quality with low packet loss.

Ah, well, back to [fixing wifi](/tags/wifi).

