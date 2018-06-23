+++
date = "2018-06-21T22:02:58+01:00"
draft = false
tags = [ "network neutrality", "wifi", "bufferbloat" ]
title = "Net Neutrality advocates: Care to try some technical solutions instead?"
description = "You can fix your networks yourselves... and/or help ISPs make better choices."
+++

Dear Network Neutrality advocates:

Network neutrality is lost in the USA now. You are reduced to fighting rear guard actions - and at least some of your core examples of the need for Network Neutrality have *always been wrong*.

Off to side, for over 7 years now, has been a [huge group of engineers and scientists](https://www.bufferbloat.net)
that recognized that the "buffering" problem *was not ISP
malfeasance* - but a theory failure, in how routers and endpoints dealt with
[bufferbloat](https://en.wikipedia.org/wiki/Bufferbloat), a problem [dating back to the earliest days of the Internet](RFC970).

Maybe you've thought better networks could be pickled by politics, not technology. Maybe you thought that people continuing to equate that [awful "buffering" meme](https://www.youtube.com/watch?v=bEFqwmqAvYE) with a need for network neutrality was good for the cause. Maybe you just didn't look into the underlying causes of network flakiness.

*We've* - the engineers that built the internet - have fixed much of that. On the routers, BQL and [fq_codel](https://tools.ietf.org/html/rfc8290) and especially [SQM](https://openwrt.org/docs/guide-user/network/traffic-shaping/sqm) are nearly universal in aftermarket Linux firmware and shipping in multiple commercial products. End to end techniques like TCP pacing, TCP small queues, and TCP BBR have appeared to make things better there.

All that's left is to achieve is: wider deployment in ISPs supplied gear and improvements to their headends. Now, mind you, there really is bad behavior out there on the Net. But that's at the management level. Even in the bad, corporate, evil-as-a-daily-practice ISPs, the engineers want to deliver the best service they can, beyond the corporate-blessed, bribery-paid data and the corporate-hated netflix.

After years of communicating privately and publically with groups like "savethenet" and [publicknowledge](https://www.publicknowledge.org/search/results/search&keywords=bufferbloat/) about everything bufferbloat breaks, I'd hoped that ending bufferbloat would also become a part of your crusade.

Not a word. Nothing. Crickets. I shudder to think of how much money and time you've spent politicking, when a good subset of the problems that upset y'all can be solved with better software and hardware. In fact, the biggest thing now stopping wider deployment of all these fixes - often seems to be *you* in the network neutrality movement that would benefit most from fixes arriving universally!

From a cable industry insider, [responding to my plea that they deploy bufferbloat fixes](/post/net_neutrality_isps):

> "One aspect which will likely kill the fq_codel and cake ideas in ISPs is the prioritized queueing for sparse flows part.  ISP folks are *ultra* sensitive about doing anything that could be interpreted (or even misinterpreted) as being contrary to network neutrality.  If a customer buys a router that has fair queuing, that is one thing, but for an operator to do it would open them up to attack.  We're not living in a rational world.  Plus, even for those who are rational, there are a lot more people that *think* they know how networks, protocols, and applications work, than there are who really understand it (even within ISPs and equipment vendors).  We've spent a lot of time recently trying to dispel the persistent and widespread view that application performance is by definition a zero-sum game (any improvement in performance must result in a degradation in performance somewhere else)."

Misapplied concepts of network neutrality is one of the things that killed [fq codel for DOCSIS 3.1](https://www.cablelabs.com/wp-content/uploads/2014/05/Active_Queue_Management_Algorithms_DOCSIS_3_0.pdf), despite [really impressive benchmark results](https://datatracker.ietf.org/meeting/86/materials/slides-86-iccrg-3).

Sigh. Nothing about that algorithm could be construed as contrary to the goals of Network Neutrality.

In fact, fq codel (now IETF standard RFC8290) is a uniquely "American"
algorithm. It gives the "little guy" - the little packet, the first
packets in a new connection to anywhere, a little boost until the flow
achieves parity with other flows from other sources, with minimal
buffering. This means that *all* network traffic gets treated
equally - faster. Isn't that what you want in a network neutral
framework? DNS, gaming traffic, voip, videoconferencing, and the first
packets of any new flow, to anywhere, get a small boost. That's
it. Big flows - from anybody - from netflix to google to comcast - all
achieve *parity*, with minimal delay and buffering, at a wide variety
of real round trip times.

If there is any one web page in this rant I could convince you to open, see [this
worldwide report on current bufferbloat](http://www.dslreports.com/speedtest/results/bufferbloat?up=1).

See that green line? Everybody that's deployed fq_codel is on the left side,
with sub-30ms typical latencies. Everybody else has annoying, frustrating, wait times sometimes measured in seconds.

Scroll down. See all the ISPs with low latency? None are in the USA.

Then go, run a test for yourself, on your network. Odds are you've got bufferbloat, too. *You can help fix this*.

It is intensely frustrating to me that huge potential improvements to how
networks behave today are tarred by the same brush as paid
priorization and so on.

I've longed for the day where a [comedian like Kimmel could lampoon buffering](https://www.youtube.com/watch?v=bEFqwmqAvYE) - but identify bufferbloat as the cause. I've longed for the day where more in
"pro-user" side of this debate, actually investigated technological solutions rather than political ones, maybe even bought a router with fixes on it. I've longed for the day where all sides could have a roundtable discussion over what can be done to make the internet technically better.

Networks are complex. Political solutions over applied are making
things worse.

Per that insiders point above - you can buy a router that does fair queuing, today. You just can't get one as supplied equipment in the USA.

One thing that might prove interesting going forward - is politicking for putting configuration of these routers fully in the hands of the users, so *they* can make the choice over what traffic to prioritize if they so choose. 
 
With the collapse of Network Neutrality - the underlying buffering problems will remain. *Even as the big ISPs move the bandwidth sucking services in-house*, those ISPs will retain the underlying buffering problems across their edge
connections. *Your* network services will remain flaky, unless those
ISPs deploy fixes.

My hope has long been, that members of the Network Neutrality
movement would *also* enthusiastically adopt techniques that actually
make the network better. And permit - more than that, *encourage* - hell, even mandate -
the ISPS to adopt things
like [RFC8034](https://tools.ietf.org/html/rfc8034)
and [RFC8290](https://tools.ietf.org/html/rfc8290) in the gear they
supply. And: Ask them, at the very least, to reduce their buffering in
their head-ends to something sane. Ask them, in their bandwidth
shapers, to try [cake](https://www.bufferbloat.net/projects/codel/wiki/CakeTechnical/), the latest result of the bufferbloat effort. I'd really like y'all to take a hard look at how [cake meets up with your principles too](https://arxiv.org/pdf/1804.07617.pdf)! And in their wifi gear, have them see [Ending the
Anomaly](https://www.usenix.org/system/files/conference/atc17/atc17-hoiland-jorgensen.pdf). Products leveraging that, make for tons better wifi. 

All of these things are available now in third party firmware, and in many
add on products that you can buy today - but they are not shipping from US ISPs by default.

On top of all this - there are many other problems in the Internet today - the one that scares me most is all the compromised routers out there. We all need find ways to regularly update the deployed base to new, faster, more secure router software as exploits arrive.

Between the ISPs, and the Network Neutrality folk, and the users, and
the engineers - we do have common goals, if only you would split out
the stuff that can only be solved by political means from those for
which technical solutions exist.

Can you start an informed dialog on those fronts?

Thanks. The network you save may be your own.

PS The ISPs claimed that ending network neutrality will spur research
and investment. *Make them prove it*!

PPS In trying to disentangle the political and technical mess that the
network neutrality debate has created, I find myself reflecting 
on the [old joke about the engineer and the guillotine](http://sethf.com/freespeech/memoirs/humor/guillotine.php):

> On a beautiful Sunday afternoon in the midst of the French Revolution the revolting citizens led a priest, a drunkard and an engineer to the guillotine. They ask the priest if he wants to face up or down when he meets his fate. The priest says he would like to face up so he will be looking towards heaven when he dies. They raise the blade of the guillotine and release it. It comes speeding down and suddenly stops just inches from his neck. The authorities take this as divine intervention and release the priest.

>The drunkard comes to the guillotine next. He also decides to die face up, hoping that he will be as fortunate as the priest. They raise the blade of the guillotine and release it. It comes speeding down and suddenly stops just inches from his neck. Again, the authorities take this as a sign of divine intervention, and they release the drunkard as well.

>Next is the engineer. He, too, decides to die facing up. As they slowly raise the blade of the guillotine, the engineer suddenly says, "Hey, I see what your problem is ..."

I've longed to see an informed article about bufferbloat and the solutions appear in Wired, the Atlantic, the Economist, the Washington Post, or anywhere, in the conventional press.

I know a bunch of people willing to write 'em. Some of them are names you might have heard of.
