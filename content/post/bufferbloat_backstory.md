+++
date = "2019-01-10T16:02:58+01:00"
draft = true
tags = [ "bufferbloat", "life" ]
title = "A bufferbloat backstory"
description = "Spring cleaning"
+++

My Bufferbloat.net Backstory

In the beginning I had one idea that I could barely express. I wanted a generic “wondershaper”, the tool I’d used for decades – to apply to wired and wireless connections. 

And I argued with Van Jacobson, about the need for Fair Queuing, and with 

It was 2011. It was raining in a deluge, and my wifi connection, going 14km over three hops and three mountains, into the town of San Juan Del Sur, had 3 seconds of latency in it, under load, with signal
strength that was adaquate. I didn't understand it. I'd do a download, and my ssh connection to the office would go to hell, my internet radio stop, 

I figured it was just because of the tin cans and string connecting Nicaragua to the rest of the world, but that wasn’t it – I couldn’t figure it out, even though I had plenty of time in the rain, doing nothing else 

It wasn't until I got back to the USA, and encountered Jim Getty's experiments into what became known as the "bufferbloat" problem, that I realized that I'd stumbled into something much, much deeper, a problem, that afflicted the entire internet, that was wrecking the performance of interactive applications.

To try and describe bufferbloat briefly: ever do a big upload or download and have your internet for other applications or users slow to a crawl, or become unusable?

Most people think think that's normal, but it needn't be. See RFC8290 and countless benchmarks of the fq_codel algorithms on the internet today. I’d 

I'm not going to go more into the what here, but describe what I did to fix it.

What did I start off doing?

Well, I'd been involved in the early days of wifi, and I helped create the embeddded linux market while at Montavista...  I was semi-retired and not doing anything useful with my life. What do you do when Jim Gettys, Dave Reed, Vint Cerf, Paul Vixie and Eric Raymond all gang up on you and say: "you're the only person we know with all the skills that can solve this. "

This begat the cerowrt project - which was an existence proof that better active queue management, fair queueing, dnssec, remote updates, and ipv6 all could be made to work well on routing hardware that costs 20 bucks or less to make.

As we made breakthrough after breakthrough, and fed the work back into openwrt and Linux and the rest of the stack. In the beginning it was the "so-called" bufferbloat problem and I had to go to doubter's houses, router in hand, to upgrade them... now... well...

Looking back on it all, however, at each innovation, I'm astonished at how huge a role collaboration and serendipity played, at how the "best minds don't work for you".

* Tom Herbert came up with the BQL algorithm, which made 30+ years of dusty old FQ and AQM research work again
* Van Jacobson and Kathie Nichols came up with "codel"
* A chance encounter with Eric Dumazet in a paris cafe led to a 9 month collaboration on fq_codel.
  He has since been the driver on many, many other bloat related innovations
* A lone hacker in australia figured out that bufferbloat was his home dsl's connection's big problem... fixed it for his family... and went on to write dslreports.com suite of bufferbloat related tests
* Toke Hoiland-Jurgenson wrote "flent"
* Pete Heist wrote "irtt"
* Hundreds of papers were published - ns3 models analyzed - 
* Hundreds of other people saw something they could do, and did it
* Hundreds of manufacturers saw the benefit of the work... and shipped it.
* Thousands of others didn't but because it "just works" shipped it anyway
* The cred for having a pending major fix for wifi, kept open source wifi from being banned by the FCC.
* And, most recently we ended the wifi perfMy Bufferbloat.net Backstory

In the beginning I had one idea that I could barely express. I wanted a generic “wondershaper”, the tool I’d used for decades – to apply to wired and wireless connections. 

And I argued with Van Jacobson, about the need for Fair Queuing, and with 

It was 2011. It was raining in a deluge, and my wifi connection, going 14km over three hops and three mountains, into the town of San Juan Del Sur, had 3 seconds of latency in it, under load, with signal
strength that was adaquate. I didn't understand it. I'd do a download, and my ssh connection to the office would go to hell, my internet radio stop, 

I figured it was just because of the tin cans and string connecting Nicaragua to the rest of the world, but that wasn’t it – I couldn’t figure it out, even though I had plenty of time in the rain, doing nothing else 

It wasn't until I got back to the USA, and encountered Jim Getty's experiments into what became known as the "bufferbloat" problem, that I realized that I'd stumbled into something much, much deeper, a problem, that afflicted the entire internet, that was wrecking the performance of interactive applications.

