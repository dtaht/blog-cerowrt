+++
date = "2019-01-30T18:02:58+01:00"
draft = true
tags = [ "bufferbloat", "benchmarks" ]
title = "Why was the internet so slow, under load?"
description = "And what can we do to fix it? - Jim Gettys, 2011"
+++

I think the improvements the members of the Bufferbloat Project made to the Internet, and to WiFi, as recently described in “Ending the Anomaly”, are the crowning achievements of my career. I’d rather people read that last paper than I talk about the processes that led to it –  and then run to check to see if their device have fq_codel for wifi already – but, here goes (but perhaps you could leave a a page open to the first graph? Or the VOIP chart? Or….)

In 2011, I partnered up with Jim to help run the project with one, core, idea of my own – "What if we could make “wondershaper fully general” ? AND the default across all the internet, across WiFi and wireless technologies? I didn’t know how, in the beginning… and nobody believed me about the power of fair queuing… not even Jim! So... in 2012, we started the CeroWrt project for home routers, as a test-bed and as an existence proof that a faster internet was feasible: that classic AQM and Fair queuing algorithms could make a difference in the edge networking experience. Along the way we improved IPv6 handling, improved DNSSEC, and pioneered a few other things, now standards, such as “source specific routing”, now known as SADR.

The final ship of that effort, in 2014, and our enthusiastic userbase silenced the doubters. The code went upstream to OpenWrt and Linux itself, and from there, well, I’ll get to that later. The stuff that we didn’t solve in CeroWrt, we took on in the later projects of Make-wifi-fast and Cake.

Along the way I did many things that were new and unusual for me. While I worked at re-engineering all “9” layers of the ISO network stack, and already a wifi and embedded Linux expert, taught myself enough queue theory from Len Kleinrock’s works until I could interact with experts.

Funding ranged from scarce to non-existent. In the early days, lit on fire with what we were doing and the early results...

I slept on Paul Vixie’s couch, and shipped code from Eric Raymond’s basement. I argued with Van Jacobson about the need for fair queuing, and with the core designers of the classic fair queuing algorithms, like Paul Mckenney (SFQ), about the need for AQM. I slept on Paalo Valente’s couch, also, for two weeks, while we hashed it out over his QFQ vs our FQ_Codel, before he was willing to concede the math was correct. I had multiple stays at the LINCs lab in Paris with Luca Muscarillo, one of the core theorists in this area, also. I built test-beds at Georgia Tech, ISC.org, LINCs, the University of Karlstad, c-base, and Lupin Lodge. A chance meeting with Eric Dumazet in Paris led to the 9 month collaboration that completed with the FQ_codel (now RFC8290) algorithm, which was the core breakthrough that potentially sped up the net by orders of magnitude, under load.

I then set to work on making it the default in Linux, and elsewhere...

Along that path, we  spawned the IETF AQM, HOMENET and BABEL working groups, made for changes in the 802.11ax standard, and fought side by side with Vint Cerf against the FCC to keep open source WiFi legal. Along the way I was highly influenced by the biography of Licklidder (first ARPA director) and by books like “when hackers stay up late” and “Dealers of lightning”, and perpetually inspired by having a chance to interact with so many core founders of the Internet, that just wanted this pesky 50 year old networking problem solved, and were willing to help.

I went to conferences I normally wouldn’t go to – gaming conferences, the IETF, user group meetings – and gave talks and demos. I lectured at Stanford and MIT, NANOG, RIPE, USENIX, IEEE, and the IETF- and of the major talks, which summarize now, 50 years of queuing theory and AQM/FQ R&D on the internet– the only one not filmed was my keynote/rant at SIGCOMM 2014 on “the value of repeatable experiments and negative results”. (they’ve not invited me back!). Taking my approach to science and engineering we succeeded where so many others had failed.

I also worked in the background, with the Open Inventions Network (OIN), to keep the patent attorneys at bay, on several cases I still can’t talk about.  We teamed up with NLnet to put a floor under some starving developers. We got comcast and google to help out here and there, too.

I reached out to every community I could think of –  notably OpenWrt, Linux, freebsd, Apple, and Android. I did a backport of the core SQM code to the edgerouter that ubnt’s userbase ran with and improved so much it became part of their standard product. You’ll find SQM everywhere now.

But the really, really hard part was: coming up with algorithms that worked, and making code that ran fast enough – and reliable enough - to work on cheap hardware. Don Knuth is still working on his fourth book! We invented a good half dozen new ones, tested the heck out of them, tuned, and retuned, and ported the code to multiple platforms, until they were safe enough for general use...

It’s hard to figure out where my work began and the work of hundreds of others ended – without whom things would have ended, too.  I have to call out my co-author and collaborator and student, Toke Høiland-Jørgensen, in particular, for having been utterly essential. I coded, theorized, QA’d, guided and evangelized - but I am sure, without me around to connect the dots and strengthen the links – none of it would have happened. We wouldn’t have BQL, FQ_codel, FQ_pie, BBR, and a heightened awareness of queue theory in many major web applications. There wouldn’t be 1200 papers on bufferbloat, on google scholar. QUIC might not have taken off to the extent it did. We wouldn’t have made videoconferencing, in particular, so much better. 

The thing is, the theory work is done; the basic implementation work is done. There’s billions of users now benefiting from some aspect of the work. Something FQ or FQ_Codel derived is the default on most modern Linuxes. RFC8290 is published. I got the license plate. FreeBSD has an implementation. 

There’s nothing left major to do except plod away adding in these features into the thousands of devices and device drivers that need them. We  finished openwrt 18.06 in july 2018, and our “sch_cake” rollup of the fq_codel SQM work – the “last QOS system you’ll ever need”, finally went mainline that August. It is now in Linux 4.19. The last make-wifi-fast patches, which QCA, Mediatek, and Intel are adopting, hopefully landed last week. Apple shipped their fq_codel version feburary 2018 on OSX and IOS. Chromium, google wifi, and much of the embedded router market, shipped theirs years back.

That’s over 2b machines sped up, so far, from my back yard, and still there is a long way to go. I sometimes think there’s enough momentum, and I don’t need to do this job anymore, but every time I hit reload on 

Certainly - after 8 years of doing it, I’d love to find something else that either used my new skills or leveraged some old ones. I kind of miss working in easy languages in gigabytes of memory, as one example. I’d like to work on immersive audio, as another, or drive another research project from concept to ship. 

(Having something profitable to do this year would help me too. Last year put me deeply into debt. Still, I would not have missed doing this project - for all the money in the world, and I turned down "distracting" job offer after job offer along the way)

It’s my hope that my story of what it took and what I was willing to do, to bring something amazing to market, and make it ubiquitous – is as inspiring to you, as it was to me.

- And that you go home, after this, see if you have fq_codel or SQM already, and turn it on. And fix a friend or two's internet as well.