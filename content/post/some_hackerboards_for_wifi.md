+++
date = "2016-03-28T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat" ]
title = "Some hackerboards for wifi"
description = "USB sticks generally suck"
+++

I wanted a set of wifi devices to drive various loads on the wifi
testbed I am setting up. What I used to use was old laptops or spare
routers I had lying around, but given that I have severe power and space
constraints it seemed logical to investigate using the latest generation
of hackerboards - small arm based boxes like the rasberry pi - to see if
they were up to the job. So I burned a couple hundred dollars on the
latest batch.

I'd like to be testing the latest outputs of the homenet working group,
babeld - basically functionality that the cerowrt project enabled that
also required some host support.

A secondary goal is to get on top of the latest generation of hardware
and make sure our requirements - debloating, wifi, kernel support for
IPV6_SUBTREES, and other features are all in there - and "just work" by
default.

I could really use a "helper" for this sort of stuff, bringing up new
gear is a matter of reading a lot of web pages and fiddling, and I'm at
the stage in life where I'd like stuff to "just work", but oh, well.


## Beaglebone black

I was an early adopter of the beaglebone black. I chose it (over the
raspberry pi) as it seemed, well, heftier, better designed, without
parts that stuck out and broke, and capable of handling

I did the port of BQL to it, and it behaved really well. However I was
perpetually rebooting them

Kernel development on that platform has continued

This time, I thought I'd try minix, I flashed a card, it failed to boot,
and I moved onto other problems.

## Raspberry Pis

## Odroid C1, C2

Given that the C2 can - barely - drive a

## Banana Pi

Haven't booted this up yet

## Galieo gen2

I don't know what Intel is thinking. Not only does their hackerboard
cost twice as much as everything else, there is nearly no aftermarket
established - you can't easily get a case, for example, the software
infrastructure is built around yocto which nobody seems to use, and

About the only major advantage to the architecture is that there is a
mini-pcie card, which happens to be something I need.

## Thoughts

Looking at the plethora of power supplies on a power strip, I can't help
but want some sort of USB based power strip with remote power control to
control them. Kind of like a digiloggers. I'd save 6 bucks on power
supplies AND get something I could control remotely to reboot stuff
with.

## The wifi problem

The next generation of nearly everything will have integrated wifi on
board, and the wifi stick market will slowly start to die. I *fear* that
that integrated wifi will suck, will have proprietary components (much
like how cell's baseband processors have evolved) and be unfixable. Thus
getting in "early" seems like a good idea.

Thx to the wonders of amazon it's actually possible to go shopping for
wifi sticks that explicitly say they support Linux, which is a
timesaver.


|STICK|C1|C2|BPI|RPI|RPI2|RPI3|Galeio|
|[]()|

panda
edimex
