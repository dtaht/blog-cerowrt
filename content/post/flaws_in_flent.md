+++
date = "2016-03-30T18:02:58+01:00"
draft = true
tags = [ "bufferbloat", "rants", "flent" ]
title = "Flaws in Flent"
description = "Engineering to the test - especially your own test - can be deluding"
+++

[flent](https://flent.org) has been the test tool of choice for the
core researchers in the [bufferbloat](/tags/bufferbloat) effort.

With it - in a matter of minutes you can replicate any network test "out there"
and compare results across an unblievable number of variables. Before Toke developed flent, it would takes days, sometimes, to set up a single plot,
now I am deluged in data, and we can investigate network behaviors in minutes
that take other researchers months. Accurately. With comparable results
in a standardized file format.

## Getting "standard statistics"

In helping develop flent, I've focused on good plotting of two or more
variables against each other as network behavior is hard to boil down
to a single "number", as much as others have tried with things such as
measuring "Bandwidth" or "jains fairness index".

Flent *can* produce standard statistics from any test, as well as detailed output that can be used in other plotting tools.

```
flent -i datafile -o plot.csv -f plot
```

What I regard these as most useful for is disproving to statistics minors
that guassian statistics measures anything useful when it comes to network
behavior.I care an awful lot about everything above the 95th percentile,
for example, and most stats majors just chop that off before even
starting an analysis.

In particular, I tend to use the raw (all or all_scaled) plots to validate sane stuff happened, and the cdf plots to cover the entire range of the data, to understand what really is going on. Then maybe a "totals" to make it prettier.

## Box plots

Box plots, in particular, can lie. Use the raw plots *first*.

## Flaws in the rrul test

There are so many ways to do badly on the rrul test that it's difficult
to break them all down. I designed it to break the most stuff the fastest,
and while I can point to a "good result" pretty easily -

{{< figure src="/flent/good_results/example.svg" >}}

explaining everything that can go wrong would take pages and pages -
which I intend to do someday in the hope that more folk learn to read
a rrul plot and what it means.

What I had always intended was the "fail the rrul" phase to be followed
by individual measurements of the simpler tests, like single tcp up and
downloads, followed by multiple tcps, etc.

There is a pretty basic flaw in all of flent in that it uses RTT based 
measurements and what's really needed is measurements of one way delay
on isochronous intervals (say, 10 or 20ms), and/or measurements within
each flow to truly "get" whats going on.

The problem with the latter problem is no tool does it, and at the
higher rates (like 10Gbit) actually doing timestamps well is problematic.

The former problem is that few good tools for creating isochronous traffic exist.
d-itg is not exactly "safe" to run on the open internet, and I'd
like something with hard realtime privs that used fdtimers to get
accurate resolutions below 10ms.

owamp has much promise but I still don't trust it's measurements lacking
both realtime privs and fdtimer support, also.

## Flent doesn't count tcp acks as part of the overall traffic measurement

Flent does not account for tcp ACK traffic as part of the overall
bandwidth tracked. If you observe a small decline in bandwidth at a 
reduction in RTT from 100 ms to 10ms, at least part of that is due to
the increased ack traffic. I've longed to have an "ack estimator" available
(basically adding in 1/40th the size of the sent flows on recieve on ipv4),
just to have an estimate of whether or not I'm fooling myself.

Flent does not also fully account for the size of the measurement flows.

## Resolution

Once measurements start getting down below 5ms, all sorts of measurement
noise enter the tests - 

* ICMP ping's - which are responded to by the kernel - start responding faster
  than UDP bsed pings - which have to context switch into user space.
* RTT based measurements start becoming significant - dropping a 
  queue from 10ms to 1ms increases the measurement traffic by a factor of 5.

Try not to take any observed difference in performance under 5ms seriously.

## Sample size

The default --step-size is 200ms in width - this is both to reduce the
heisenbugs introduced by the measurement portions of the text and to

When trying to operate at resolutions lower than 50ms, other tools,
like fping, start getting behind - finding a ping tool that could
accurately get below 50ms resolution would be nice. 

## Videoconferencing

We don't have a good videoconferencing test. Videoconferencing has a characteristic where the video frame does not fit into a single packet. Thus with the
FQ we do, the first part of the new frame is moved forward in time, relative
to the tail. Our latency measurements do not measure that.

We've discussed how to go about feeding a representative videoconferencing
flow into a webrtc via various means, there's a single command line way 
to do it that I need to find.

## Understating the impact of AQM

The various tests in flent mostly use a separate measurement flow, rather
than measuring timestamps inside of each flow. So once we added fq
into the over aqm effort, the basic plot can be misleading as to whether
the aqm is actually functioning. 

You can infer the AQM's behavior by the width of the sawtooths on the
up and download portions of the plot. Seeing low latency on the ping
section of the chart AND sawtooths some multiplier of the actual path
RTT is what you want to see, but we have not got those clearly seperated
yet. It would interesting if we could correllate those two separate
concepts from the data itself.

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

if there is any one thing I regret sometimes, it was using netperf instead of iperf
as the primary measurement tool. netperf is widely used within the linux
kernel community, but iperf is the primary tool elsewhere. iperf3,
in particular, supports json output AND there are version of it 
readily availble for both android and IoS, and I wish we had oore
support for it.

I do not have the faith in iperf that I do in netperf however.

## UDP floods

We recently discovered a need to try out udp floods in at least some 
tests, as we ran small boxes out of cpu in a rarely hit portion of the
fq_codel algorithm..

## Flent vs other stuff is *very useful*

I'd also always intended to use the various flent tests as a way
of generating repeatable "background" loads, against which other traffic
could be measured. It's hard to "see" what's going on in a typical
web transaction, for example. We used flent very successfully in
conjuntion with the chrome web page benchmarker, in showig how
well normal, not faked, web traffic did vs loads similar to torrenting.

Over time, key tests for simultanienty have moved into flent itself -
we can sample queue size, for example, and certainly having all the
variables controlled is a goodness...

... but sometimes you just want to show something like web, or quake
*just working* while the network is under load, and flent is great for that. 
