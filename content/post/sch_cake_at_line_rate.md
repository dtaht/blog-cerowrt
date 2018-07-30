+++
date = "2018-07-25T18:02:58+01:00"
draft = true
tags = [ "bufferbloat", "flent", "rants" ]
title = "Running sch_cake at line rate"
description = "Let packets be packets!"
+++

When you've worked really hard and got used to cake regularly having
half the interpacket latency fq_codel and sch_fq have...

When I discovered in upstreaming it GSO got turned always on at line rate,
and always off when shaping <= 1Gbit.

When used at line rate it doesn't split big bursty packets. During all our testing it always split up GRO/GSO/TSO etc.

Line rate can be 10-1000mbit on ethernet hardware (with pause
frames). It can be even less on other hardware or faster. Running at
line rate, with variable backpressure supplied by BQL, is a "nice
thing". It's great that cake used to run the same by default shaped or
unshaped. That is, in part, why it always split GSO before.

I started this rant because I was puzzled about getting twice the
latency and jitter I used to, from the "final" cake, unshaped, on one
of my main servers (that does audio/video distribution). After some
digging I realized we'd made a mistake in the final patch set to not
split gso always. I missed that patch when it went by. I had burned
out on the debate.

This initial burst bloats BQL by a factor of 3 at one gbit ethernet,
and doubles the interpacket latency against 4 flows.

So here are my arguments for always splitting gso by default shaped,
or unshaped, unless you explicitly turn splitting on:

the mvneta would software assemble 

* Nat offloads

Cool. You'll be more inclined to get a box that does software nat
than not, just so you can run cake. The odds of you being stuck with
an ancient kernel with those kind

Win.

and while they gain on speed, the resulting product tends to be more buggy
and 

* Cake's principal use case is to be a network gateway qdisc.

Sure, absolutely, run it on a host, see what happens.

* TBF also always splits GSO

Why should one qdisc not do that by default, also?

* GSO Transits the routing table as one chunk.

Disabling GSO on an ethernet driver forces that decision all the way
up the TCP stack. Doing it "on the sly", means that you can TSO all
you want on the stack, transit the routing table, and then get turned
back into packets by the qdisc.

Win. Routing table lookups are *expensive*

* "You can disable GSO/GRO/etc via ethtool!"

Driver-writers are all enthusiastic about software GRO because it
makes benchmarks look better. In the real world full of entropy, it
doesn't accomplish much except bloating both the network and the
codebase up.

Vendors don't ship ethtool. Even if you have it, fiddling with
gso/gro/etc is an undertested or under-implemented code path and
fraught with (t)error. Some let you set it, but ignore it,
also. there's no good

gso-splitting in cake by default exists as we (the dev team and early
adopters) had forgotten to disable tso/gro/gso so many times and
messed up so many results.

Users have no idea which end of ethtool is which.

It's far better to split packets back into packets before hitting the
driver. Always.  Making it bulk things up to save cpu should always be
a tunable. At least, with GSO on you transit the routing table all in
a bunch.

If I had my druthers I'd make NAPI less bulky too.

If I had a spare billion dollars I'd work on the Mill CPU which can do
32 ops/cycle and context switch in 5. I HATE all the spectre patches
going around because they disable speculation, run a whole lot of
extra code to do so... AND you *still* can't context switch worth a
damn on any processor affected. I hope to gawd risc-v will be better.

Hopefully someone elses have the spare billion dollars to switch NICs
to using timer wheels as [Van Jacobson suggests](), and write a new
hardware-offloadable FQ+AQM system that is even more entropic and
really scales across multiple cpus. I know how to write one but am
short a few years pay on cake as it is.

* GRO is important!!!

Yes it is! The read-side path of linux, particularly as you get past
4Gbit/sec, has become a far more serious bottleneck than the transmit
path. The two paths are *way* out of wack nowadays.

This is one of the reasons why I've not tried for perfect entropy in
fq_codel sender side. It's "bad enough" that we dynamically down the
quantum. 

I *had* done a more SFQ-like version of fq_codel in early versions of
cerowrt, but although it "felt" better, with the tools we had at the
time the results were impossible to measure.

In an idealized fluid model we'd send A1,B1,C1,D1,A2,B2,C2,D2,A3. (Actually you might randomize even that a bit). But sending A1, A2, A3, A4 in a bunch
seemingly makes GRO and the tcp stack work better.

fq_codel, cake and so on send MTU-size bursts of acks. We've actually tried
to make the point that with a "perfect" ack-filter and bunching like that,
that we can compress ack streams and thus have even less processing up
on the other side of the data center.

Getting kernel to send less acks in the first place is TRICKY.

Because two packets back to back trigger an ack

In cake we actually reduce the quantum so as to send less and less big
packets at lower rates. We cap the quantum at 300 as that was the best
number we could achieve while still being fair to ipv6 and ipv4 acks.

