+++
date = "2016-12-30T18:02:58+01:00"
draft = true
tags = [ "todo" ]
title = "Wifi and LTE-U politics"
description = ""
+++

My gut reaction to LTE-U was not just no, but "hell, no!" and "hands
off my wifi!". I don't believe in gut reactions, but after a bit of
investigation...

there is not much sign that the LTE and 5G folk have been paying
attention to the queuing delay problem that they have - in the handsets,
towers, and backhauls. Certainly a few of those paying attention to the
bufferbloat effort have spoken up, in pieces like: [5G - it's the
network, stupid](http://dirk-kutscher.info/posts/5g-its-the-network-stupid/)

http://dirk-kutscher.info/publications/managing-radio-networks-in-an-encrypted-world-2/


## Other test results

Surprisingly the LTE-U Forum has actually posted the slides from this workshop:

http://www.lteuforum.org/workshop.html

The Qualcomm deck has a bunch of results showing WiFi behaving poorly to other WiFi:

http://www.lteuforum.org/uploads/3/5/6/8/3568127/lte-u_coexistence_mechansim_qualcomm_may_28_2015.pdf

eg.., last slide in the deck.

## Politics

"Forum was formed by industry members with both LTE and Wi-Fi
expertise – ALU; Ericsson; LGE; Qualcomm Technologies Inc.; Samsung;
Verizon"


I try not to think about what yet another conflicting usage of the same
frequencies means in terms of ongoing standards evolution, in
particular, nor about all the stuff we hope to do to improve wifi going
forward in make-wifi-fast, nor do I like considering a world where
independent deployment of ready-made gear is replaced by centralized
monthly billed gear, and latencies climb still further.

In terms of rhetoric:

I will argue that the phrase "unlicensed spectrum" needs to go, in
favor of talking about "the public" or "personal" spectrum, to make
the emotional argument more effective at the policy layer. Once we
start getting into niceties about how this stuff could actually (not)
work, we've already lost the public debate.

I don't like how the phrase "mobile" conflates the issues, either.

Along these lines, at a private workshop that QC held they showed a
graph showing how unevenly WiFI APs from different vendors share airtime
with each other. They are pushing pretty hard on this argument that WiFi
is a poor neighbor to itself, and in turn LTE-U is no worse... IMHO,
this very weak aspect of WiFi (i.e., very poor certification, companies
gaming or altogether ignoring aspects of the standard) is very
troublesome and is a big reason that LTE-U/LAA has a chance to succeed.
Of course we are not conceding this point to them, but it is what it
is..

FYI: as I understand it the 3.5 GAA spectrum is "licensed by rule", but
2.4 and 5 GHz are not "licensed by rule". Not sure if FCC refers to them
as unlicensed anywhere though.
