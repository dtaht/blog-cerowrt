+++
date = "2016-03-30T18:02:58+01:00"
draft = true
tags = [ "lab", "wifi", "bufferbloat"  ]
title = "All up testing"
description = "Finding and fixing real problems, faster"
+++

I do, primarily, what's called "all up testing". It's a form of
testing, proven in the space program , that is the fastest way
to make dramatic progress... or, make dramatic explosions.

Scientists find it maddening. They want to test each variable in
isolation, figure it out thoroughly, write a paper, then move on.

The real world does not have many single variable problems. Many

Painstakingly develop a model, and then toss it away for 

The question all up testing tends to answer is - "What is the important
variable?"

Com,plexity collapse

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

But sometimes it fails. Sometimes you hit a problem so hard, that
dividing your resources across multiple domains won't get you anywhere.

You dig a very deep hole. Usuually when this happens, I end up
taking a very, very deep nap, and wake up focused with a few 
ideas as to how to dig into it further.

Out comes the notebook. Out comes the debug tools. Out comes the
single minded consistency that only the scientific method can bear
on a problem.... and you tediously go through every known and unknown
variable trying to find out what went wrong along the way.

Some of the hardest problems are ones with interrelated bugs.

and you struggle to reproduce it. And you finally do - crash the whole network
- just when your gf is trying to watch a show. "Honeeeeyyyy"? 
"The network's down"

Adding fq-codel to wifi was like that.

Out what the other guy did. 

I had a goal - no more priority 1 or 2 bugs - before we could declare
cerowrt stable. Fixing the last bug took 8 months, and a lot of hair,
and money I didn't have. 
