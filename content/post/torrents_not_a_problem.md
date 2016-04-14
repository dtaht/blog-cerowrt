+++
date = "2016-03-25T18:02:58+01:00"
draft = true
tags = [ "bufferbloat", "bittorrent" ]
title = "Torrents are not a problem with fq_codel"
description = ""
+++

I wrote this whole thing already...

This is a real world example of a major torrent download/upload happening
(ubuntu.iso) while attempting to stress out the link

{{< figure src="/flent/major_torrent" >}}

There are 64 torrent flows competing here against 4 download and 4 upload
flows, and the total bandwidth achieved is 50Mbits for the "normal" flows,
and 25Mbit for the other 64. Why is that? With a FQ'd system you'd expect
something like 4Mbits...

Bittorrent has 4 phases

	searching the DHT for (seeding)
	initial download
	download + upload (participating in the swarm)
	upload only (seeding)

One of the many mis-understood things about torrents are that while they
were a big problem when the protocol first came out, much work took
place to make it kinder and gentler. All torrent clients have the ability
to artificially rate limit the upload (usually on a diurnal basis).

Another key misunderstanding is that by default, a typical download or upload
only lasts for 15 seconds, there are only 5 active streams, and every few seconds it switches to another flow

Another - ledbat - still - does not work

Ledbat. Ledbat != uTP. Very few benchmark tools exist for uTP but

	"Reno" congestion control
	the IW is 1, not 10

Even if it has low queuing delay it can't ramp up as fast. When it finally
hits a drop, it backs off harder. Web traffic, in particular, cuts through
torrent traffic like butter - a

	There ARE things that can be done to make torrent even less of a
	problem. The default prioritization scheme of the sqm-scripts will
	toss all traffic marked CS1 (background) into it's own bucket, and
	most torrent clients have an underdocumented option to enable that.
	It's broken on current transmission (sigh), so that it does not
	appy to uTP, and I've been meaning to submit a patch upstream for
	that for ages.

	with *that* in place - extensive upload torrenting is invisible to
	any other traffic in the household. There's been talk of adding
	a new diffserv marking - less than best effort - for years now,
	and I'd love to see that used.

It isn't every lifetime that you obsolete decades of research into LPCC,
and I spent the first year of the bufferbloat effort consulting everyone
involved to see if

So in the end, my conclusion was that torrent worked better...

and HAS traffic was worse.

It is totally feasible to achieve "less priority", still, even in a FQ'd
system. And uTP does that already. Solved problem. I moved on.
