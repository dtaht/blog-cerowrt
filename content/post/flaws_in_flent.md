+++
date = "2016-03-30T18:02:58+01:00"
draft = true
tags = [ "bufferbloat", "rants", "flent" ]
title = "Flaws in Flent"
description = "Engineering to the test - especially your own test - can be deluding"
+++

[flent](https://flent.org) has been the test tool of choice for several
core researchers in the [bufferbloat](/tags/bufferbloat) effort.

With it - in a matter of minutes you can replicate any network test "out
there" and compare networking results results across an extraordinary
number of variables, over time, across many tests. Before Toke developed
flent, it would takes days, sometimes, to set up a single plot, now I am
deluged in data, and we can investigate network behaviors in minutes
that could take other researchers months. Accurately. With comparable
results in a standardized file format.

It leverages (primarily) other well regarded test tools to accumulate
its results, notably netperf, which is the network performance tool of
choice in the linux networking community.

Best of all, it's free (GPLv3) software, and it's easy to get up and running
on Linux and OSX. The windows version is only capable of browsing and
plotting tests, at the moment.

## Getting "standard statistics"

Now... I didn't do much programming on flent myself. It uses python, a
language I don't care for much (the GIL, and the syntax, primarily). I
wrote the stuff that needed to be hyperfast (in C), and I essentially do
QA on whatever Toke dreams up. QA is a thankless task, but the core dev
shouldn't do it - there are good reasons to have both a dev team and a
QA team (or blue vs red).

I've focused on good plotting of two or more variables against each
other as network behavior is hard to boil down to a single "number", as
much as others have tried with things such as measuring "Bandwidth" or
"jains fairness index".

Flent *can* produce standard statistics from any test, as well as
detailed output that can be used in other plotting tools.

```
flent -i datafile -o plot.csv -f plot
```

What I regard these as most useful for: is disproving to statistics minors
that guassian statistics measure anything useful when it comes to network
behavior. I care an awful lot about everything above the 95th percentile,
for example, and most stats majors just chop that off before even
starting an analysis.

In particular, I tend to use the raw (all or all_scaled) plots to
validate sane stuff happened, and the cdf plots to cover the entire
range of the data, to understand what really is going on. Then maybe a
"totals" to make it prettier.

## Box plots

Box plots, in particular, can lie. Use the raw plots *first*. Your
box plot isn't going to show variants of behavior like this
{{< >}}

We had a similar result where certain kinds of ipv6 traffic caused an
instruction trap and 2-3 second burp in the network while it recovered.
The bar plot only showed an 10% decrease in performance under ipv6...
seemingly acceptable (overhead, other reasons)...

... until we put the box on a big ipv6-enabled network where it slowed
to a crawl, perpetually handling instruction traps.

*OUTLIERS MATTER*

*ALWAYS LOOK AT THE RAWEST PLOTS FIRST*

## Flaws in the rrul test

There are so many ways to do badly on the rrul test that it's difficult
to break them all down. I designed it to break the most stuff the fastest,
and while I can point to a "good result" pretty easily -

{{< figure src="/flent/good_results/example.svg" >}}

Explaining everything that can go wrong would take pages and pages -
which I intend to do someday in the hope that more folk learn to read
a rrul plot and what it means.

Relying on any one test overmuch is a tad foolish. The rrul test was
designed to break everything I knew to be broken in under 60 seconds.

What I had always intended was the "fail the rrul" phase to be followed
by individual measurements of the simpler tests, like single tcp up and
downloads, followed by multiple tcps, etc.

## RTT measurements rather than one way delay

There is a pretty basic flaw in nearly all of flent in that it uses RTT based
measurements and what's really needed is measurements of one way delay
on isochronous intervals (say, 10 or 20ms), and/or measurements within
each flow to truly "get" whats going on.

The problem with the latter problem is no tool does it, and at the
higher rates (like 10Gbit) actually doing timestamps well is problematic.

The former problem is that few good tools for creating isochronous
traffic exist. Flent has a test built around the d-itg voip simulation
tool, but d-itg is not exactly "safe" to run on the open internet, and
I'd like something with hard realtime privs that used fdtimers to get
accurate resolutions below 10ms.

owamp has much promise but I still don't trust its measurements lacking
both realtime privs and fdtimer support, also.

Avery's "isochronous" tool is of some use, but again, unsafe to deploy
on the wider internet without some sort of 3-way handshake to kick it off.

Quic has always been on my mind.

## Flent works best at speeds greater than 4Mbit

A huge flaw in most network research today is that researchers tend
to focus on achievable speeds in the lab, and are perpetually posting
results in the 1mbit to 10mbit range. Flent lets you test at speeds
up to 40Gbit. Most of our testing has been in the range 4-200Mbit.

TCP's behaviors at lower rates are bound by different variables than
TCP's behaviors at higher rates. Of issue are the size of the initial
window, loss rates, and ssthresh, and the actual tcp used.

Our focus with flent has been measuring actually achieved rates in the
field, which for ISPs ranges from 384k up to a gigabit - measuring
queue depth, cpu overhead, etc. Some binding variables there include
the size of the initial window also, but pacing, recv and send buffering,
and so on start factoring into play more. At higher speeds, loss rates drop
dramatically, in particular.

One of the hardest problems to measure is what happens at a range of
achievable rates from 1Mbit to 1Gbit in the same session, as in
[wifi](/tags/wifi), or in [route flaps](/fixme)

Nobody has a good emulation for wifi's behaviors today. It seemed
simpler to just go forth and implement the new queueing ideas we have,
in Linux directly, and go measure that, and wash, rinse, repeat.

That took two years.

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
not I'm fooling myself. Also, on the server side, to detect when
ack decimation seemed to be taking place

## Resolution issues

Once measurements start getting down below 5ms, all sorts of measurement
noise enter the tests -

* ICMP pings - which are responded to by the kernel - start responding faster
  than UDP based pings - which have to context switch into user space. Sometimes.
  Some kernels deprioritize ping!

* RTT based measurements start becoming significant - dropping a
  queue from 10ms to 1ms increases the measurement traffic by a factor
  of 5. So you might "see" a latency improvement and a corresponding
  decline in bandwidth that is not, actually true. The fix is to run a
  test without the measurements.

Try to take any observed difference in performance under 5ms cautiously.

## Sample size is large

The default --step-size is 200ms in width - this is both to reduce the
heisenbugs introduced by the measurement portions of the text and to lower
the overhead of sampling in the first place.

When trying to operate at resolutions lower than 50ms, other tools,
like fping, start getting behind - finding a ping tool that could
accurately get below 50ms resolution would be nice.

Yet, there is often much hidden detail that can be revealed by using a smaller
sample size. And if you really need more detail, take a packet capture and
tear that apart with other tools. With the *repeatable* aspects of the flent
tests, driving a given load, packet captures can be torn apart more sanely.

## Videoconferencing

We don't have a good videoconferencing test. Videoconferencing has a
characteristic where the video frame does not fit into a single packet,
and there is a burst of packets (10 or so) every 16ms at a 60hz rate.
(Many video conferencing systems only capture 5-16 frames/sec) Thus with
the FQ we do, the first part of the new frame is moved forward in time,
relative to the tail, and this periodic "burst" is something we hope
codel will largely ignore under most loads. Our latency measurements do
not measure that.

We've discussed how to go about feeding a representative videoconferencing
flow into a webrtc via various means, there's a single command line way
to do it that I need to find.

## Understating the impact of AQM

The various tests in flent mostly use a separate measurement flow, rather
than measuring timestamps inside of each flow. So once we added fq
into the overall aqm effort, the basic plot can be misleading as to whether
the aqm is actually functioning.

You can infer the AQM's behavior by the width of the sawtooths on the
up and download portions of the plot. Seeing low latency on the ping
section of the chart AND sawtooths at some multiplier of the actual path
RTT is what you want to see, but we have not got those clearly seperated
yet. It would interesting if we could correllate those two separate
concepts from the data itself.

## No DB backend

As the number of tests has grown into the 100s of thousands, having some
form of database backend to figure out stuff, with access to metadata,
has grown more and more needed.

We encapsulate a lot of the variable data into filenames, which is
something that each user names differently. So we end up doing stuff
like flent-gui *ecn_yes*.gz to look at data over time or other variables
as a first pass.

## No web front end

There was a start at a [json based flent analytics engine](fixme) that
could show details with javascript. It was a great prototype, but it stalled
out - one on a stupid thing with font licensing, another on sort of needing
that db backend, and it needed a committed developer, also.

## Test Automation and standardized strings of tests

There is a very good "batch" facility in flent, but using it for the first
time is intimidating. But: you can construct a long series of tests and checks
for errors, and so on, using it.

Me, I tend to script up something in bash, and include that test script
with the data, to see what I had under test. It would be better if I and
everyone else put more rigor into this, with a standardized set of
"batches" that captured all the statistics available. There are so many
site specific variables that make that hard.

## Not (quite) enough worldwide coverage

We operate 10 [flent servers around the world](fixme), but they are A)
hosted primarily with one co-location facility (linode) and B) you
really can't trust the numbers above 200Mbit due to other factors

