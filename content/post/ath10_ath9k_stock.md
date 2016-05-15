+++
date = "2016-05-04T18:02:58+01:00"
draft = true
tags = [ "wifi", "ath10k" ]
title = "So what's the stock behavior really like on the ath10k"
description = "FQ_codel is not effective if the underlying driver is overbuffered"
+++

Last week I did a string of tests against ath10k stock. For starters, applying
fq_codel at the qdisc layer accomplished *NOTHING*, as not a single packet
was dropped, marked, or rescheduled. Quite a few people lacking BQL-enabled drivers have "enabled" the fq_codel qdisc and reported that it "worked", without realizing that with their overbuffered drivers underneath it, it was not *engaging*.

They follow on by doing a straight bandwidth measurement without a simultaneous
ping. I really wish all tools measured both bandwidth and latency. Perhaps
iperf3 could be patched to do that, especially on it's udp test?

Most recently the [turris omnia folk enabled fq_codel and reported that "it worked"](/fixme)  - when it didn't engage. I pushed for a while on the group of armada 385 devs to get BQL working, but they fizzled out, and most reports of the ethernet driver of that (also in the linksys 1200) are terrible - which is 
why I've stopped doing active development on that chipset. It really helps, when adding the 7 or so lines of code that BQL requires, to have good access to the specs, and time to debug crashed hardware.

Said "fq_codel works"! - and no, their test showed it never engaging
because the armada 385 drivers had so much excessive buffering and no
BQL in them as to never exert backpressure on the stack.

But anyway, this blog entry is supposedly about a quick test of the ath10k, which also did not engage. This is what *not engaging* looks like:

```
root@apu2:~# tc -s qdisc show dev wlp4s0
qdisc mq 0: root
 Sent 8570563893 bytes 6326983 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc fq_codel 0: parent :1 limit 10240p flows 1024 quantum 1514 target 5.0ms interval 100.0ms ecn
 Sent 2262 bytes 17 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
  maxpacket 0 drop_overlimit 0 new_flow_count 0 ecn_mark 0
  new_flows_len 0 old_flows_len 0
qdisc fq_codel 0: parent :2 limit 10240p flows 1024 quantum 1514 target 5.0ms interval 100.0ms ecn
 Sent 220486569 bytes 152058 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
  maxpacket 18168 drop_overlimit 0 new_flow_count 1 ecn_mark 0
  new_flows_len 0 old_flows_len 1
qdisc fq_codel 0: parent :3 limit 10240p flows 1024 quantum 1514 target 5.0ms interval 100.0ms ecn
 Sent 8340546509 bytes 6163431 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
  maxpacket 68130 drop_overlimit 0 new_flow_count 120050 ecn_mark 0
  new_flows_len 1 old_flows_len 3
qdisc fq_codel 0: parent :4 limit 10240p flows 1024 quantum 1514 target 5.0ms interval 100.0ms ecn
 Sent 9528553 bytes 11477 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
  maxpacket 66 drop_overlimit 0 new_flow_count 1 ecn_mark 0
  new_flows_len 1 old_flows_len 0
  ```

Another point to note is the maxpacket of 64k. Ugh. GRO is in play here,
to an extent never dreamed by the original developers, who limited it
to 24K *for a reason*. Software GRO devs, ignored that reason.

Note: limiting software GRO is now a patch also in the linux mainline 
kernel.

I note that although the openwrt folk enabled fq_codel universally, there
was not the mad rush towards making BQL work. I'm pretty frustrated with this 
- most of the latest generation of hackerboards have 100Mbit phys, most have
enabled GRO, and all ship with a 1000 packet pfifo_fast queue as the default.

These would be tons more responsive, under load, if they were running 
fq or fq_codel underneath.

There's a patch generalizing codel, another generalizing fq, to be
able to be used at both the qdisc and mac80211 layer. And then there's
a patch switching ath10k to use soft irq scheduling... which landed
first, leaving the fq_codel qdisc in play...

So in the [keruffle over fq_codel_drop](/fixme), what had actually gone wrong was that
for the first time ever, the ath10k had some backpressure exerted from
elsewhere in the stack, and the results were, um, less than ideal.

Honestly, I spend too much time in a bubble, thinking that all traffic
is at least attempting to be congestion controlled, that it is being "nice".

An iperf3 UDP flood test:

```
iperf -bla
```

is emphatically *not* nice.

And thus - now there's a patch for adding bulk dropping on overload to fq_codel.

It doesn't solve all problems - the stress a udp flood overload like this puts
on the total call path in linux is enormous, and it would be better
to signal the read path that it should drop stuff identified as bad sooner, and
[people are thinking about that](/kevin). The need to drop packets in
linux, sooner, is also whats driving some interesting work by tom herbert.

## But back to fq_codel for wifi

Anyway *I'm* not testing that patchset. Running fq_codel over wifi at the
qdisc layer is not the right thing - the right thing is to move the algoritm
much closer to the wifi hardware itself where it can also be aware of
each station's parameters.

So rediculously overbuffer

*noticable* (things like mosh were even better)

## Total rrul failure

We're talking the meanest, nastiest test of them all, the

The thing that sets [flent](https://flent.org) apart from all other network analysis tools - is its ability to easily compare network related datasets over time, over potentially dozens of different variables.

Packet captures to flent for example


## Side notes

Partially because I only reserved enough space on /boot for one kernel
at a time, it seems. Resizing /boot is kind of dangerous.

Back when the yurtlab was still operational, I could be utterly sure
nobody was peeing on my channels.

BQL on everything, but the embedded world

consistentlybetterupload.svg     rrul_wipeout_2.svg
consistently_worse_download.svg  rrul_wipeout.svg
controlled_latency_cdf.svg       someloss.svg
massivelywrongrrul.svg           upload_win.svg
rrul_be_decent.svg               waybetterlatency_equal_throughput.svg
