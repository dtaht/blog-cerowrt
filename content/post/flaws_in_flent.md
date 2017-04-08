+++
date = "2017-02-11T19:02:58+01:00"
draft = true
tags = [ "bufferbloat", "rants", "flent" ]
title = "Flaws in Flent"
description = "Engineering to the test - especially your own test - can be deluding"
+++

[Flent](https://flent.org) has been the test tool of choice for several
core researchers in the [bufferbloat](/tags/bufferbloat) effort.

With it - in a matter of minutes you can replicate any network stress
test "out there" and compare networking results across an extraordinary
number of variables, over time, across many tests. Before
[Toke](https://blog.tohojo.dk/) developed flent, it would take days to
set up a single test and single plot. Now you can be deluged in data,
and can investigate network behaviors in minutes that take other
engineers months, accurately, over each change you make, with comparable
results in a standardized file format, and a zillion useful plot types.

Flent leverages other well regarded test tools to accumulate its
results, notably [netperf](http://www.netperf.org), which is the network
performance tool of choice in the Linux networking community.

Best of all, flent is free (GPLv3) software, and it's easy to get up and
running on Linux and OSX. The windows version is only capable of
browsing and plotting test results, at the moment. (You can use a
windows box as a netperf target).

There have been
[many network bugs and fixes found with flent](/post/found_in_flent).

Despite the title of this blog entry, *I love flent*, and how useful it
has been (see above link) but I felt the need here to express what it
does and where you can go wrong, when using it.

Getting "standard statistics" out of any network test tool
----------------------------------------------------------

Now... I didn't do much programming on flent myself. It uses python, a
language I don't care for much (the GIL, and the syntax, primarily). I
wrote the stuff that needed to be hyperfast (in C), and I essentially do
QA on whatever Toke dreams up. QA is a thankless task, but the core dev
shouldn't do it - there are good reasons to have both a dev team and a
QA team (or blue vs red teams).

I've focused on good plotting of two or more variables against each
other as network behavior is hard to boil down to a single "number",
as much as others have tried with things such as measuring "Bandwidth"
or "jains fairness index". It's a heisenbug principle - you cannot
measure the capacity of a pipe at the same time as the path length -
something that
the [TCP BBR](http://queue.acm.org/detail.cfm?id=3022184) folk finally
got right (after 30 years of trying).

Flent *can* produce standard statistics from any test, as well as
detailed output that can be used in other plotting tools.

```
flent -i datafile -o plot.csv -f plot
```

What I regard these as most useful for is: disproving to statistics
minors that guassian statistics measure anything useful when it comes to
network behavior! You should care an awful lot about everything above
the 95th percentile, for example, and most stats folk just chop that off
before even starting an analysis.

[Amdahls law](https://www.pugetsystems.com/labs/articles/Estimating-CPU-Performance-using-Amdahls-Law-619/) applies quite firmly to network behaviors - the
total time to complete a network transaction is bound by the speed of
the slowest portion of the transaction. Recently I saw that someone had
independently rediscovered that 50 year law and called it
[FIXME](FIXME). Sigh.

Speed up TCP all you like, but if your DNS fails most of the time, you aren't going to win. Fix DNS all you like, but if you pound packets through DNS to make absolutely sure you always get a result, and you'll slow everything else down. If arp fails, you are going to get nowhere (literally). Change multicast all you like, and you'll break something else. And so on.

Deeply "getting" Amdahl's law really important. It's wedged into my
bones by decades of real-time programming my part. Everything can slow
you down - from dns lookup failure to happy eyeballs timeouts, to TCP
tail loss, to retransmit delay... and you need to be aware of and fix
everything in this incredibly complex system of system, networks of
networks that is the modern internet today. You fix one thing, you have
to play wack-a-mole on the the next thing that crops up.

Anyway, I tend to use the raw (all or all_scaled) plots in flent - first
- to validate sane stuff happened, and the cdf plots to cover the entire
range of the data, to understand what really is going on. Then maybe a
"totals" bar plot to make it prettier - but always AFTER looking at the
rawest data to ensure it is sane.

Incidentally, despite me dissing "Standard statistics" here, I keep
hoping that some new statistical distribution and related tools would
apply to networking. One candidate is: [FIXME](FIXME)

Box plots
---------

Box plots, in particular, can lie. Use the raw plots *first*. Your
box plot isn't going to show variants of behavior like this:

{{% figure src="" %}}

We had a similar result where certain kinds of ipv6 traffic caused an
instruction trap and 2-3 second burp in the network while it recovered.
The bar plot only showed an 10% decrease in performance under ipv6 in
the lab... seemingly acceptable (overhead, other reasons, seemed plausible)

... until we put the box on a big ipv6-enabled network where it slowed
to a crawl, perpetually handling instruction traps.

*OUTLIERS MATTER*

*ALWAYS LOOK AT THE RAWEST PLOTS FIRST*

Learning how to read the error bars in the whiskers is kind of hard
too...

... especially if you don't trust the data you got the whiskers from in
the first place!

There are a lot of different box plot types out there. One type I'm fond
of (that flent doesn't do) is the seven number summary - partially
because what's above the 98th percentile is *interesting* and we'd
rather show more detail.

## Flaws in the rrul test itself

I am the originator of the RRUL ("Realtime Response Under Load") test
which sometimes I am fiercely proud of and sometimes I regret. Comcast
asked me to write a spec for something nasty and simple that showed how
bad bufferbloat could get, and... well... I did. Then Toke implemented
it. And the rest is history.

There are so many ways to do badly on the RRUL test that it's difficult
to break them all down. I designed it to break the most stuff the
fastest, and while I can point to a "good result" pretty easily -

{{< figure src="/flent/good_results/example.svg" >}}

Explaining everything that can go wrong would take pages and pages -
which I intend to do someday ([here's some](/posts/found_in_flent)) - in
the hope that more folk learn to read a rrul plot and what it means.
What you should look for is "smoothness", overall latency and jitter,
bounded, and multiple flows sharing fairly, and the short measurement
flows not being lost. Positive (but not necessary on a modern network)
things to look for is classification, actually working.

I need to stress that relying on any one test overmuch is a tad foolish.
The RRUL test was designed to break everything on the Net I knew to be
broken in 2012, in under 60 seconds. Life is short. Long tests lose user
interest quickly.

What I had always intended was that the "fail the RRUL" phase to be
followed by individual measurements with simpler tests, like single
tcp up and downloads, followed by multiple tcps, etc. There are also
many valuable pre-existing tests out there - like packets per second -
well worth running.

But at the time RRUL was designed it seemed that a hopelessly large
amount of the Internet today was engineered to pass the "speedtest.net"
tests - which are a string of tests that run for less than 20 seconds
each, and test for latency independent of bandwidth. If you ran a
speedtest-like test for 22 seconds rather than 20, everything
exploded, like a dragster at the end of a track.

The
[dslreports bufferbloat](http://www.dslreports.com/speedtest/results/bufferbloat?up=1)
tests (co-designed with members of the bufferbloat.net mailing list) are
MUCH better than speedtest in that they do test for latency under load... but they
still don't last long enough to extrapolate the results for the long
term, and certainly do not run long enough (by default - you can change
the length) to test gbit links fully. They
[chop off all data after 4 seconds of latency](http://www.dslreports.com/speedtest/results/bufferbloat?up=1), also, and we are
[well aware that many, many seconds of latency](FIXME) exist beyond that
on various connection types.

So... I do not look forward to a day where the internet is re-designed to
"pass the RRUL test in 60 seconds". That would mean any breakage after
that period would be my fault!

For the sake of the internet, and your own sanity, (and mine!) never
conclude that a network test of any length is a reliable predictor of
what will happen at length * 2. Always test for the longest periods
possible, when you can... [At different times of day](fixme), under
different conditions and delve into the details, as there may be dragons
there.

One example of how short testing can screw you up was the recent, and maddening
[wifi short period anomaly is here](/post/channel_scans_suck) -
where *weeks* of 1 minute long test data were *sometimes* permuted by a
wifi channel scan and we only figured that out extending the length of
the test to 5 minutes, from 1.

I'd fallen into the habit of looking at my summary data only, assuming
that the rest of the network was behaving correctly. (It WAS - on OSX).

We found another network crash bug, once, that took 26 minutes of
continuous testing to tickle. [And another](fixme), with a counter
overflow in odhcp6 that took 51 *days* and hammered your network
perpetually afterwards.

ASIDE: I'd really like to find a way to run an OS and tools 10-100x
faster than real time in qemu, so we could find bugs like those and have
more hope that a deployed product would survive years in the field. Slow
memory leaks are really hard to find, counter overflows, also.

## The flent RRUL test isn't actually the rrul test as specified

The
[original RRUL specification](https://www.bufferbloat.net/projects/bloat/wiki/RRUL_Spec/)
specified isochronous traffic and wanted one way delay (OWD) for the
measurement flows and also timestamps within the TCP flows. This turned
out to be (way) too hard to implement in 2013, and in flent. We also used
(as it turned out) a diffserv marking commonly not optimized for in most
networks.

Someday, perhaps we'll get a RRUL test that is more correct. I've
already got a name for it - Corrected RRUL. Call it: CRUL.

And then... we'll find some other reason why it's broken, and some
other common traffic type (google standardized on AF41 for
videoconferencing for example) we need to be measuring.

## Flent uses RTT measurements rather than one way delay

There is a pretty basic flaw in nearly all of flent (per above) in that
it mostly uses RTT based measurements and what's really needed is
measurements of one way delay on (fixed) isochronous intervals (say, 10
or 20ms), and/or measurements within each flow to truly "get" whats
going on.

The problem with the latter problem is no tool does it, and at the
higher rates (like 10Gbit) actually doing timestamps well is problematic.

The former problem is that few good tools for creating isochronous
traffic exist. Flent has a test built around the d-itg voip simulation
tool, but d-itg is not exactly "safe" to run on the open internet, and
I'd like something with hard realtime privs that used fdtimers to get
accurate resolutions below 10ms.

[owamp](FIXME) has much promise but I still don't trust its
measurements: lacking both realtime privs and fdtimer support,
and it needs *good* ntp or ptp sync on both sides to work right (which
is really rather unneeded for a short test).

Avery's [isochronous](fixme) tool is of some use, but again, unsafe to
deploy on the wider internet without some sort of 3-way handshake to
kick it off.

Leveraging QUIC has always been on my mind, but until recently no usable
libraries existed.

## RRUL overstates the impact of bidirectional traffic on asymmetric links

Because it stresses out both the up and download paths equally, the
slowest part of the (usually up) link dominates the induced latency.
Most use cases for the internet are downlink mostly.

The real number for latencies you can actually achieve with fq_codel
(and cake) is actually, far, far less, once you get a decent uplink for
the rrul - or use tests like tcp_ndown, or web simulate tests, to see
the chocolately goodnesss.

RRUL is intentionally modeled on bittorrent - which usually has 5 active
flows up and down, and is symmetric (using 4) because that made it more
possible to have a range of easily comparable tests. The mis-diagnosis
of what bufferbloat was doing to bittorrent's assumptions is how the
bufferbloat problem was first seen, massively, in the wild.

Ironically it had been my intent to model torrent fully (there's a test
for it in the flent suite), but a working ledbat implementation for the
linux kernel has never arrived.

## Flent works best at speeds greater than 4Mbit

A huge flaw in much network research today is that researchers tend
to focus on achievable speeds in the lab, and are perpetually posting
results in the 1mbit to 10mbit range - or - focusing on the 100Gbit
range - and nothing in-between where all the real end-users are.

Our focus with flent has been measuring actually achieved rates in the
field, which for ISPs ranges from 384k up to a gigabit - measuring
queue depth, cpu overhead, etc. Some binding variables there include
the size of the initial window also, but pacing, recv and send buffering,
and so on start factoring into play more. At higher speeds, loss rates drop
dramatically, in particular.

We've successfully used flent at speeds up to 40Gbit. Most of our
testing has been in the range 4-200Mbit as those are the upcoming speeds
of the internet and within the range of most wifi. Of late, we've moved
towards testing the gbit speeds now more common on fiber and 802.11ac
class WiFi.

TCP's behaviors at lower rates are bound by different variables than
TCP's behaviors at higher rates. Of issue are the size of the
[Initial Window](https://tools.ietf.org/html/draft-gettys-iw10-considered-harmful-00),
loss rates, the size of the receive window, and ssthresh, and the actual
TCP used.

One of the hardest problems to measure is what happens at a range of
achievable rates from 1Mbit to 1Gbit in the same session, as in
[wifi](/tags/wifi), or in [route flaps](/post/babel_half_fail)

Nobody has a good emulation for wifi's behaviors today. It seemed
simpler to just go forth and implement the new queueing ideas we have,
in Linux directly, and go measure that, and wash, rinse, repeat.

That took [three years out of our lives](paper pending sorry soon).

Anyway, flent samples at a default sampling rate too high and uses too
many flows to get decent plots as you drop below 4Mbits. The fact that
this graph looks "spotty", is a flaw of the measurement and not the
test!

{{% figure src="" %}}

But: it is also a key example of why the modern internet does not work
well at these speeds anymore. The default IW10, and TCP offloads, in
particular, are very damaging to your link at these speeds.

## Flent (and most web benchmarks) are testing multiple flows

Actually, testing single flows can be revealing. This is a long distance
test (72ms baseline latency to Newark from San Francisco) that clearly shows 50ms
of overbuffering on the sonic link, vs the effects of codel, vs the
current behavior of cake.

{{% figure src="http://www.taht.net/~d/sonic_cake_vs_fq_codel_vs_fifo_70ms.png" %}}

See cake taking off very slowly there?

This "mis-feature" is in cake primarily because codel reacts too slowly
to dealing with multiple flows in slow start on slow networks, and can
overshoot - causing excessive latency on your line that can be hard to
clear out. (you can see the codel overshoot (multiple short 50ms latency
spikes) if you squint - or are running a voip call or other isochronous
stream). (Still, we need to tune this cake better in the long run)

Web browsers start tons of flows. I've lost hope people will stop using
IW10. Network behaviors like this
[hurt your internet experience](https://danluu.com/web-bloat/). Cake
stomps on stuff in slow start early, and *hard*. TCP theorists hell bent
on achieving maximum throughput for one flow are going to hate us for
that, but folk in the 3rd world, (like, America) will love it.

There's a new error in the world that has cropped up. In testing sonic
fiber, using [their tests](FIXME), users happily report gbit throughput - but
that comes from using multiple flows across multiple machines across
their infrastructure.

In my tests, any set of flows to one destination seems to be
rate limited to a total of about 130Mbits.

(I don't blame Sonic for this, it is a sane reaction for an ISP to try
to offer low latency. Per host fq is a semi-effective means to do that,
and sonic has been the best ISP I've ever tested with that native
buffering of only 50ms - which I promptly reduced to near zero above
with cake/fq_codel, and I have been puzzling over the 2-10ms long path
jitter with multiple flows on long duration tests ever since:

{{% figure src="http://www.taht.net/~d/sonic_106_cake_vs_default.png" %}}

I also don't currently understand *how* sonic did this. Is it a feature of GPON? Or
is my TCP running out of some window? What?)

Testing 2-3 flows can also be revealing. There was some good research
published recently showing codel had an issue with 3 flows.

I don't care about the interaction of 1,2,3 or even 4 flows. I care
about the interactions of up to hundreds of flows on real, edge, links.
The days where you cared about getting max throughput out of a single
flow are hopefully long dead (except for those that care about it!)

## Flent doesn't count tcp acks as part of the overall traffic measurement

Flent does not account for tcp ACK traffic as part of the overall
bandwidth tracked. Flent does not also fully account for the size of the
measurement flows.

If you observe a small decline in bandwidth at a reduction in RTT from
100 ms to 10ms, at least part of that is due to the increased ack
traffic and increased amount of measurement flows.

I've longed to have an "ack estimator" available (basically adding in
1/40th the size of the sent flows on receive on ipv4), and to add in the
costs of the measurement traffic - just to have an gauge of whether or
not I'm fooling myself. Also to detect when ack decimation (or stretch
acks) seemed to be taking place. But without accurate statistics
gathered about the acks, such an estimator would be lying most of the time.

## Resolution issues

Once measurements start getting down below 5ms, all sorts of measurement
noise enter the tests -

* ICMP pings - which are responded to by the kernel - start responding faster
  than UDP based pings - which have to context switch into user space. Sometimes.
  Some kernels deprioritize ping, or amoratize it!

* You will typically see ICMP-only tests jitter a lot 100-1000ms) on wifi, due to
powersave being on.

* RTT based measurement flows start becoming significant percentages of
  the traffic - dropping a queue from 10ms to 1ms increases the
  measurement traffic by a factor of 5. So you might "see" a latency
  improvement and a corresponding decline in bandwidth that is not,
  actually true. The fix is to run a test without the measurements.

Take any observed difference in performance under 5ms cautiously, in
flent. Someday, perhaps, we'll come up with ways to accurately measure
things below a ms.

## Sample size is large by default

The default --step-size is 200ms in width - this is both to reduce the
heisenbugs introduced by the measurement portions of the text and to lower
the overhead of sampling in the first place.

When trying to operate at resolutions lower than 50ms, other tools,
like fping, start getting behind - finding/writing a ping tool that could
accurately get below 50ms resolution would be nice.

When operating at RTTs less than 25 ms, we miss a lot of detail,
presently. Flent was primarily designed to be an internet stress test,
not a local network one.

Yet, there is often much hidden detail that can be revealed by using a
smaller sample size. And if you really need more detail, take a packet
capture and tear that apart with other tools like wireshark. With the
*repeatable* aspects of the flent tests, driving a given load, packet
captures can be torn apart more sanely, and examined every-which-way.

## Videoconferencing

We don't have a good videoconferencing test yet. Videoconferencing has a
characteristic where the video frame does not fit into a single packet,
and there is a burst of packets (10 or so) every 16ms at a 60hz rate.
(Many video conferencing systems only capture 5-16 frames/sec) Thus with
the FQ we do, the first part of the new frame is moved forward in time,
relative to the tail, and this periodic "burst" is something we hope
codel will largely ignore under most loads. Our latency measurements do
not measure that.

It is not a good idea to extrapolate from our VOIP results to
videoconferencing results.

We've discussed how to go about feeding a representative videoconferencing
flow into a webrtc via various means, there's a single command line way
to do it that I need to find.

At least some videoconferencing systems have finally started to add
decent congestion control to their products - notably google congestion
control is in chrome and firefox, and jitsi has adopted it also.
Freeswitch has not, as yet.

Still, despite me begging for it - nobody's putting voice and video on
separate tuples - which would provide a useful 20ms audio clock for
congestion control of the video stream to build against in a FQ-ed
environment.

My overall suggestion at the moment is for those testing
videoconferencing to hit their link with a background flent test (rrul
in particular) and watch what happens to the videoconference.

## Flent does not actually show the TCP sawtooth directly

Most TCP theorists write papers that show the TCP sawtooth directly.
That's what you'll see in all the literature.

We don't do that directly in flent. We can't.

What we actually do is a *reflection* of that by measuring the actual
transfer rate behavior over time, not the evolution of the TCP window
itself, and the sampling period is often too high to actually see that
reflection accurately.

If you want sawtooths, take a packet capture at the same time as running
a flent test, and plot using wireshark, or tcptrace -G; xplot. There are
plenty of other tools for taking apart packet traces worth playing with.
What's most helpful about flent here, is that you can generate a
repeatable test, and get traces that you know are repeatable...

There is work going on to also
[get raw-er tcp behaviors](https://github.com/tohojo/flent/pull/91#discussion_r100667368)
directly via the "ss" utility during a flent test. It's hard - sampling
at a high rate, permutes the test.

See how smooth this plot looks? Great result, eh?

{{% figure src="fixme" %}}

But we're lying - there's a sawtooth in there but you can't see it due
to the sampling rate and short RTT.

Be aware that the very act of running tcpdump may skew your results also
by eating too much cpu. Run tests with and without tcpdump to make sure
you aren't heisenbugging yourself!

[netsniff](http://netsniff-ng.org/) is the fastest set of tools for dealing with tcpdump I know of.

## Flent understates/obscures the impact of AQM

The various tests in flent mostly use a separate measurement flow, rather
than measuring timestamps inside of each flow. So once we added [FQ](fixme)
into the overall aqm effort, the basic plot can be misleading as to whether
the aqm is actually functioning.

You can infer the AQM's behavior by the width of the sawtooths on the
up and download portions of the plot. Seeing low latency on the ping
section of the chart AND sawtooths at some multiplier of the actual path
RTT is what you want to see, but we have not got those clearly seperated
yet. It would interesting if we could correllate those two separate
concepts from the data itself.

You *can* get at additional statistics for queue depth if you enable
some tools, that can be quite helpful (particularly the tests that
measure the queue in bytes). However that requires having the
measurement tool run on the bottleneck router, and ssh access, and can
also permute the test.

{{% figure src="fixme" %}}

## No DB backend

As our number of test results has grown into the 100s of thousands,
having some form of database backend to figure out stuff, with access to
metadata, has grown more and more needed.

We currently encapsulate a lot of the variable data into filenames,
which is something that each user names differently. So we end up doing
stuff like flent-gui *ecn_yes*flent.gz to look at data over time or
other variables as a first pass. Filename length is limited, however,
and we do arbitrary transforms of the filename to make sure they are
readable on all oses.

## Corporately/Personally identifiable information

Flent by default stores very little about your network, so you can share
files with others with a bit more confidence than otherwise.

Using the -x option, it gathers a *lot* more. This includes (As of this writing):

````
FIXME
````

## Metadata creation and usage

Flent has a very useful arbitrary metadata storing and browsing/sorting
facility - it's leveraged internally by several other tests. If you get in
the habit of using it, you might save much trouble later.

````
flent --test-parameter=rtt=40ms --test-parameter=qdisd=fq_codel
--test-parameter=topology=parking_lot --test-parameter=whatever=somevalue

````

Despite trying, I've never forced enough discipline on myself to add
comprehensive metadata, generally relying on the filename.

## No web front end

There was a start at a [json based flent analytics engine](fixme) that
could show details with javascript. It was a great prototype, but it stalled
out - one on a stupid thing with font licensing, another on sort of needing
that db backend, and it needed a committed developer, also.

We *do* have a nice integrated facility for most operating systems. If
you click on a flent.gz file, we recognize the file extension and hand
it off to a local flent instance for further analysis.

## Simplistic GUI front end

Recently, a simple gui front end landed for flent. It's great.

While this is a great way to get started with flent, eliminating
scripting, and making interactive tests really easy - you can quickly run
out of ways to specify useful additional parameters, and several core
tests require those.

Flent is intensely scriptable and until this gui arrived, hard to get
started with, so I'm glad it is there, and I'm sure it will improve.

## Test Automation and standardized strings of tests

There is a very good "batch" facility in flent, but using it for the first
time is intimidating. But: you can construct a long series of tests and checks
for errors, and so on, using it.

Me, I've tend to script up something in bash, and include that test script
with the data, to see what I had under test. It would be better if I and
everyone else put more rigor into this, with a standardized set of
"batches" that captured all the statistics available. There are many
site specific variables that make that hard.

Others have wrapped flent with other wrappers, not knowing the batch
facility existed. This is a problem.

## Flent's configuration language is pure python

You can *easily* write your own tests in flent, as the configuration
language is pure python, wrapped in an eval statement. But: Evaluating
arbitrary code in something exposed to the internet is a terrible idea -
which is why flent runs as a client on top of other, hardened code.

If you write your own test... please share it with us?

## Not (quite) enough worldwide coverage for flent servers

We operate 10 [flent servers around the world](/post/worldwide_flent_servers), but they are A)
hosted primarily with one co-location facility (the very supportive
linode - I recommend them highly!) and B) you really can't trust the
numbers above 200Mbit due to other factors, as we don't regulate who is
testing when and all these servers peak at 1GBit each.

Generally our expectation was that folk will use flent in a lab, while
testing new hardware, rather than hit the worldwide servers.

We would welcome more netperf servers around the world located in
different data centers. A means to pay the DC bill we already have would
be nice.

## Underdocumented options incompletely implemented

Flent has an ability to gather many more useful stats than it does, but
it requires some setup to get it right.

```
cpu_stats_hosts
udp_bandwidth
upload_streams
download_streams
qdisc_stats_hosts
qdisc_stats_interfaces
cc
ping_hosts
tos
```

## iperf vs netperf

If there is any one thing I regret, it was using netperf instead of
iperf as the primary measurement tool. netperf is widely used within the
linux kernel community, but iperf is a primary tool elsewhere. iperf3,
in particular, supports json output AND there are version of it readily
available for both android and IoS, and I wish we had more support for
it.

BUT: I do not have the faith in iperf that I do in netperf however. Here's
[two](FIXME) very [strong](fixme) reasons to not use iperf. I finally
got fed up and started fixing iperf, but it will be years before the
fixes make it into the field.

Yet netperf is not built by default for many platforms, notably debian,
and building it yourself is a barrier to entry on code that is otherwise
currently pure python.

In either case, wrapping our analytics around a hyperfast C written test
tool is what got us to where we could drive big loads, regularly, and
reliably. Things like the web tests are basically testing browser and
server javascript performance at higher rates, not queuing delay or the
network itself. Nor are they well documented on how they work and what
they do.

## UDP floods

We recently discovered a need to try out udp floods in at least some
tests, as we ran small boxes out of cpu in a rarely hit portion of the
fq_codel algorithm... OOPs.

## Fragments are undertested

We've ignored fragments, which is probably a bad idea. iperf and netperf's
UDP flood tests DO generate fragments. Fragments *usually* behave badly
on the internet itself, but...

## Flent vs other stuff is *very useful*

I'd also always intended to use the various flent tests as a way
of generating repeatable "background" loads, against which other traffic
could be measured. It's hard to "see" what's going on in a typical
web transaction, for example. We used flent very successfully in
conjuntion with the chrome web page benchmarker, in showing how
well normal, not faked, web traffic did vs loads similar to torrenting.

Then the [chrome web page benchmarker broke](FIXME) with no replacement on the horizon.

Over time, key tests for simultanienty have moved into flent itself -
we can sample queue size, for example, and certainly having all the
variables controlled is a goodness...

... but sometimes you just want to show something like web, or quake
*just working* while the network is under load, and flent is great for that.

## Conclusion

Don't engineer to the test! DO test stuff as repeatably as possible. Run
tests for as long as possible and look for smooth behavior. Keep records
and flent data over time, over time so you can find what broke (or
regressed), when. Flent's flexible json data format *still works* even
on data we collected 4 years ago, and we intend to keep it that way.

Find more workloads you want to simulate and file bugs and submit patches to
the [github repo for flent](https://github.com/tohojo/flent)!

The network you might save is your own.

## Other resources

* Benchmarking AQM guide

* Mahimahi

* TEACUP

* ipv6 thc

* iwl

* candelatech

* NS3

* NS2
