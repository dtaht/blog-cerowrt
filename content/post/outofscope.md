+++
date = "2016-05-04T18:02:58+01:00"
draft = true
tags = [ "wifi", "ath10k" ]
title = "Everything broken in linux's 802.11 implementation was out of scope in the standard"
description = "The latest code is less borken but slower"
+++


It's late. I miss ranting at andrew, also, so forgive the upcoming rant...

(andrew, dave, I'm off course on the selective unprotect idea)

On Tue, Apr 19, 2016 at 10:28 PM, Michal Kazior <michal.kazior@tieto.com> wrote:
> On 20 April 2016 at 07:06, Dave Taht <dave.taht@gmail.com> wrote:
>> Dear Michal
>>
>> toke will be back from vacation next week. I'm trying to fill his queue...
>>
>> I spent the week trying to get a couple different pieces of hardware
>> going. I gave up and ordered a http://www.pcengines.ch/apu1d4.htm to
>> see if that will work.
>
> Neat. Let me know if you need any help.
>
>
>> I also re-read the entire 802.11-2002 spec. It really does look like
>> the selective unprotect idea would work -  you really can put NoAck OR
>> a block ack in the Qos field, and separate parts of an aggregated
>> AMPDU can have different QoS fields so long as bit 4 and 8-15 are
>> constant. There are quite a few places where not backlogged
>> this would probably help too (streams of tcp acks)
>>
>> This gets me back to my thinking it's a packing problem... (and I
>> really would like to see the performance with NoAck on universally for
>> unicast data frames, then think about a way to signal turning NoAck on
>> selectively on backlogged flows.
>
> FWIW There's a sw-retry knob in ath10k (default 0xf = 15) for
> frames/aggregates. I guess this is something that would interest you
> as well :)

Jeebus. Yes, when the darn stack is backlogged in any way, just
ratchet that down and things will get better naturally. Your bad
stations are going to make you retry more, kill them... 15??? the
default?? AGGGH.

(I have a rant about how heretical it was to have just 1 at the mac
layer in 1997...)

*2* and move to another station.

is there a retry/rate chain (as in ath9k?)

>
> Anyway, do you have some ideas when to actually light up the NoAck? I

For a quick test, half the time? see what breaks.

> guss you'd need to inspect packets at L3/L4 and do that only for TCP.

Meh, I am not huge on DPI. What I'd settled on was on packet size < 300
can care about a lot less, no matter the protocol.

> UDP tends to carry voip/sip which is very sensitive to packet loss (in
> a bad way) from what I've heard.

voip is more sensitive to jitter and delay than loss. You can easily
lose 40% of your voip packets and hardly notice in modern codecs.
(random loss is ok, bursty loss or delay is not) What happens today is
way more often jitter and delay than loss.

fq_codel fixes voip thoroughly, no classification needed.

videoconferencing, jury's still out.

> Should we just mark NoAck for all
> non-ECN TCP packets?

Yea! Lets have an orgy of losing packets every interesting way
possible until we start losing enough. :)

Would love to see data as to what happens nowadays.

but in the longer run
what I figured was that you'd NoAck larger percentages of the packets,
except the last ones per flow. So it was more "flow based" than
protocol based. As for the controller for how that might work, it
would be a bit more like pie, (and rather than dropping in the qdisc,
you'd be signalling the rate controller to run at a higher rate and
drop more packets and/or retry less...

as an undenyable indicator of congestion, an ECT(3) marked packet (CE)
could be protected more, yes. Honestly for all the hype ecn gets I
don't care about it much, particularly on mediums that are already
highly lossy in the first place. ECN makes a lot more sense on wired
links.

>
>
>> (does the ath10k do the right thing? It's not clear from reading the
>> spec how the response block ack gets formed in this case, the
>> expectation from reading bits of the spec is only the sequence numbers
>> outstanding will be acked/nacked....
>
> ath10k isn't really involved in sequence numbers and acking at all.
> It's all FW/HW offloaded.

Yes, that requires really tight timings.

Grump. But noack could work at the driver/firmware level if I/we
twisted ben greer's arm? And maybe we could get a knob for enabling
it...

OK, I will try it on ath9k. Which I think is retries 10 times still.

>
> With currently (default, "NativeWifi") tx mode in ath10k there's no
> way to specify QoS Control field. It is stripped because tid is
> delivered "out-of-band" (i.e. as a part of Tx command itself, not the
> frame payload). FW/HW later re-injects it however it feels like later.

Sigh. Another thing I kept noticing while re-reading the spec was all
the things that are wrong with wifi were "out of scope". 802.11e left
scheduling the different traffic classes to the vendors (which I hope
the binary firmware does more like cisco does it, not like linux does
with no admission controll), then there's all sorts of references to
sort of how to do it right...

from my notes:

"9.6 Multirate support
Some PHYs have multiple data transfer rate capabilities that allow
implementations to perform dynamic rate switching with the objective
of improving performance.  The algorithm for performing rate switching
is beyond the scope of this standard, but in order to ensure
coexistence and interoperability on multirate- capable PHYs, this
standard defines a set of rules to be followed by all STAs."

Aggh! Cue samplerate, minstrel, and dozen proprietary solutions!

on 802.11e's selection of each queue...

"mean data rate, the peak data rate, and the burst size are the
parameters of the token bucket model, which provides standard
terminology for describing the behavior of a traffic source.  The
token bucket model is described in IETF RFC 2212-1997 [B19] , IETF RFC
2215-1997 [B20] , and IETF RFC 3290-2002
[B24]
"

People tend to treat the cw-releated default parameters for 802.11e as
unchangable gospel rather than something you tuned to the workload...
no - cut the txop size when you have lots of stations, at least!

"The QoS AP announces the EDCA parameters in selected Beacon frames
and in all Probe Response and (Re)Association Response frames by the
inclusion of the EDCA Parameter Set information element.  If no such
element is received, the STAs shall use the default values for the
parameters."

you tuned it. dynamically. based on the workload!

"The management frames shall be sent using the access category AC_VO
without being restricted by admission control procedures."

because admission control for VO, especially, was needed!

"The AP may use a different set of EDCA parameters than it advertises
to the STAs in its BSS."

Because you need to get more airtime for the AP!

9.7's issues

"admission control, in general, depends on vendors' implementation of
the scheduler, available channel capacity, link conditions,
retransmission limits, and the scheduling requirements of a given
stream.  All of these criteria affect the admissibility of a given
stream.  If the HC has admitted no streams that require olling, it may
not find it necessary to perform the scheduler or related HC
functions."

but if the controller has admitted streams it's friggen necessary


>
> There's also Raw tx mode which doesn't require QoS control to be
> striped but I don't know how A-MPDU aggregation works then (especially
> with the NoAck policy). It'd have to be simply tested out. Surely
> A-MSDU breaks but that's probably not so important (yet I guess
> considering you want to test a theory).

I did like the "thin" firmware idea. That said, there does seem to be
some back and forth between the firmware writers and the needs to make
things work better, so...

>
>> Then I got deep into some packet captures that were just wrong, wrong,
>> wrong with endless retries on the wrong sequence numbers in the first
>> place (or so I think), put the  caps on the list...
>>
>> you don't need that much loss at high rates, I showed 25% at 6.5 mbit
>> for 4 flows in at 2ms... then I started working on "correct" packet
>> loss statistics at a variety of rates for a variety of flows...
>> testing cake again... found an ecn bug on osx...
>>
>> and now it's late tuesday
>
> Heh :)
>