qdisc cake 800c: dev enp6s0 root refcnt 2 bandwidth 10Mbit diffserv3 triple-isolate split-gso rtt 10.0ms raw overhead 0 
 Sent 203113620735 bytes 140847783 pkt (dropped 76632, overlimits 0 requeues 20983) 
 backlog 0b 0p requeues 20983
 memory used: 946616b of 4Mb
 capacity estimate: 0bit
 min/max network layer size:           42 /    1514
 min/max overhead-adjusted size:       42 /    1514
 average network hdr offset:           14

                   Bulk  Best Effort        Voice
  thresh        625Kbit       10Mbit     2500Kbit
  target         29.1ms        1.8ms        7.3ms
  interval       58.1ms       11.3ms       16.8ms
  pk_delay          0us         11us          3us
  av_delay          0us          2us          2us
  sp_delay          0us          1us          1us
  backlog            0b           0b           0b
  pkts                0    118779517        18798
  bytes               0 203226241219      3356924
  way_inds            0       401599            0
  way_miss            0         2161            9
  way_cols            0            0            0
  drops               0        76632            0
  marks               0       106171            0
  ack_drop            0            0            0
  sp_flows            0            1            0
  bk_flows            0            0            1
  un_flows            0            0            0
  max_len             0        68130         5260
  quantum           300          305          300


* "Always split-gso disables by default a key linux feature that
  nearly everything else uses. It saves cpu! Lots of CPU!"

Doesn't matter on a modern x86 box a typical end-user has at typical
workloads. cake's hard to measure at 1gigE.

so... let cake be a good counter-example by default of what can go right and
wrong if you always treat packets as packets. There's no good or safe
way to disable GSO/GRO/etc on many drivers in the first place as noted
above. There's no data on what smoothly FQ'd flows do through virtual
ethernet devices. There's no data on a lot of cool things cake does,
our attempt at throttling massively unresponsive flows via blue being
one of them.

I already pointed out that bql size is 1/3 of what it is with GSO on.

If you don't run out of cpu what can you do?

* But that big TSO offload of that initial burst lets us ship and close a whole
 network transaction in one lump! We can do millions of flows that way!

