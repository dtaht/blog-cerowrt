+++
date = "2016-08-30T12:03:58+01:00"
draft = false
tags = [ "wifi", "bufferbloat", "ath9k", "osx" ]
title = "ECN on fq_codel'd WiFi intermediate queues verses OSX Mavericks"
description = "ECN can be awesome, but..."
+++

ECN - "Explicit congestion notification" - is a means to do congestion
control without packet loss. It requires support in the routers,
clients, and servers - and despite being enabled in most servers, it
used to be disabled in most clients. Working AQMs with ECN support are
not in most routers either, until - in 2012 - we made fq_codel the
default in OpenWrt and derivatives. This enabled ECN also. That
implementation was good for ethernet but emphatically *not* optimal
for a WiFi AP. Our efforts this year in the make-wifi-fast project
have been towards making it not just work, but work well.

I usually don't expressly test ECN - since most clients have it off -
but it's often convienent to note marks rather than drops to see if
the codel AQM is actually working, and packet drops are coming from
somewhere else. Enabling ECN turned out especially useful to rule out
codel at fault while finding and fixing the [fq+crypto bug](/post/crypto_fq_bug) this summer.

ECN support is VERY important to a few folk I respect, so I took it for a spin
while testing the new [fq_codel for ath9k code](/tags/ath9k), verses OSX.

The Bufferbloat Projects' "Godfather" is Apple's Stuart Cheshire, who
wrote "[It's the latency, Stupid!](https://www.internetsociety.org/blog/2012/11/its-still-latency-stupid)" - two decades back. He created MDNS, and made
that universal, worldwide. He's got something like 16 patents, and his network game "[Bolo](https://en.wikipedia.org/wiki/Bolo_(1987_video_game))" gave me a lot of fun, back when I still had time in my life to play games. He also beat me by a few months towards developing the first IP enabled wifi AP, which I learned from a [patent dispute we both won](http://the-edge.blogspot.com/2010/10/who-invented-embedded-linux-based.html), in 2010, from work we both did back during 1998, long before we'd ever met.

He's also been a driving force in getting ECN deployed worldwide. (There are hundreds of other people involved, too!)

I'll never forget driving into Apple's headquarters in 2013 to meet
Stuart... and seeing several CeroWrt WiFi SSIDs popping up on my
handheld. It was as cool as the [day I met Woz](fixme) for the first time. We ran 3 tests, and inside of an hour, I'd blown his
mind with stuff we'd had "just working" for over a year, and solved a problem that he'd had with screen sharing for decades. That was the [second day](/posts/big_days_in_bufferbloat_history) that I thought our scruffy little underfunded, understaffed, seemingly ignored project, might actually make a difference in the world.

The work we did that day [culminated in an excellent talk - see 24 minutes in](https://developer.apple.com/videos/play/wwdc2015/719/) about why AQM and ECN were important for interactive network applications, then Stuart drove Apple's ECN worldwide test, which got ISPs to fix the remaining deployment problems it had, and what followed that was Apple's enablement of ECN universally on modern versions of iOS and OSX in this past year. You'd think that with Apple on the case ISPs and router makers worldwide would be racing to upgrade their gear to handle it... but...

Anyway, seeing how well ECN performs now on WiFi was on my must-test list, and I wanted to blow Stuart's mind again.

## Analyzing fq_codel on WiFi's ECN support

Rather than just supply pretty pictures, here are packet captures of
the same test [without ecn](http://www.taht.net/~d/2flows-iv-bug-fixed.cap.gz) and [with ecn](http://www.taht.net/~d/2flows-iv-fixed-ecn.cap.gz). Feel free to take them apart with your tool of choice. For this section, I am using tcptrace and xplot.org to generate the plots, rather than [flent](https://flent.org).

{{< figure src="/flent/fq_codel_osx/perfect_ecn.png" >}}

It's *perfect*. Not a single loss. Perfect congestion control,
completely bounded latency...

{{< figure src="/flent/fq_codel_osx/perfect_zoomed.png" >}}

Absolutely *perfect*. [Girlgenius-level coffee machine perfect!](http://www.girlgeniusonline.com/comic.php?date=20070618) (please read 4 panels!)

Where we would have had loss and a retransmit before, we now get a CE
ECN mark and drop the rate as shown by the CWR. We got results this
good 5 years ago, on dsl, ethernet, and cable, and have been trying to
get to deployment ever since.

*But* - to me - the utility of ECN is limited. The related rant got
so long that I had to put it all into [another blog entry](/post/ecn_rant). Quickly though:

Once you reduce the bufferbloat inflicted RTT nightmare with bypassing
the bulk flows with fq, and managing the rest with an aqm like codel,
even without ECN:

{{< figure src="/flent/fq_codel_osx/loss_sack.png" >}}

on this local test with the new code it only takes 25ms to have a loss
and recovery that fills the hole and allows forward progress to continue.

There's also only ~30 loss events in the entire 30 second trace (there
would be more at a lower rate, less at a higher one).

{{< figure src="/flent/fq_codel_osx/sacked_zoomed.png" >}}

This amount of delay for an infrequent loss is basically inperceptable
to humans, and the overall delays so dramatically (10-1000x) lower
than what we see today on most networks, under most circumstances,
that my conclusion then was that waiting for ECN support on the
clients was a waste of time, and we should deploy what we had,
starting in 2012.

For example the pie implementation in the upcoming DOCSIS 3.1 standard
lacks ECN support. It's still totally worthwhile to deploy AQM without
ECN! (although fq_codel has full ecn support enabled nearly
universally)

Note: Astute observers of this data might note that - why does TCP take
25ms to recover when the path delay flent is measuring is only 8ms?

Well, what we are measuring in flent is the FQ-induced delay for
sparse flows. The aqm component that codel is allows for quite a
bit more queuing for the tcp flows. It's VERY important to track how
well the AQM is actually working against TCP, but the only good way we
have to do so with the tools we currently have are via packet captures,
tcptrace, and xplot.org.

The sparse flow optimization in the fq_codel implementation sometimes
helps the replacement packet shoot to the front of the queue.

...

Adding ECN does not do much for total throughput measured over a
reasonable interval, either, and even a slight change to how tcp
itself works (pacing), only results in a fractional improvement in
bandwidth.

{{< figure src="/flent/fq_codel_osx/ecn_does_not_buy_us_much.svg">}}

Anyway, back to the rest of the tests. If you didn't think this section on ECN was overlong, feel free to also [read the ECN rant](/post/ecn_rant).

## Note: Why am I using Mavericks instead of modern OSX?

ECN is only on for a random 5% of connections and there is no way to
turn it exclusively on or off. There was a point release that fixed
this, I haven't go around to installing it, and my OSX box is my
day-to-day laptop and I live in fear of the day I crash it and cannot
recover.

One last, last note here, is that I tend to object to people using
single numbers to measuring TCP behavior.

{{< figure src="/flent/fq_codel_osx/upload_zoomed_to_show_the_ramp.svg" >}}

The roughly 2 seconds it takes to ramp up to full speed here for a
single flow is *necessary* for TCP's stable operation. Two flows, ramp
faster. A given web transaction rarely lasts for more than 2 seconds,
and is bound by the RTT - not the baseline bandwidth!  Anything you
can do to reduce the RTT is a win. I'd like to look in more detail as
to how web transactions are behaving at some point... and in the
meantime I'd really like it if more people could look at sawtooths
like these and understand that they are *good*.

{{< figure src="/flent/fq_codel_osx/download_pattern.svg" >}}
