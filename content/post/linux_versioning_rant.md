+++
date = "2016-05-01T12:02:58+01:00"
draft = false
tags = [ "wifi", "bufferbloat" ]
title = "Network Academia: Please document your patches and kernel versions in your papers"
description = "As, unlike the physical world, networking has few real constants, and lots of bugs."
+++

This is taken, almost verbatim, from a rant of mine in 2013
[on linux versioning](https://lists.bufferbloat.net/pipermail/bloat/2013-November/001735.html) .

I will work on it at some point to reduce the "rantyness" of it...

But: honestly, if every academic paper on networking published the exact
linux kernel, and a git tree to it, it would be a better world. I think
this rant had useful effects when I first wrote it, but I just read
(may, 2015) - (and
rejected - and you know who you are) a bunch of papers this week that
did not document their work thoroughly enough.

...

I am in the process of trying to reproduce the recent rite papers on
immediate congestion notification and the iccrg ARED work and need
to explain something to researchers so that I don't have to work so hard.

Linux kernel releases are numbered X.Y.Z-Q. All kernel versions
contain bugs. Linux 3.2.0 was, IMHO, the nadir of the network stack in
Linux.

The "X" is the major version number. It's only changed 4 times. "Y",
is the minor version number. These come out roughly quarterly and
consist of new development of "features". The "Z" is critical patches
backported from newer releases. -Q is usually the vendor's kernel
build number which often contains many more patches.

These numbers, clearly identified, in every academic paper on
networking, and every presentation, ever published,  would make me a
happier guy. A pointer to the git tree actually used would make me
even happier, with all the patches (like DCTCP in this case) applied,
would cause me to dance for joy, and sing hallelujah!

Anyway, on the "Z" part of X.Y.Z:

Periodically a
[long term stable linux kernel release](https://www.kernel.org/category/releases.html)
is picked and receives updates for as long as someone is funded to do
it.

*the only things that enters into a long term stable release* are fixes
for security bugs, crash bugs, and truly egregious bugs that can be
somewhat easily fixed. "Features", don't.

The rest of the development goes into X.Y+1.

(Sane people never run a X.Y.0 release on hardware/data they care about.)

So... anyway... when I was told that the recent paper on DCTCP had
been done against Linux 3.2.18, "which came out in july, 2013!" ...

I was partially happy - pretty stable release - but my heart sank as I
knew that very, very, very few of the relevant fixes for bufferbloat and
the tcp stack had landed in anything prior to Linux 3.6. Those fixes had
mostly qualified as "features". Several in fact have been in such
continuous development that I'd not want to generalize from fq_codel in
3.5 vs what's in 3.8 now, as one example.

So it's my hope that folk will try to follow more closely the X.Y series
of kernels rather than the 3.2.Z series of kernels in the future. I'm
very happy with what happened in the 3.12 series in particular and
look forward to work against it in the near future. The 3.13 work is
just beginning, too.

In the hope that the showing the mechanics of researching what fixes
did land in an old stable release would help on future papers,
here's how to look:

```
git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
git clone linux-stable linux-3.2.18
cd linux-3.2.18
git checkout v3.2.18
git checkout -b ritepaper
git log net include/net # just the networking bits, not the driver
bits for this example
```

And: BQL, enhanced SFQ, SFQRED, codel, fq_codel, tcp small queues,
retirement of some odd tcp logic, and hundreds of other changes were
made to the the stack since 3.2.0, and were NOT backported to 3.2.Z.

And: some very relevant bugfixes did indeed land in 3.2.18 that were not in 3.2!

If you have an experiment that used TCP that is against an even older
release, perhaps some of these major bugs might explain your results.
Here's a sampling:

```
commit 4b9b05fd95c502521eaef111ba0f83c58b391587
Author: Eric Dumazet <edumazet at google.com>
Date:   Wed May 2 02:28:41 2012 +0000

    tcp: change tcp_adv_win_scale and tcp_rmem[2]

<snip snip>

    This also means tcp advertises a too optimistic window for a given
    allocated rcvspace : When receiving frames, sk_rmem_alloc can hit
    sk_rcvbuf limit and we call tcp_prune_queue()/tcp_collapse() too often,
    especially when application is slow to drain its receive queue or in
    case of losses (netperf is fast, scp is slow). This is a major latency
    source.

commit b713f6c7d317c136f03c132203d0900f4a0de084
Author: Yuchung Cheng <ycheng AT google.com>
Date:   Mon Apr 30 06:00:18 2012 +0000

    tcp: fix infinite cwnd in tcp_complete_cwr()

    [ Upstream commit 1cebce36d660c83bd1353e41f3e66abd4686f215 ]

    When the cwnd reduction is done, ssthresh may be infinite
    if TCP enters CWR via ECN or F-RTO. If cwnd is not undone, i.e.,
    undo_marker is set, tcp_complete_cwr() falsely set cwnd to the
    infinite ssthresh value. The correct operation is to keep cwnd
    intact because it has been updated in ECN or F-RTO.

commit 65355aea86b2a70cbc7cbe14466702bc5a4e2217
Author: Neal Cardwell <ncardwell at google.com>
Date:   Tue Apr 10 07:59:20 2012 +0000

    tcp: fix tcp_rcv_rtt_update() use of an unscaled RTT sample

    [ Upstream commit 18a223e0b9ec8979320ba364b47c9772391d6d05 ]

    Fix a code path in tcp_rcv_rtt_update() that was comparing scaled and
    unscaled RTT samples.

    The intent in the code was to only use the 'm' measurement if it was a
    new minimum.  However, since 'm' had not yet been shifted left 3 bits
    but 'new_sample' had, this comparison would nearly always succeed,
    leading us to erroneously set our receive-side RTT estimate to the 'm'
    sample when that sample could be nearly 8x too high to use.

    The overall effect is to often cause the receive-side RTT estimate to
    be significantly too large (up to 40% too large for brief periods in
    my tests).


commit 1ee5fa1e9970a16036e37c7b9d5ce81c778252fc

    [PATCH] sch_red: fix red_change()

    Now RED is classful, we must check q->qdisc->q.qlen, and if queue is empt
    we start an idle period, not end it.

```