To try and describe bufferbloat briefly: ever do a big upload or download and have your internet for other applications or users slow to a crawl, or become unusable?

Most people think think that's normal, but it needn't be. See RFC8290 and countless benchmarks of the fq_codel algorithms on the internet today. I’d 

I'm not going to go more into the what here, but describe what I did to fix it.

What did I start off doing?

Well, I'd been involved in the early days of wifi, and I helped create the embeddded linux market while at Montavista...  I was semi-retired and not doing anything useful with my life. What do you do when Jim Gettys, Dave Reed, Vint Cerf, Paul Vixie and Eric Raymond all gang up on you and say: "you're the only person we know with all the skills that can solve this. "

This begat the cerowrt project - which was an existence proof that better active queue management, fair queueing, dnssec, remote updates, and ipv6 all could be made to work well on routing hardware that costs 20 bucks or less to make.

As we made breakthrough after breakthrough, and fed the work back into openwrt and Linux and the rest of the stack. In the beginning it was the "so-called" bufferbloat problem and I had to go to doubter's houses, router in hand, to upgrade them... now... well...

Looking back on it all, however, at each innovation, I'm astonished at how huge a role collaboration and serendipity played, at how the "best minds don't work for you".

* Tom Herbert came up with the BQL algorithm, which made 30+ years of dusty old FQ and AQM research work again
* Van Jacobson and Kathie Nichols came up with "codel"ormance anomaly - with code that is now in QCA's ath9k and ath10k drivers, mediatek's MT76, and soon, all of intel's new wifi products

My end goal, when we started the make-wifi-fast project after cerowrt concluded, was to make wifi far more performant and low latency than 5G could ever be.  That took 5 years. It's now in increasingly wide deployment. IOS and OSX swithed to default to fq_codel earlier this year, as the most recent example. Intel, soon. 

Most of Linux switched to fq_codel as the default a few years ago.

I once calculated that if we fixed bufferbloat, and widely deployed those fixes, that we could save everyone on the internet, a few seconds of day of delay, and countless moments of annoyance and
frustration.

An easy calculation: Saving 2 billion people, 10 seconds a day, equalled 16000 man-years of time and incalculable frustrations from jitter and latency. That made the work worthwhile, even when funding
was scarce, or progress slow, which it was, through most of these projects.

The results of my work are nearly universal now, probably in heavy use across your cloud, for example - working silently to make a better experience.

If you run a recent linux... do a 

tc -s qdisc show | grep fq_codel

and see if it's on. Or look for BQL. Or BBR.

or OSX... or FreeBSD.

and realize I've improved your life, just a little bit. Worldwide, the
scale is almost unimaginable.

I'd like to think that fixing bufferbloat, so thoroughly, and by by
working all nine layers of the ISO stack to do it, and making the
fixes increasingly ubiquitous across all operating systems, I've made
a much better internet, for everyone, in the cloud, in the DC, in the
business, and the home.

Not only that, but "queueing" and "sanely shedding load" are now a
well-recognized problem in many other layers of the stack. Uber, for
example, used the codel algorithm to cope with bursts in their car
reservation system.

What was my role in all this? I did what I'd always did in every
startup - I'm a big believer in "management by wandering around" -
finding problems, inspiring people to fix them, doing the dirty work
no-one else was willing to do, empting the trash cans, cheerleading,
nagging, publicising, engineering, testing, and innovating. I've made
some great friends and contacts not only in academia, but industry and
the linux community. Coding wise, well, I'm proudest of the wifi
fixes.

With that.... I went to the 802.11 wg meeting - the next day latency
appeared in 5 specification documents. We went to the IETF, and
spawned the aqm, babel, and homenet working groups. That fed back into
the webrtc and rmcat working groups also, and the videoconferencing
standards benefited.

I sincerely doubt something as deep and hard as the bufferbloat
problem was to solve will ever cross my career again. I'm out, oh, ~2m
in back pay for having made the effort, but karmically, I'm set for
life. The work is done. The code is "out there". The standards are
published. I can do something else. 

I don't know what that is.

I'd like a chance now, to go forth, and *use* these new capabilities,
in new products, to build a lower latency, higher capacity, and more
interactive internet. I'd like to push the limits of voip (2ms
intervals instead of 20ms), videoconferencing (8ms frame rates or
less), and AR and VR, in a new string of hardware and software
products. I've a long standing itch to scratch in audio, as one example.

Amazon is one of the very few places building stuff I like. 

Thank you for your consideration.

