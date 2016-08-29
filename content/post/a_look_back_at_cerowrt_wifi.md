+++
date = "2016-08-26T12:02:58+01:00"
draft = false
tags = [ "wifi", "bufferbloat", "ath9k" ]
title = "A look back at CeroWrt's WiFi"
description = "How far we've come! How far we have left to go!"
+++

I dragged an old cerowrt (wndr3800) box out of the bin to compare
where we are now with where we were 3 years ago. We'd solved a metric
ton of problems with that project, but we'd not made the dent in wifi
latency we'd wanted to make.

With the latest softq-enabled code are achieving over 50% more
throughput, with 1/3 the induced latency!

{{< figure src="/flent/cerowrtcompared/oldvsnew.svg" >}}

These numbers are not achieved by any other wifi card I've ever tested
under linux, or indeed, any other operating system.

(The results with HT40 mode are a 5-15% improvement in throughput with a 30% decline in latency, not shown)

If I had any one goal with the [make-wifi-fast project](https://www.bufferbloat.net), it has been to get wifi performing with sub-30ms latencies throughout its operating range,
with 4 stations running full blast, making good gaming and voip
experiences possible, again, without explicit classification. We've
finally proved that feasible, with this and the new airtime fairness
scheduler.

{{< figure src="/flent/cerowrtcompared/boundedlatency.svg" >}}

I should be happy.

It is *possible* to do even better than this. The current structure of
the code is: one aggregate in the hardware, one, submitted, "ready to
go", and the rest being queued up in software. When the first
aggregate completes, the "ready to go one" starts getting processed by
the hardware, while a completion interrupt is generated to clean up
the tx descriptor, which fires off construction of a new aggregate,
which is considered "ready to go" as soon as its constructed and
submitted into the hardware FIFO. This leads to a natural median RTT
of what you see here - about 15ms, with a minimum of 5ms, and a long
tail extending out to 40ms (depending on retries). Both stations have
to have code this tight to get here, but...

Even the worst case latency of the new code is better than the best
case latency on the old code, *at this rate*.

At lower rates, things are even better. Where the old ath9k approach
would generate latencies extending out in seconds at the lowest wifi
rates, the new code's network latency is relatively flat across all
rates. I'd hoped to show this wonderfulness in this blog entry, but
the codebase needed a change [to solve a fq + crypto bug](/posts/crypto_fq_bug), and there is still some work needed to
round out the new [airtime fairness](https://blog.tohojo.dk/2016/06/fixing-the-wifi-performance-anomaly-on-ath9k.html)
code.

There are three other techniques that could cut this still further,
but they are kind of speculative at the moment.

For starters, let's compare this 60Mbit (HT20 running at 120 to
150mbits) result with what we could get on ethernet.

{{< figure src="/flent/cerowrtcompared/ethernetvsath9k.svg" >}}

Squint. See that dotted line on the left there, at about 100us? That's
fq_codeled ethernet, on the same workload.

Try not to be depressed. Showing that ath9k wifi still has inherently
100x more latency under load than ethernet does, is not too depressing
when you keep in mind we already knocked out 100x of what existed
before. Well, the fact that it took 4 years to get to this point IS
depressing.

How can we do better?

## Defer the next aggregate submittal until the device is less busy

The first technique is that once "one is in the hardware", we also have an
estimate for how long it is going to take to transmit (1-4ms).

We don't have an *accurate mininum* estimate for how long it will
take, we have one for the maximum time it will take with up to 4
minstrel-controlled retry chains, but we can change the code to
give us that. (and also start [reworking minstrel to work smarter](/post/minstrel))

So we don't have to start the process of assembling and submitting a
new one to the hardware until (minimum_estimate - some time to form
the aggregate).

Doing this deferral would require scheduling a softirq handler to
fire at some point after that estimate, which does involve added
overhead, and attempts to submit drivers that used a technique like
this have largely been regected due to costing extra cpu.

The advantage of this approach is that we don't need to know anything
more about the ath9k hardware than we already do, and you can get
quite a few packets in 1ms over ethernet - 6 big ones. Or some packets
arrive over the air... any way you do it, you potentially get more
packets to aggregate that you can't get otherwise.

Note: It may well be at the smaller transmit estimates we need to accrue
more than one outstanding txop in the first place, particularly at
higher than HT20 rates, with some sort of NAPI or BQL-like
tradeoff. At really high rates (>300Mbits) we're seeing a need to do
that, particularly on receive, on newer hardware like the ath10k.

## Defer next submittal until the next tx is in progress

In the real world, there are multiple stations capable of grabbing
a slot out of the wifi contention window and transmitting.

Because there is contention for the non-duplex media, the real
estimate before you can grab the media again is X + Y stations also
trying to transmit. It's worse than that - which device will win the
election, is random. One device might get a chance to transmit 2 or 3
times before another device wins. If the AP wins multiple times we end
up draining its queue without accumulating enough packets in the
reverse direction to keep a TCP flow going. If the AP loses multiple
times then latency can suffer similarly. There is a lot to be said for
real full duplex like what you get from an ethernet switch!

Regardless: the total time spent waiting for the ability to transmit
again might be 10s of ms, during which time new packets can arrive
from a variety of sources that you could assemble into the new
aggregate.

Still, arbitrarily waiting for the (minimum time - some overhead) as
per the first method described above - would ensure more packets were
available at the transmitter to send, without affecting the contention
window.

So...

IF there was a way to check or poll for the device being busy on a
receive, we could recognize that, and then wait until the *receive
interrupt* was received before starting the aggregate assembly
timer. This would ensure more packets arrived to be processed
elsewhere and cut the apparent latency still further in that case.

Better:

The most ideal solution would be if the ath9k hardware could generate
an interrupt upon actually starting to transmit what it has queued up,
which we'd use to signal the start of the next aggregate formation,
instead of the completion interrupt.

Timings are tight, you'd want to be able to form that aggregate in
under 1/10th a ms, but you'd have had a chance to accrue packets for a
far longer period of time while you knew the media was otherwise busy,
and aggregate all you've got into your eventually acquired TXOP.

## Not scheduling a tx at all until "enough" packets arrive

You *could* defer having anything in the tx queue at all until you have
a few packets worth transmitting. Most people have rejected this option,
because if you aren't competing for that contention window, you lose... but
in the case of tcp, at least, you don't care - packets will keep arriving
at a given rate elsewhere and you can take two or more txops in a row
without sending any data in return once its rate is built up enough on
a longer path.

And despite pointing out that this technique is successfully used
elsewhere (napi,ping), and that applications can take some time to
submit all their outstanding requests to the driver, and there are
pesky locks everywhere that can slow down packet delivery to the
driver - it hasn't been tried, because detecting when you are out of
packets to potentially send is a hard problem.

One solution is to keep a log of what the interpacket arrival rate is,
another would merely be to defer starting the aggregate formation
process until some reasonable amount of time has elapsed. For example,
on a router receiving packets at 100Mbit, the "next" big packet will
arrive 130us later.

There are also techniques elsewhere in the stack like xmit_more, and
we can also peek the queue to see what's there instead of blocking.

I tend to think that making a decision to schedule a txop for a given
station should be pushed to the airtime scheduler on the AP, and that
we should stay in there fighting for media access in the driver.

# Getting more bandwidth for TCP

This is not the whole story, cpu scheduling latency factors in, which is
why on this ethernet benchmark, you see the udp tests, here,

{{< figure src="/flent/cerowrtcompared/udp_vs_icmp.svg"  >}}

taking about 250us of jitter/latency because there is a context switch between
the kernel and netperf that takes a while to process. 250us is essentially
"noise" of course, at ethernet speeds, but we need to account for it.

Some of the lag here is due to NAPI batching up interrupts, also.

We may already be running into scheduling problems, if we only have
one small packet outstanding in the hardware, we may be missing
the window for submittal of the next one. This would explain why
we aren't getting as much upload throughput as we used to on the rrul test.

{{< figure src="/flent/cerowrtcompared/rrul_be.svg"  >}}

...

Modern software engineering is skewed horribly on the side of using
less cpu. Modern CPUs' inability to context switch rapidly is in part
the reason for the rise of dpdk and other alternatives that avoid this
context switch. They burn cpu cores spinning madly, polling for
packets rather than awaiting interrupts or further batching them up
(with techniques like [NAPI](ZXC) to (dpdk is a great way to heat data
centers)

There are sound reasons to want to use less cpu - it frees up the cpu
for other applications, it saves power - but in all cases, batching up
interrupts violates a basic principle of packet conservation - the
fluid model. 

## A look at existing code

In ath9k/xmit.c

The capabilities of the hardware are ironic. Each of the 4 queues can
have an 8 deep fifo attached. This means that at worst case transmit
rates, the hardware can have 128ms worth of packets queued up without
further intervention. We're running the fifo depth effectively at 2*8
now, and an end goal might be to nearly eliminate the BK queue in
favor of better aggregation, and soft limit the entrance to the VI and
VO queues so that we supply a limited amount of airtime and backlog.

{{< highlight C >}}
enum ath9k_tx_queue_flags {
        TXQ_FLAG_TXINT_ENABLE = 0x0001,
        TXQ_FLAG_TXDESCINT_ENABLE = 0x0002, // what does this do?
        TXQ_FLAG_TXEOLINT_ENABLE = 0x0004, // what does this do?
        TXQ_FLAG_TXURNINT_ENABLE = 0x0008, // what does this do?
        TXQ_FLAG_BACKOFF_DISABLE = 0x0010,
        TXQ_FLAG_COMPRESSION_ENABLE = 0x0020,
        TXQ_FLAG_RDYTIME_EXP_POLICY_ENABLE = 0x0040, // ?
        TXQ_FLAG_FRAG_BURST_BACKOFF_ENABLE = 0x0080,
};


	/*
         * We mark tx descriptors to receive a DESC interrupt
         * when a tx queue gets deep; otherwise waiting for the
         * EOL to reap descriptors.  Note that this is done to
         * reduce interrupt load and this only defers reaping
         * descriptors, never transmitting frames.  Aside from
         * reducing interrupts this also permits more concurrency.
         * The only potential downside is if the tx queue backs
         * up in which case the top half of the kernel may backup
         * due to a lack of tx descriptors.
         *
         * The UAPSD queue is an exception, since we take a desc-
         * based intr on the EOSP frames.
         */
        if (ah->caps.hw_caps & ATH9K_HW_CAP_EDMA) {
                qi.tqi_qflags = TXQ_FLAG_TXINT_ENABLE;
        } else {
                if (qtype == ATH9K_TX_QUEUE_UAPSD)
                        qi.tqi_qflags = TXQ_FLAG_TXDESCINT_ENABLE;
                else
                        qi.tqi_qflags = TXQ_FLAG_TXEOLINT_ENABLE |
                                        TXQ_FLAG_TXDESCINT_ENABLE;
        }
{{< /highlight >}}