Generally the expectation is that folk will use flent in a lab, while
testing new hardware, rather than hit the worldwide servers.

## Underdocumented options incompletely implemented

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
available for both android and IoS, and I wish we had oore support for
it.

I do not have the faith in iperf that I do in netperf however. Yet netperf
is not built by default for many platforms, and building it yourself is
a barrier to entry on code that is otherwise currently pure python.

In either case, wrapping the analytics around a hyperfast C written test
tool is what got us to where we could drive big loads, regularly, and
reliably. Things like the web tests are basically testing browser and
server javascript performance at higher rates, not queuing delay.

## UDP floods

We recently discovered a need to try out udp floods in at least some
tests, as we ran small boxes out of cpu in a rarely hit portion of the
fq_codel algorithm..

## Fragments

We've ignored fragments, which is probably a bad idea. iperf and netperf's
UDP flood tests DO generate fragments.

## Flent vs other stuff is *very useful*

I'd also always intended to use the various flent tests as a way
of generating repeatable "background" loads, against which other traffic
could be measured. It's hard to "see" what's going on in a typical
web transaction, for example. We used flent very successfully in
conjuntion with the chrome web page benchmarker, in showing how
well normal, not faked, web traffic did vs loads similar to torrenting.

Over time, key tests for simultanienty have moved into flent itself -
we can sample queue size, for example, and certainly having all the
variables controlled is a goodness...

... but sometimes you just want to show something like web, or quake
*just working* while the network is under load, and flent is great for that.

## Conclusion

Don't engineer to the test! DO test stuff as repeatably as possible.
Find workloads you want to simulate and file bugs and submit patches to
the [github repo for flent](https://github.com/tohojo/flent)! The
network you might save is your own.
