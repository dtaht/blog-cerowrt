+++
date = "2016-03-25T18:02:58+01:00"
draft = true
tags = [ "bufferbloat" ]
title = "Save the Sawtooth!"
description = ""
+++

The sawtooth is part of TCP 101.

The conceptual leap - that having all these sawtooths wiggling and
jigging around - is going from the textbook descriptions of why
it exists - to how thousands of flows on a network all co-operate.

this is why in flent we always show all that noise, first, up front,
to try and lend intuition that it is multiple flows, all co-existing,
on something like a sawtooth that makes the internet work at all.

You can't - by design - grab all the bandwidth with a single tcp flow...

... unless you add so much buffering - 2x as much buffering - as needed
to completely disable this portion of congestion control. And congestion
control is why the internet works, at all, and it is why a group of
people in the bufferbloat effort were so panicked at seeing this basic
assumption violated on every technology we had, back in 2011.

Which is basically what vendor after vendor did.

What happened on a small scale on the original internet was happening
on a regular basis all along the edge of the internet, on wifi, and
elsewhere.

# Reno

# Cubic

# others

## Eliminating the sawtooth
tcp-hybla, tcp-cdg

dctcp
