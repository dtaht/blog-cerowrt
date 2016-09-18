+++
date = "2016-09-16T12:02:58+01:00"
draft = false
tags = [ "wifi", "bufferbloat", "ath9k" ]
title = "Solving the crypto-fq bug in ath9k"
description = "How I spent my summer vacation"
+++

With the first ever [fq_codel implementation for
WiFi](/tags/ath10k) and the [WiFi airtime fairness scheduler](https://blog.tohojo.dk/2016/06/fixing-the-wifi-performance-anomaly-on-ath9k.html) we'd
finally hit our holy grail - reducing WiFi latencies under load by an order
of magnitude and improving throughput similarly in contended cases. We hit a major bug, however, that blindsided us, that took all summer to solve. Swapping out the engines completely on the airplane, while dealing
with billions of actual users and an incredibly complex codebase, is
*hard*. 

{{< figure src="https://blog.tohojo.dk/media/airtime-v2-tcp-upload.svg" title="VICTORY!">}}

You can't do much better than this on wifi with a single channel, this
much dramatically reducing latency while also improving throughput. It
was awesome. It seemed perfect. After 5 years of effort, we'd won. It
was time to attend a few conferences in Europe, and take a vacation,
after submitting the patches to the Linux kernel maintainers.

I booked the next plane out... out went the patches... And
two reviews came in immediately, telling us they didn't work.

One of our problems has been that we rarely get *all* the very
interrelated patches out, never the whole enchalada, and thus people
have been testing (and often, reverting), individual patches, tested in their
particular circumstances, where we have been testing the whole thing,
with our limited testbeds, and ingrained habits.

Felix Feitkau (of the lede-project) had to revert the FQ portion of the
patches, which got bandwidth up where it belonged (with codel
engaging), but it cost latency, and we didn't grok what had broke. (We'd
actually not expected Felix to come up with a backport that fast in
the first place, there are a good dozen infrastructural patches needed
to be in play, but he managed to do the backport, find a bug, report it, and
then work around it, in under a week)

Was the bug in the backport, or in the mainline code? Was our code
(developed on x86) too slow to run on cheap mips platforms? What??

Another reporter claimed the patches caused UDP traffic to slow from
800Mbit to 30Mbit in his testbed environment. That was interesting
in itself and the [subject of this blog post](/post/udp_floods).

The "FQ" bug took 4 months to find and fix. Helping find and fix
it was basically was how I spent my summer vacation.

## Finding and Fixing the "FQ Bug"

With FQ on, and two or more flows, peak bandwidth went to hell, and
codel wasn't working. With ECN also enabled, there were no marks, but
plenty of packet loss. With FQ disabled, ECN on showed a normal codel
pattern of CE marks, and with ECN disabled, there was a normal pattern
of loss and SACKs on an interval close to the expected RTT.

With FQ on, the bandwidth of the flows were being regulated by
something else. There was lots of loss. Some flows would stop entirely
until a 250ms timeout.

By shaving all this latency out of wifi it seemed we'd broken TCP - with two
flows we normally would get more bandwidth, not less. But: UDP
floods showed some similar patterns - about a 25% bandwidth lossage with two udp
flows present. 

What that "something else" was was really hard to find. We explored
TCP send buffering, receive buffering, pacing on or off, disabling the
new ratt code, trying things with OSX, backing up kernels, examining
elephant entrails...

Of all the fq_codel components - the FQ portion of the algorithm had
always given us the least trouble. We'd stretched the limits of the
possible, and fallen off a cliff somewhere. Did the cpu cost of the
hashing hurt on small platforms? Hashing costs in fq_codel are high
but a distant third compared to the costs of timestamping and looping
through the dequeue step. There is a lot of code involved, a lot of it new,
a lot of it reused... Was it a wild pointer? An off by one error?
Something corrupting packets?

Felix found and fixed several bugs with wifi powersave handling. I'd found [symptoms of these bugs](/post/poking_at_powersave) months earlier, and [other anomalies](/post/anomolies_thus_far/) but failed to identify the causes. But those weren't it. We turned powersave off entirely and that didn't help.