Not doing pacing of that initial burst is one thing that bugs me about
current linux tcp. I [don't like IW10 much either]().

Theoretically, IW-anything is an artifact of not doing FQ in the first
place on our networks. It's not needed. In reality... we don't know.

OK, so cake can be effectively IW1, adding new flows to the
network smoothly, as space allows, always FQ-ing. It works
terrifically well on network gateways. Does it work elsewhere? Dunno.

Cake, when shaped, by default, does some "initial spreading" to IWXX
based bursts while tcp is in slow start. It doesn't, quite, when it
needs to fill the bql queues at line rate, but the rest of the time,
when loaded, shaped or unshaped, it does. Part of the point of cake is
to minimize those bursts to a bare minimum and inflict the bare
minimum of jitter on other flows, like those coming from a game or
voip server.

I thought distributing cake with the default behavior of NO TSO BURSTS
EVAH!  aught to be interesting. I look forward to more field
measurements. I imagine that short flows FCT will get slightly worse due
to this, as the gain we get from the fast queue for syn, syn/ack for
all flows, gets spread out by the IWXX burst for the next 7 packets,
but I really don't know. I certainly expect cake to transit virtual
machines worse than GSO but I also expect interpacket latencies to
stay lower so long as cpu exists.

(And you still distribute that burst from as "one lump", it just takes
an appropriate amount of time for all the packets to arrive based on
the number of flows in the network and the cleanup handler gets spread
out too.)

Trying to make the point that maximizing entropy also leads to more
reliable smoother RTT measurements for TCP, less retransmits, smoother
capacity grabbing, and less retransmits, less impact on other
applications, is something that cake might do at these higher rates,
outside of the research field. We won't know unless we find out.

Again, have I mentioned that if you want to run cake in a DC, you
should know what you are doing? If you want to run cake as a normal
users might, you should need to know nothing.

I wish I'd fought harder for nat-by-default.

* "But my workload is all TCP!"

Great! run sch_fq. sch_fq is really awesome for hundreds to millions
of flows in the data center. Cake can run a smaller (sub 500
concurrent flows) workload than sched-fq at way less buffering and
self-inflicted RTT than sch_fq can at the same utilization. That many
apps using the network share really fairly, tcp, udp, or whatever.

cake's quantum is a single packet. sch_fq's is two. cake applies codel
to everything. sch_fq relies on TSQ but keeps 16k around at all times.

This is 

* "But with GSO on we can run at 50Gbit!"

Great. At 1Mbit 64k can cause 546ms worth of damage *per flow*.
Swallowing burps of any size causes collateral damage to codel. Your
typical cake usage today is shaping to well under a 10 mbits on an
uplink.

If you are crazy enough to want to run cake at data center speeds, you
are also hopefully smart enough to disable other features you don't
need like (perhaps) triple-isolate, diffserv3, nat, fiddle with the
metro setting, and tell it to preserve gso with the new no-split-gso
option.

We already nuked "nat by default" in upstreaming sch_cake because it
brought in the relevant netfilter modules against the high-perf-guys
wishes. OK, I can live with that, it just means per-host fq requires
that nat be specified, and if you goof, you more or less revert to
flow based fq. Harm done, hard to find, but not huge.

I note: luci-app-sqm hasn't been updated to automatically specify nat
for cake as yet. *I* forgot to update it during my initial testing of
the new code and we have no sane way of telling users in the field to
update their conf file or gui for themselves. I figure at least half
the users configuring cake in the field that need "nat on" will
forget. then we'll get "per host fq isn't working!" or worse, people
will be deluded that it is on, and conclude it doesn't help.

Autodetecting nat being on has always been a problem for users,
routing protocols, firewalls, etc, etc.

Then... remembering to stress the pain points of no-gso-split, not so
much. What gui option do you want for that? The effects of always
having sanely sized packets are difficult to quantify except in terms
of user QoE and finely grained jitter measurements.

Given the thousands of hours of testing cake with "packets as
packets", I'd just as soon deploy that and see what people see.

Even expressing gso to end users is a problem.

* "but... 50Gbit!"

This is still slower than what other HTB+qdiscs can do at least last I
checked. Sure, there's a use for something handy that can run and
shape above a gbit, and if you want to preserve GRO, specify that when
you do so.

tc qdisc add dev whatever bandwidth 40gbit no-split-gso

I'd LOVE to see cake made competive with htb+something and
(especially) run (with shaping) well across multiple cpus. We've not
done the level of detailed cache line analysis required, nor optimized
a few data structures, and really, if you are going to shape, you
should shape across multiple cpus with some sort of scatter gather
algorithm distributing the allowed bandwidth.

* "But... 50Gbit!"

Of the hundreds of machines in my deployment, personally, only two run at
10GigE... and they are hooked up to each other. Most run at a gbit. A few
have hw flow control and run at much less. A lot are hooked up via wifi
(at 100mbit, yes, with flow control and gro disabled on what's connected to them).

I tend to think my deployment looks a lot more normal worldwide than
your typical data center deployment. Does your laptop have > 1gbit?
Your TV?

* ack-filtering works better without GRO.

... Untested, but ack-filtering on gro-splitting should work better than not.

* Our packet stats are way more accurate with gso-splitting

... as we are counting, um, packets. Taking actual statistics on actual packets
is actually freaking useful, 'cause then you can look at buffering and get
a grip on how many actual packets are actually traversing the link.

* "We should make GSO automatically adjust better".

It doesn't on deployed gear. Certainly GRO doesn't on deployed gear. Part
of why we split GSO by default is because the mvneta and edgerouter don't,
and we see 64k bursts coming in from the offload engine and from
clients doing things like IW10 in slow start, that hit the gbit onboard
switch and then have to shit out through a paltry 5mbit uplink while some
gamer is desparately trying to shoot someone just around the corner.

* "GSO splitting eats cpu!"

... but makes the network better. CPUs are cheap. If you run out of cpu,
the order in which you should disable cake features is actually:

besteffort # diffserv classification hurts
# Or buy a faster box
nonat # the default, now actually, is running without nat
# Or buy a faster box
flows # disable triple-isolate
# Or buy a faster box
no-gso-split # 
# Or buy a faster box
tc qdisc replace dev whatever fq_codel
# Or buy a faster box

* "I want cake to be my default qdisc!"

I'm (we're?) not pushing for cake to be the standard "default" linux
qdisc. We pushed for fq_codel to become that, and have mostly
succeeded. I do think cake is close to ideal for modern ethernet
network devices and cpus running at or below 1Gbit, and the best thing
ever made for network gateways. Even then there's a lot of devices
hooked to 100mbit macs that cake could help, and a lot of devices
hooked to a gbit mac that even pfifo_fast can't help.

For DCs... we don't know, but we'd like the defaults to remain best 
for the current use case. We know the metro setting works well at GigE,
for example. 

For hosts...

Cake's certainly *my* default qdisc and I'd kind of got used to half the
latency and buffering that sch_fq inflicts, effective hw flow control, etc,
etc, everywhere I'd deployed it. I have workloads that are not tcp (video
security cameras). sch_fq treats udp as a second class citizen, cake treats
all flows equally.

I would like to see cake be a default qdisc for jittery devices running at
below 1Gbit that use hardware flow control (and BQL) in particular, like
cable modems, ethernet-over-powerline, etc. I'd like to see the ideas in
cake challenge a few conventional assumptions and inspire future work.

* "Users should just shape at 1Gbit or below"

Shaping eats cpu. Running at line rate eats less. Running at line rate,
even always gso splitting, eats less cpu than shaping below 1Gbit.

In either case you end up with BQL acquiring some fixed amount of buffering
to mitigate interrupts. I really wish there was a way to get rid of even 
the 40k of BQL buffering we get now at 1gbit.

Shaping is not as reactive as running at line rate without GSO is.

* "We can make GSO autosizing better!"

Actually, it's already pretty good, but does nothing for GRO.

* "You can disable GRO!"

See ethtool issue above. And (in the example of a many other)
you want it on all the other ports.

* But... Bandwidth!!

Come on, don't you know who you are talking to?

"Once you have bad latency, you're stuck with it".

* Any questions?

