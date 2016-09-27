+++
date = "2017-09-27T12:02:58+01:00"
draft = false
tags = [ "bufferbloat", "tcp", "bbr" ]
title = "A bit about TCP BBR"
description = "Knowing something like BBR must exist was maddening and motivating"
+++

One day, a while back, an instant message came in: "Hey, dave, take a
packet capture on youtube and tell me what you see."  So I did, and
what I saw was packets spaced perfectly on ms intervals. "Wow" - I
said - and reported back. At that point it was pretty common knowledge
that sch_fq with pacing had deployed within google - and I assumed
that it had finally deployed on youtube.

"Anything else?" - that person asked - and I poked deeper and saw,
seemingly - that the cwnd was a bit weird, but nothing I could put a
finger on. 

I wasn't in a position to guess, further, that [BBR](/tags/bbr) had also been
deployed there - nor am I sure it actually was, at the time - I don't think
it was, not in its present form, at least.

## Clue #2

Some time prior - independently, in my daily google search for news
about [bufferbloat](/tags/bufferbloat) - I'd stumbled across
[Bufferbloat Resilient TCP](http://cpsc.yale.edu/event/dissertation-defensemichael-nowlan) -
which naturally piqued my curiousity. After a bit of wrangling (theses
are are supposed to be nailed up!), and a few months later, I got the
thesis to read over.

I evaluated the code as it was then, and it sucked the same way every
delay based TCP had before it - cubic outcompeted the hell out of it -
and it needed a whole lot of math in the hot path, besides.

It had a very good idea in it:

````
BBR detects bufferbloat by comparing its calculated correlation to a
configurable threshold (e.g., 90%) and declaring bufferbloat whenever
the value exceeds the threshold."

Upon detecting bufferbloat, BBR immediately sets the TCP cwnd to the
window estimate, rather than gradually reducing the sending rate as
in, for example, Proportional Rate Reduction [19]. Immediately
changing the cwnd has two advantages. First, it stops packet
transmissions immediately and prevents further exacerbating the delay.
When the transmissions resume with the reduced cwnd, they should
experience shorter queuing delay.

*Second, drastic changes in sending rate should result in sharp
differences in observed RTT, increasing the signal-to-noise ratio in
the observations and improving the correlation calculation*.
````

That idea was BRILLIANT. But elsewhere the code relied on old, broken,
delay-based ideas. That delay base was an impossible hurdle. I
couldn't figure out how to make it work. I'd read all the hundreds of
papers on bufferbloat, and TCP BBR as I grokked it then, joined the
ashheap of all the other delay TCPS, like CDG, and New Vegas.

Without an Internet flag day, a delay based TCP was going to go
nowhere.

## Still... something was up

I - like thousands of others - have longed for an end to end network
congestion control solution that actually worked. As much as I've been
advocating fixing the routers, I've known that was a hopeless cause
for major ISPs, or at least, a 10 year long truck roll that we're now
5 years into without enough vehicles leaving the garage. Yet - nobody,
in 40 years of trying, had ever come up with something satisfactory,
end to end, and what we were accomplishing on software based routers
was 10-50x better than what anybody had ever achieved end to end. So I
had to try.

Still... something was up. Google'd flows behaved better. Admittedly
they'd actually gone and made sure that all the actual
bufferbloat-fighting pieces required that had been developed to date -
BQL, pacing, etc, etc - actually worked on their hardware. A lot of
people have turned fq_codel on and had it not do anything, not
noticing the BQL requirement. Others have drivers that overuse NAPI,
or are otherwise buggy, cpu-limited, and so on. Software rate limiting
was fiddly in the face of PPPoe and ATM encapsulations - we really
needed BQL support in the DSL and cable firmware, and nobody writing
that stuff seemed to be listening.

Would Google solve the end to end congestion control problem? Nobody
had ever come up with a fq'd aqm that worked, either, in 40 years of
trying, before the very same folk, all now working at google, had, in
2011. So I worried. I lost sleep. Was I dedicating my life to
something pointless and futile?

Google'd flows were short - youtube's rate-limited - the only way I
have to really figure out how something is working is run a range of
fairly long tests against it - and that's not what I could do.

## Clue #3: BBR in QUIC?

Then BBR snuck out again as [part of a QUIC commit](https://groups.google.com/a/chromium.org/forum/#!topic/proto-quic/aOldwaxktxA).

*Alarm bells went off*!

I'd been watching the paced behavior of QUIC "just work" - and being
annoyed at the very idea of IW32 (10 slow start packets and 22 paced
ones) - while watching it really work against all kinds of traffic and
wondering what was up - but there is no decoder for quic that tears
apart its cwnd or tcp-equivalent statistics - just an opaque header.

The code for the QUIC server at the time, was not particularly easy to
use, I never got around to setting it up, and the only way to understand
QUIC's behavior would have been to have a heavily instrumented quic client,
which didn't exist either. And I looked over the code, and it seemed
like the same broken BBR I'd looked at before.

"Just tell me one thing" - I asked. "Tell me what I'm doing on wifi is still
worthwile? Lie if you must!"

The answer came back: "The wifi work is worthwhile - keep at it."

:whew:

Since then I just got more and more heads down on beating bufferbloat
on wifi. Google had a big part of the internet covered, somehow. Wifi
was still a problem I could make a difference on.

## Focusing changes

Still:

* I stopped sweating inbound rate limiting as much

We've had to wait until about last year, for hardware to appear that
could do inbound rate limiting and management with fq_codel, above
60Mbits. That hardware is still pretty expensive - and buggy - but
things like the turris omnia are capable of managing 200+Mbit inbound,
and we needed that. Or we needed something that worked end to end - Or
the big iron CMTS/BRAS makers would ship something that worked...

Of the three, the sure bet was always "better end user hardware", but
if e2e works... I could stop nagging the CMTS and BRAS makers to
deploy something better. So I did. I still (strongly) think that some
form of fair queuing would make a load of difference on the ISP side
of affairs. HFSC + SFQ is widely deployed for a reason.

FQ makes a huge difference on the uplink as well, and I dearly wish
fq_codel had got its day in the sun on the DOCSIS 3.1 standard.

* I stopped caring about the IETF

Endless debates over two impractical alternatives was not my cup of
tea. I proved to myself, at least, that the "fq" portion of fq_codel
could handle the onslought of the new TCP variants being proposed, and
the fq-ing bit had the potential to make alternate congestion control
mechanisms more deployable - but the AQM bit blew up the assumptions
of every known delay based tcp also, which was a result we'd shown
back in 2011, and it didn't work as well against the assumptions of
DCTCP of the DCTCP folk would like, either.

I have always worried that "a smart queue system that worked today,
wouldn't work tomorrow", like what had happened to
[wondershaper](https://www.bufferbloat.net/projects/cerowrt/wiki/Wondershaper_Must_Die/).

* I stopped working on "cake"

I really just wanted to work on wifi, anyway.

[Cake](https://www.bufferbloat.net/projects/codel/wiki/CakeTechnical/) - well, as I originally conceived it - was intended merely to be
faster than htb + fq_codel in the sqm-scripts on weak hardware. The
earliest version of it could rate limit inbound 40% better than that
could.

Then: Second system syndrome set in, in response to user requests. 

Cake gained many forms of diffserv classification, and extensive
statistics. Jonathan added a variant of blue, called cobalt (for handling
unresponsive flows), added an 8 way set-associative hash, switched to
memory limiting rather than packet limiting - and most recently -
Kevin got nat and per host fairness working. Not having fq within per
host fairness was a common complaint - it more or less works now.

Cake has become the nearly most feature-full shaping software there is out
there.  It's teetering on the verge of being middlebox-ware, although
no-one has gone so far as to propose adding ack thinning to it, thank
Ghu.

The end result of all that has been code that was actually slower than
htb+fq_codel is. I've long thought there was a way of improving that
dramatically - getting rid of the need for "tc_mirred" in the ingress
filter, but haven't got around to it. Cake *does* work, on decent
hardware, at past 10Gbit rates, and for those that want the ultimate
in low latency networking can apply it there, too.

Cake's primary use case now is dealing with shaping requirements in
the most optimal way on very slow networks. That's a big use case -
Most home users still have far less than a 10Mbit upload channel! But
it still isn't quite what I'd wanted.

Cake's improvements over fq_codel amount to percentage points here and
there, a much better user interface, and better handling of a slew of
edge cases.

Maybe someday, if someone gets on it, the original dream of

tc qdisc add dev eth0 ingress cake bandwidth 100Mbit

will work on low end hardware. I use cake daily, on just about everything,
but haven't got around to evaluating all the new whizzy features.

In the meantime, we're working on speeding up wifi by 5x and removing
an order of magnitude of its excess latency. Some of cake's ideas and
features have applied there - in particular, changing the bandwidth
dynamically was very helpful in understanding how wifi and codel might
interact. Other cake features have migrated into fq_codel. 

...

I'd put a bit of work into a kinder, gentler policer, called "bobbie",
for a while, but couldn't make it work worth a damn. Policers suck,
and despite me encouraging everyone to turn to shapers instead, remain
very widely deployed - which the BBR folk recognise and are trying to
solve their way. Maybe policers will remain relevant, now.

## Clue #4: fq_codel gets "ce_threshold"

A year (?) ago, support for a weird new parameter, "ce_threshold",
arrived for fq_codel in the Linux mainline.

It did bad things to cubic. I tried DCTCP against it - that wasn't it
either. What the heck was it for? I didn't even bother to ask, knowing
I'd get stonewalled on the answer.

We documented it for the still-pending fq_codel RFC, and moved on.

## Paranoia

Somewhere around here, most of my emails started ending up in people's
spam folders, regularly. I think that's just a co-incidence - given my
propensity for verbosity, or including lots of non-https urls, some spam filter
at google objects - but it's partially why I blog now, more. If you are
on the bufferbloat related mailing lists, and you haven't got any email
from me lately, check your spam folders?

It's always puzzled me as to why nearly no traffic from the lists ends
up in a google search with a pointer to lists.bufferbloat.net email
archive, and why we only have 66,000 or so bufferbloat related results
on any given google search, after 6 years of it....

## Clue #5

At IETF 96, I corralled a googler and explained the problems we were
having with applying codel in the Wifi environment.

"So the minimum interval is probably over 4ms?", he asked.

"Yes - way over - the jitter and delay can still be 100s of ms with lots
 of stations".
 
"A pity." - he replied, and then he clammed up.

!@#!@!# !!!@#!@#! @#!@#! @#!@#! $%@#!%#! @#!@#!@$!$!@#!@#!@#!%!@!

## Digression: Further fixing wifi

I've long planned - once the fq_codel and airtime fairness code
stablized, to start ripping even more jitter and latency out of
wifi. In particular, we can clamp the AP's TXOP to ever smaller values
as more stations need service, and also advertise a smaller TXOP in
the beacon. We don't need to use up 4 ms on every transmit, and (IMHO)
it is best to optimize for minimal service intervals - not bandwidth -
when stations are contended, period - a viewpoint that I'll have
endless debates trying to share with others in the industry, until
we deliver a proof of concept implementation that works.

There's also potential modifications to minstrel rate controller -
right now it can take 10s of seconds for it to find the right rate,
and it samples on a fixed 5% interval which is both too often and too
late. Your typical web transaction lasts 2 seconds, and finding the
right rate inside of 100ms would be ideal. Minstrel-blues corrects
this, but I've seen it take 20 seconds, to find a good rate.

There's also the idea of Minstrel aiming for the least jittery rate,
opportunistically checking for a better one - particularly when there
are flows ramping up, when there is time to apply the additional
jitter without harm.

But - compared to the queueing delay problem itself, fixing minstrel takes
second place.

In developing BBR, the google devs were looking from the outside of the
home network, in, and could see wifi problems pretty clearly from that
viewpoint. Wifi's issues are not dominated by packet loss - but by
overbuffering and, jitter, and excessive RTTs.

They have the fixed, physical RTT, the buffering on the link itself,
and then the behavior of the wifi behind it - also crazily
overbuffered - to deal with.

So the outside RTT - usually more than 10ms - BBR smooths over,
buffering up up to estimated 1 BDP's worth of packets. The inside
buffering - well, the problem they solved for wifi was for wifi's
current deployment, and the issues we're introducing in make-wifi-fast
with ripping out all the excess latency in wifi, are a problem only a
half dozen people have today. Now that I have BBR in the wifi testbed,
we can work on doing things more right for BBR, there!

Me, *I'd like* to make wifi capable of twitch gaming, to get 4ms of
latency for for audio applications, and VR, one day. Doubt I'll
ever get there.

Anyway, after a first look at BBR's behaviors over wifi, I think a
good answer is to not sweat the buffering problem as much as we have
and have a kinder, gentler approach to the amount of buffering we
allow - either queue up a "good sized" aggregate for *every* station,
or vary the codel target and interval as a function of the number of
active stations. Right now, it's a fixed 20ms, and a hack to make it
behave better at really low rates, which works ok for a small number
of stations. I worry about the overall size of the "knee" of the curve
here, and for all I know we'll have to abandon codel as we know it,
entirely. The FQ bit... airtime fairness... intermediate queues implementation... still needed, and nice.

There's a long term problem in that we just eliminated the qdisc
entirely in favor of doing all that, and perhaps a wifi client would
want to run BBR - which mandated sch_fq.

## Clue #6

There have been perpetual delays on the final codel draft for the
IETF, which blocks the fq_codel draft that I'm a co-author of.  I kind
of suspect, now, that part of the reason for that was internal
progress on BBR, and trying to figure out the right way for codel to
deal with BBR, and vice versa. Thankfully, although fq_codel is widely
deployed at this point (by my standards, not googles!), it's deployed
in software, and we can go back and fix it, there, if we have to.

I think we need to change codel to drop CE marked packets instead of
giving those a free ride, when codel engages, in particular.

## Back to BBR

So, about 2 weeks ago, BBR arrived as a proposed patch to the linux
kernel, and after a few rounds of polishing, entered what will become
linux 4.9, and I've just gone and tested the hell out of it.

Could I have figured out how it worked? *Not a chance*. Even with 20/20
hindsight and remembering each of these clues, now, today, vividly,
I'd have never twigged to how BBR worked. Controlling the "gain" of
the pacing rate also was a fundamental insight, and there are at least a
half dozen other behaviors I don't fully understand yet, all solving
real problems on the internet today.

To google's huge credit, they are making the code and paper, available
now, to make for one day, a better internet. They needen't have done
so - although the game theory here works for them too - every adopter
of BBR will have to fight less with other BBR implementations to get a
good result on a given network, and reno and cubic can slowly die out
as the Internet's default congestion control algorithm.

Assuming it works! Still early days! I gotta go work on wifi now!