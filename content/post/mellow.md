+++
date = "2016-04-16T18:02:58+01:00"
draft = true
tags = [ "bbr", "Fair queuing", "bufferbloat", "papers" ]
title = "Mellow TCP"
description = "Can a new LPCC TCP be developed that uses zero queuing?"
+++

One of the first things I worked on when we started the bufferbloat effort
was trying to figure out what bittorrent was doing wrong. I *knew*, going
in, that we were going to "break" torrent by appling either AQM or FQ technologies
at the edge - and not only did we prove definively that low priority 
congestion control (LPCC) got reprioritized with aqm and fq technologies,
I like to think we also proved that it didn't matter.

The paper evolved and evolved over the years, with multiple publications,
and it's become a thing of beauty - but they didn't need to keep my name
on it! I've had nothing to do with LPCC since my stay at the LINCs in 2012.

Since my name hasn't appeared on that many publications - and it's a wacking
good paper - I guess I can live with it. :)

My only disappointment is the work ended with red and sfq, and I've
gone onto working on things like fq_codel and cake, which I'd LOVE
to have the same level of analysis on. Some of the things in cake
are expressly designed to make the notion of "background traffic" more
feasible, notably full support of classification, and the per-host
fairness ideas ("triple-isolate"), on top of a 8 way set associative 
5 tuple hash, that can decode NAT before hashing.

(I have to point out that most of the work on cake is being done by others,
also)

I've put thinking about LPCC on the back burner, in favor of thinking
about good congestion control, in general - but...
occasionally I have an idea that has to go into that bucket,
and I'm just going to accumulate those ideas here in the hope that maybe
someday everything will congeal.

## Bittorrent in general


## Background and Least effort classification

How much bandwidth should background traffic get?

Originally, I thought it should be 5%, but it turned out that 90% of
comcast traffic was mismarked CS1, so I upped it to 25%. Even then,
that's unworkable. The only answer that works is for users to be able
to do whatever level of background traffic they want outgoing, and for
everyone to agree that - somehow - CS1 should be preserved e2e - and
that it should mean - deprioritize this, but not too much!

Or we should invent yet another diffserv codepoint for it.

I've largely given up on classification as anything other than a "hint",
better algorithms are needed both on the TCP, and on the router.

## Nagle

Nagle once said: "That every application is entitled to one packet in the
network". More drastically, you could limit that to every host is entitled
to one packet in the network.

## Flower

## Mellow TCP - a medium capacity tcp for fq'd networks

IW2, subpacket windows and mss reduction

## BBR

## CDG

## Bandwidth enforcer

## Coupled congestion control

Fixme. I've

## The future!

I would hope - that some time in the indefinate future that we will 
hit "peak bandwidth" - wherever everybody, all the time, always has enough.

I think we are actually pretty close to that in many respects across the
broader internet. Aside from demands for 4k video, the need for extra
bandwidth across the edge seems to have peaked at about 100mbit, worldwide.
