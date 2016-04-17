+++
date = "2016-04-16T18:02:58+01:00"
draft = false
tags = [ "bufferbloat" ]
title = "Cake verses everything"
description = "Comparing theoretical results with reality for fq-codel, the next generation"
+++

I just restarted long-rtt testing on
[cake](http://www.bufferbloat.net/projects/codel/wiki/CakeTechnical)
after aborting the last series of tests in mid-December late last year, as the codel implementation was broken. It's hard to believe it's already April - Moving myself and the lab back from Sweden took some time, there were other difficulties and [distractions](/tags/wifi), and I only just now have enough of the right (new) pieces assembled to give the [latest code for cake](https://github.com/dtaht/sch_cake) a try.

Here's the [flent](https://flent.org) [test results for cake_vs_everything](/flent/cake_vs_everything). It's simpler to just [git clone the repository](https://github.com/dtaht/blog-cerowrt) and browse the results.

Since the last major set of completed test runs, Linux has gone through
a few revisions, notably adding the much heralded "sch_fq" tcp scheduler,
which does packet pacing. In my new lab, I also switched from doing delay in userspace, to doing delay via the "netem" command, as it seems - if used properly -
netem can be trusted now, when used in conjunction with the sqm-scripts. Maybe - see last plot below...

## Emulating Reality

I chose 3 RTTs for this test series - reflecting the actual RTTs I get to
three of my servers in the cloud - 12ms, 48ms, and 84ms - corresponding to Redwood City, Dallas, and Newark, across the USA. Bandwidth is 110Mbit down, 10 up, since that's what I get from my cable box here.

For variety I also added in an OSX box for some of the RTT fairness tests.  (I have a bunch of other hackerboards I intend to add to things at some point)

Topology: test driver(dancer) <-> router(prancer) <-> {OSX lion, Linux 4.4 (vixen)}

## Quick notes

Probably my favorite plot so far was the one that shows the effect of
[flow queuing](https://tools.ietf.org/html/draft-ietf-aqm-fq-codel-06)-
SUB-ZERO induced delay:

{{< figure src="/flent/cake_vs_everything/subzero.svg" >}}

The latency for sparse flows actually *goes down* from idle to busy!

We didn't actually crack lightspeed here, this is in part - is an
artifact of linux defering "ping" until the device is more busy.

BUT: I think a lot of people have been misled by [reading older rrul
graphs at slower bandwidths or non-ethernet technology](http://burntchrome.blogspot.com/2014/08/new-comcast-speeds-new-cerowrt-sqm.html) - many of the first fq_codel rrul tests
published had 5mbit up bandwidths, this could incur delay of 5-10ms or
more on the "sparse" flows in that test. In the fq-codel derived algorithms, there is actually *no* delay incurred for flows that are sparse enough to "jump
the queue" - only queue building flows are ever delayed in fq_codel.

Cake builds on this further by having an 8 way set associative hash and
managing its static queue better. Someday I'll write down the equation for this behavior, it looks really lovely at higher bandwidths with only a few
greedy flows....

I also note, that in all my tests thus far, the mac somehow tends to
have a slightly more greedy tcp.

This plot:

{{< figure src="/flent/cake_vs_everything/winningbyahair.svg" >}}

shows cake winning over sqm-scripts. We had to manually put a fudge factor
into htb + fq_codel to give enough of a buffer to avoid running out of cpu,
cake figures out if enough is availble automatically, and the shaper
saves a packet - I am certain there are rich people out there that care
about saving a few dozen usecs - I'm not one of them.

And it seems like regular codel still outperforms cake's codel in some
circumstances:

{{< figure src="/flent/cake_vs_everything/cake_codel_stillbusted.svg" >}}

BUT THIS plot:

{{< figure src="/flent/cake_vs_everything/andthentherearethewtfs.svg" >}}

Is a complete - WTF? It compares the two (pie and codel) single queue
AQMs against each other... with radically different (and wrong!)
behavior between the OSX box and linux box. Pie gyrates all over the
place, codel hits a fixed high and stays there.

Ah... science. Given how weird the single queue aqm results were
overall, I guess I'll have to investigate that before moving onto

## Testing Reality

There are a couple other errors in this test series - I did not successfully get
queue depth and drops every time, in particular - and I am going to add
in a few more tests that more or less match what is in the bufferbloat
trial, *and* add in the CMTS + cablemodem emulations.

After that, I plan to repeat all these tests against
the real world. Unless we find a new bug in cake.

Please feel free to pull apart this data and note any
interesting flaws/artifacts/comparisons! The battle to beat bufferbloat
is back on!
