+++
date = "2016-03-30T18:02:58+01:00"
draft = true
tags = [ "lab", "wifi", "bufferbloat"  ]
title = "All up testing"
description = "Finding and fixing real problems, faster"
+++

I do, primarily, what's called "all up testing". It's a form of
testing, [proven in the space program](), that is the fastest way
to make dramatic progress... or, make dramatic explosions.

All up testing is the fastest way to find "the true variable" - what
Donald Rumsfeld called the [unknown unknown](). I've spent most of my
life in the pre-scientific process, chasing intuition, in search
of isolating and fixing the unknown unknowns - doing endless experimentation,
tweaking as many variables as possible, trying to find a lever to move
the world, writing down random results of random tests, in the hope that
one day a repeatable pattern may emerge, and an unknown unknown, move,
at least, to being a known unknown, or a known. 

True scientists (I can't count myself as one!) find my approach maddening. They want to test each variable in
isolation, figure it out thoroughly, write a paper, then move on. Hell, my
approach makes *me* crazy - I'll find a bunch of problems that interact somehow
and then grope for months to isolate the real variable(s), by backing
off each major change one by one to see what was really broke. Or,
if I'm lucky - by describing what I encounterd so well that someone 
with more of a clue can have their "Aha!" moment.

The real world does not have many single variable problems. Nearly all those
have been isolated and examined. All that's left is the interaction between
multiple variables.

I (with a lot of help), pounded through 50 years of network queue theory to
ultimately help come up with what became fq_codel. I'd started off with a vague
generalization - "Why didn't wondershaper scale up?" 

It turned out there were multiple variables in play, all of which inobvious.

* BQL 
* Codel
* FQ

Painstakingly develop a model, and then toss it away for 

The question all up testing tends to answer is - "What is the important
variable?"

Complexity collapse

* Incentivises 
* 

All 

Ahmdals law. 

ripples spread out.

Building embedded firmware is kind of like that. You build (what used to be
called) a single system image, you run without an mmu,and a single bug,
anywhere in the system, can crash the whole thing.

*you have* to test like that. 

and light the candle.

We found and fixed 280 bugs that way.

test in isolation, will they work? 

You assemble all your pieces on stage 1,2,3 on the rocket - and if your
project is the payload, you pray that those responsible for the bits 
you depend on did the same level or better testing you did, 'cause otherwise
you are going to have a bad day.

Bad days happens.

# Embracing randomness

The big developments in the bufferbloat effort tended towards random

# The big picture

Jim Gettys, Andrew McGregor and I spent an eternity developing a document
that addressed everything we knew was wrong with wifi, and published it.

While we'd hoped 

Jim's kickoff of the bufferbloat effort was a 

# The role of the scientific method

So, along the way 

But sometimes it fails. Sometimes you hit a problem so hard, that
dividing your resources across multiple domains won't get you anywhere.

You dig a very deep hole. Usuually when this happens, I end up
taking a very, very deep nap, and wake up focused with a few 
ideas as to how to dig into it further.

Out comes the notebook. Out come the debug tools. Out comes the
single minded consistency that only the scientific method can bear
on a problem.... and you tediously go through every known and unknown
variable trying to find out what went wrong along the way.

Some of the hardest problems are ones with interrelated bugs.

and you struggle to reproduce it. And you finally do - crash the whole network - just when your gf is trying to watch a show. "Honeeeeyyyy"? 
"The network's down"

Adding fq-codel to wifi has been like that. There are so many variables
in the experiment that it's hard to hold them all in your head.

# On the CeroWrt project

What were the unknown unknowns

Out what the other guy did. 

I had a goal - no more priority 1 or 2 bugs - before we could declare
cerowrt stable. Fixing the last bug took 8 months, and a lot of hair,
and money I didn't have. 

All up testing.

Well, bugs.

But, what's this? only 50Mbit's up for the competing flow, leaving
approximately 85% of the capacity unused in that direction.

Divide by two and start again.

Is it the new algorithms? No, cake is outpeforming fq_codel here.

Is it CPU? Well, we peak at about 30% of cpu on a quad core system. That's
a throughput measure - context switches are the bigger problem on interrupt
handling and few focus on that. One of the reasons why arm (was) a bigger
success on devices is that older versions had a short pipeline and could
context switch much faster than intel could. 

Is it the device driver? Are we out of some critical resource?

Is it a bug elsewhere?

have a single thread rx/tx cleanup ring. This causes all sorts of oddities,
- it made sense when we were using single cores btw - but it would be generally
better to clean up tx and rx separately now that multi-cores are more common.

That said, more than one manufacturer only uses one interrupt for tx/rx so
you can't do that either.

Cake and netem only have a single soft irq for scheduling it.

It's one thing to have something that performs better, another thing however if it
uses up too much cpu to actually deploy. 


One of my hopes, though, is to encourage more people to internalize the
advantages of all-up testing, develop methods to make it so, 

The downside?

One person, wandering around creatively, blowing up networks, can create
a lot of work, [for a lot of people](), that does need to be thoroughly
explored. 

And this one person, is tempermentally ill suited for that - having cut
such a swath through most of the big problems, I'm still wandering around
looking for more, trying to line up resources to fix them, and not having
a good time anymore.

Every project needs multiple kinds of people on it, and they mostly all have
to appreciate each other's value.

But I do wish we had more people, applying their skills, and adopting some
of mine, to finish up the work.

consists of nagging, of showing by example, by creating competition,
an existence proof.

# speed

I went on gut feel, a lab notebook, and the bare minimum turnaround time
between and idea and implementation. I cut corners, in other words. If
I'd written a paper for every insight we'd still be where we started

Things I regret are that I've not actually written a lot of code, of late,
that my own contribution cost me more money than I made, and that 

sometimes you have to do the slow slog 

And I team up with people that can compensate 

Sometimes though, I get so scattered across the surface of things that
I need to take weeks (or months), to look across my notes, and try to
identify if any of the odd patterns added up. I've had to put in my schedule - "Reset my schedule".

It's the difference between applying the OODA loop and engaging in a full
frontal assault. I recognise that both methods apply but have specialized
in the first, in seeing the latter in more supply.

out in front, trailblazing, while letting others fill in the blanks.

buckling down for the long haul, pursuing standardization, finding other

For example, I'm blogging here, rather than writing papers, in part to
*avoid peer review* because there are too few peers to review and it's
a 9 month cycle between papers, where 

exploration of all the alternatives, led to a blinding flash of insight
on Eric Dumazet's part that a modification to DRR would solve most of the
problems we'd hit by using per packet fairness schemes such as SFQ.

everyone else - including me! - was so blindsided by this that it took 
months to internalize, and begin to isolate what new problems were exposed
by this approach. Finding a means to drop packets from flooding took
2 years longer.  

"Cake" has been a patient exploration of - for benefits that are nearly
immesurable.

By such means, progress is made.

# Summary

Have a big picture
Get eyeballs
Test and increment
Communicate
You don't have all the answers

But without that initial seed crystal, nothing would have happened.

Universal Systems Language - Lessons from apollo

Fixme: I have no idea why these are in here

http://blog.interviewing.io/we-built-voice-modulation-to-mask-gender-in-technical-interviews-heres-what-happened/

http://lens.blogs.nytimes.com/2009/06/03/behind-the-scenes-tank-man-of-tiananmen/?_r=0

https://www.sovereignman.com/lifestyle-design/uncle-sam-admits-monitoring-you-for-these-377-words-6832/

post singularity arrives ahead of schedule

by the time you read this it will be too late.

what if aggregation increased with distance? Actual distance in ms.

http://images.google.de/imgres?imgurl=https://upload.wikimedia.org/wikipedia/commons/2/2e/Margaret_Hamilton.gif&imgrefurl=https://en.wikipedia.org/wiki/Margaret_Hamilton_(scientist)&h=719&w=566&tbnid=T5zwwY7Y7ijerM:&tbnh=186&tbnw=146&docid=QvlAI254ghjvuM&itg=1&usg=__YQUnKH6s40iFXnYKlDQdpbSSqvI=