Kathie Nichols (of [Pollere](http://www.pollere.net/about.html)) brought out her new [TSDE tool](http://pollere.net/Pdfdocs/FunWithTSDE.pdf) to analyze the captures, showing the median delay to be right in the expected ballpark of 20-30ms, but also showing it to be occilating wildly.

{{< figure src="/flent/crypto_fq_bug/DTdwnstreamq.jpg" >}}

Eric Dumazet thought that [TCP small queues](https://lwn.net/Articles/507065/) might be the culprit.  His current TCP small queues implementation makes an assumption that the  driver's completion handler will finish in (well under) a millisecond, which is more than correct for ethernet. But: wifi can take greater than 4ms. This formula in the code:
<pre>
limit = max(2 * skb->truesize, sk->sk_pacing_rate >> 10);
</pre>
assumes TX completion should happen in less than 1 ms, or even better. (note, we think this is an actual issue, still, but haven't got around to fixing it)

Andrew McGregor blamed an iperf threading problem.

Avery claimed the codel code was already slower than the FIFO queue code.

We tested all these assumptions. Nope. Performance always went to hell
with more than 2 flows present and FQ on. Everyone was stumped. We
spent months... dead in the water... stumped. 

## Personal note

Sometimes I think the only thing going for me is a clear goal and
dogged persistence - I don't have the coding chops and ability to
visualize nanoseconds Eric has, nor the deep insights into the
structure of the ath9k code Felix and Toke have, nor the experiences
and insights into TCP's behaviors Kathie, Van and Matt have, nor the
clear grasp of Minstrel that Andrew and Thomas have... I just want to
end bufferbloat in my lifetime!

And despite that "persistence" - my ADHD has really got out of hand:

I'd got my fingers into too many pies - trying to bring in the ns3
code, dealing with several ietf working groups, consulting for comcast
and google, trying to find funding the bufferbloat project for one
last year, keeping the website and mailing lists humming - testing the
code on ath10k also - getting more labs setup - building kernels for
my testbed - helping fix the FCC - I'd devolved into a :gasp:
m-m-m-m-manager - living on what Paul Graham called [the managers
schedule](http://www.paulgraham.com/makersschedule.html), someone that
doesn't know how to solve any technical problems, just *who* might -
and the whole point of me taking this trip was to finalize a bunch of
stuff, get it off my plate, and deal with the burnout! I needed less
stuff to do, so I could go deep on the things blocking everything
else, make an actual technical contribution, and I needed "just say
no" to anything new, for a while... and this was possibly the last bug
blocking a revolution in wifi performance with millions of overly slow
wifi implementations shipping per day... and I needed to somehow take
no more priority interrupts for a while.

"Dave - the Hillary campaign is on line 1!"

"Tell them I'm busy and they should just ask QCA to open up the source to the firmware and publish some !@#!@ documentation!"

"They can't help you with that. They just need your proposal for their first 100 days by tomorrow."

"They need to get elected first! WiFi can't wait!"

## Still on a personal note

During the IETF conference in Berlin... we finally gathered together nearly
everyone to a meeting at the [c-base hackerspace](https://www.c-base.org) to have a go at this.

{{< figure src="https://lh3.googleusercontent.com/hJwVJGSgtMClhfKASLjVAQ5YCO87zaIm9gcZxnmhPNekeWZ9ALa41FHPyyweZEzKWo4j4ImpJg=w4096-h2160-no" link="https://plus.google.com/u/0/107942175615993706558/posts/J7dmBEVJknP" >}}

(from left to right - Tim Shepard, Felix Feitkau, Toke Høiland-Jørgensen, and Matt Mathis)

I wish I'd taken some more pictures - we had the most people from the
homenet and bufferbloat efforts together from all over the world we'd
ever had!

Felix and Tim had a chance to catch up on the chantx issues, Tom Huhn
showed off his [minstrel-blues power reduction](https://github.com/thuehn/Minstrel-Blues) effort to everyone multiple times, Juliusz and Elektra discussed routing...  and I went from person to person, analyzing the captures in their
different ways, trying to gain an insight.

I don't remember all that happened that night (beer was present), but
all of a sudden... I started having fun again. Stumping the smartest
people from all over the planet is inspiring, and knowing that they
are just as stumped as you are AND willing to pitch in, more so.

"Pain shared is reduced, Joy shared, increased", Spider Robinson once wrote.

Still... failure.

I blew off a couple meetings, cleared my schedule, and prepared for my
last week in Denmark, with Toke. Short RTTs between us is a goodness -
we usually have a 10 hour time difference, now we could cut that
down to ms!

We had one last shot to work closely together, and we'd exausted a
long set of blind alleys.

## Back to hacking

Hacking continued. Felix found a few more bugs... actually lots more
bugs throughout the stack were fixed by lots of people, any one of
which could have been the sources of this problem... we tested those...

And finally, after everyone doing all this work, after building a
large chart of everything we'd and they'd tested, with known knowns,
the known unknowns, the data confirmed and not... Toke and I realized
that having *crypto* on or off was the key variable.

After that the problem became easily repeatable.

Toke found that the wifi queues were actually emptying 1500 times over
the course of a 30 second test.  He tore apart the pattern of the
queue emptying with histograms, but got nowhere. He also found that
keeping "some queue" queued up even when it could fill an entire txop
- cutting the size of the txop - reduced the number of fluctuations to 2
per second. This interval was enough to almost - but not quite
entirely - re-enable the codel algorithm, which depends on delays
being persistent.

Were we blowing up the hardware crypto engine? Did it run slower when
it had lots of differently destined packets? Was there too much
latency in the irq handler?

I kept seeing persistent indications in the aircaps that we were
somehow breaking the block ack window - I'd been seeing these [for
months](https://plus.google.com/107942175615993706558/posts/WA915Pt4SRN) - that the number of packets going into the air was not
necessarily the same as the number that came out - but that's always
the case in wifi - we really need better tools to look at aircaps 
- and doing that analysis by human eyeball and mental pattern
recognition should get delegated to an AI someday.

But we still couldn't find it. I gave up and started to spend my
nights talking with one of Toke's roomates, trying to clear my head
and think strategically about the problem, contemplating giving up
entirely and going off to do something easy and less stressful, like
entering national politics - while he took a deeper and deeper dive,
and periodically popped up to tell me what he'd done, and my
overworked subconcious would then come up with ever crazier ideas to
try.  Finally he too gave up, wrote up his results and [posted a thorough summary to the
mailing list](https://lists.bufferbloat.net/pipermail/make-wifi-fast/2016-August/000904.html).

... and a few hours later, Felix [zeroed in on the problem](https://lists.bufferbloat.net/pipermail/make-wifi-fast/2016-August/000907.html).

Wifi framing is dependent on 3 numbers being incremented, correctly,
in sequence - the block ack, the QoS parameter, and the crypto
IV. Crypto was a late addition to the WiFi standard.  The QoS number
came as a part of the 802.11e standard, and the Block Ack sequence
came in as part of 802.11n.

Each of these numbers is layered on top of each other in the 802.11
header and they all need to increment at the same rate at the same
time, basically.

We were adding in the IV on the enqueue step, and on the dequeue,
pushing out packets in a possibly different, fq'd order, with a
different sequence for the Block Ack - or putting out a newer IV
earlier than a later one! Most of the time, until bigger aggregates
started forming at higher bandwidths, the fq'd order would be close to
the enqueue order. When we had bigger aggregates the IV and the Block
Ack seqno could get out of sync, (or the IV itself sent out of order)
and the wifi driver on the other side would rightly start refusing to
process packets, asking for retries on certain messed up block ack
segments until it gave up.

Thus: weirdly distributed packet loss and pauses at peak times, queues
emptying and refilling many times per second, and all the other
weirdness.

The first fix involved basically moving 4 lines of code from one routine to
another, to defer asssigning and incrementing the IV until after the
dequeue. That fixed it.

On the same day, the [ns3 code for fq_codel and BQL got merged into mainline](https://www.nsnam.org/wiki/Ns-3.26) ns3, after 4 years of part time effort by everyone involved. Finally, we have a world where not only others can simulate fq_codel behaviors, but also start figuring out how to apply them to the BQL and WiFi
simulations now therein without needing hardware or deal with the
complexities of the Linux Kernel!

It was a good day.

The hackish solution for the crypto+fq bug was not good enough for the
Linux WiFi maintainer.  As it turned out, we'd not solved enough of the
problem - only handling the one crypto case we'd looked at, not
TKIP. Johnannas Berg kicked back the first patch attempts with pithy
comments.

In the end Toke moved the processing into "early" (non-time-sensitive) and "late" (sequence sensitive) handlers.

## Aftermath - the bad

* We should have asked the bug reporters for their exact configuration

Had we done that, we'd have been able to duplicate the circumstances
immediately, and we'd have made a lot more progress long before we
did.

* Debugging with crypto enabled is hard

One reason why toke and I had fallen out of the habit of enabling wpa
is that you can't decrypt the captures unless you capture the moment
in which the crypto session is negotiated. If you don't get that
exchange, the entire capture looks like a pile of garbage - you can't
see the IP headers, you can't see anything but the mac80211 headers -
and thus it never occurred to us to try crypto on or off!

Introducing crypto into the mix also increased the probability of
running into other bugs - we know there are many, and here we are,
just trying to hold latencies under load low - and being entirely
focused on that problem.

The rest of the world enables wpa encryption almost universally now.

Mae Culpa.

* Statistical analysis failed us

We tend to sample things at 200ms intervals to reduce the impact on the system. Here - things were going wrong at *200us* intervals, and it was nearly impossible to determine the patterns with classic statistical analysis.

* We broke everybody's test tools

I mean: *everybody's*. Not one TCP expert had ever seen a pattern like this before.

## Aftermath - the good

* TSDE improved

Kathie improved her TSDE test tools to look at drops and reordering,
as well as adopting a new infrastructure library to parse IPv6. You
can clearly see the carnage, now: The red dots are sequence space
holes, the black dots are out of order (seq no) packets. So, red are
likely losses, black likely retransmits.

{{< figure src="/flent/crypto_fq_bug/tsde.png" >}}

If there's a gap, there probably are no packets.

*"Looks like [Pointillism](https://en.wikipedia.org/wiki/Pointillism)!"* - she said. 

* Simon Wunderlich's lab joined the effort

They did a bunch of tests with 30 stations showing that we'd licked the
airtime fairness problem, fully, and truly. I'm tempted to make the
resulting graph the logo of the make-wifi-fast project.

{{< figure src="/flent/crypto_fq_bug/airtime_plot.png" >}}

He also showed that without fq, with 30 stations running at 1Mbit,
latency still sucked - but we knew that. The bare minium latency under
those circumstances would be close to 500ms, and he measured 1 to 2
seconds, which is more or less within expectations - still horrible -
but that's wifi for you.

But things still worked, and we moved on to trying the working code
next, at higher rates with the same number of stations, with
spectacular results.

The tool they created to look at WiFi airtime stats is now open
sourced. Get [yourself a copy](https://github.com/dtaht/airtime-pie-chart), take an aircap and see the air!

* We built a better test matrix

Our test matrix for [make-fifi-fast is really large](https://docs.google.com/spreadsheets/d/1q4vprjBz4Uvbxuc13sjlKBXNvLD4t3OZ1gfeyoZxPoM/edit?usp=sharing)... and we've added all forms of crypto to it now.

The cross product of needed things to test is so large that we've beem
asking various other labs (like unh) to pitch in and help. Click above to see what's on it!

* ECN turned out useful... for debugging

With ECN enabled end to end, I could clearly see patterns injected by the
codel algorithm - and packet loss somehow being caused elsewhere.

## And me...

Somehow I fit in emotional visits to the Berlin Wall, and Checkpoint
Charlie. I got a chance to play some music in a studio in Bristol, and
pushed back some of my incipient burnout. I also pushed up some needed
testing to *this month*, instead of November, in the yurtlab.

## Aftermath #2

I didn't expect to have got this far with the OpenWrt side of things
in the first place. I'd basically been planning a deployment, at
scale, in the yurtlab, in november, when a bunch of other pieces of
the project are slated to land.

Since august... there has been bug after bug found, elsewhere in the wifi stack. The ath10k code got a bunch of needed changes backed out, and another change (adding NAPI support), that I'm very dubious about.

But, for the ath9k, most of the needed code and hooks are upstream now. We have [test builds for multiple lede platforms](https://kau.toke.dk/lede/airtime-fairness-builds/ar71xx/generic/) - the venerable wndr3800, archer c7v2, ubnt uap-lites, and a few others - that you can try out. Patches are moving upstream. We have even more cool things left to add...

It will be a one line patch to turn them on, when the code's
done. Work continues in both lede and linux kernel mainline to get to
where we have the first ever fq_codeled, airtime fair wifi scheduler,
truly out there, for people to use.

There are still problems remaining - queues emptying a little too
often remains one, another is the possible TSQ issue - possibly
interrelated! but things are looking better and better every day.

## Conclusion

Zen helps. Giving up leads to other possibilities arising.

With enough bugs, all eyeballs are shallow.
