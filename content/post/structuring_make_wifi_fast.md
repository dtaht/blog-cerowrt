+++
date = "2016-12-30T18:02:58+01:00"
draft = true
tags = [ "todo" ]
title = "Pitching make-wifi-fast"
description = ""
+++

## DIVERSE / DIFFUSE ACTION REQUIRED

About 1/3 fto 1/2 of the concrete actions required/recommended can
occur "organically", that is, through ad hoc and semi-organized
efforts of individuals and small teams.  The remaining work will
require fairly dramatic engineering investments and also
cross-industry changes in mindsets and practices - not something IMHO
achievable without a paradigm shift (see below)

## BIGGEST CHALLENGES

- binary blobs and open behavior:  Even after 20 years of open source
driving ecosystem expansion, key players remain incredibly guarded
with regard to "their high-value IP" (herein intellectual property,
not Internet Protocol), all the way down to low-level code in
networking drivers.  In this case I speak from very direct experience,
in particular with semiconductor suppliers who service the WiFi
marketplace.  They are the real source of binary blobs, or more
specifically, obfuscation and lack of access to chipset particulars
and the code that should enable maximum wireless silicon ROI.  These
companies, for better or worse, are IP-driven and almost always
IP-paranoid, even in / especially around otherwise open source
settings.  It will require a simultaneous carrot and stick approach to
get them to abolish the blobs:  a clear value proposition to fully
open source drivers and exposed MAC and performance assist
technologies, and an unpalatable onus for continuing business-as-usual

- legacy / backward wireless standard interoperability:  across the
spectrum of IT we see how backward compatibility provides short-term
business gain and long-term ecosystem pain.  My favorite examples
include the x86 architecture, the ARM architecture, HTML attributes,
legacy encryption standards (now enabling back-off exploits), the US
and IPv4 and support for 16 and 32 bit infrastructure in an
increasingly 64 bit world.    The WiFi document highlights how
backward compatibility is killing WiFi performance.  My suggestion is
the establish a new "basement", wherein devices after a certain point
will only support newer standards, with explicit provision on how to
handle legacy with parallel tech, as was the case in the early days of
WiFi (e.g., with USB-based and SD-interface devices vs. native ones)

- Co-opting the WiFi Alliance:  the WiFi brand is currently owned by
the WiFi Alliance who, IMHO, think that they are doing a great job of
managing the brand and of promoting WiFi evolution.  Not.

## BIG SOLUTION

I think the key is to "invent" a new WiFi.  It might really use the
most advanced versions of existing tech, but it would get a new name,
and most importantly, new standards that encompass many/most of the
micro-solutions outlined in Jim Getty's "Make WiFi Fast" document, as
follows:

- a clean transition to the most advanced, forward-looking spec cum standard

- a consortium to (re)brand the new medium (call it Firefly or what
you will) and establish ground rules for participation, enforced by
branding rights:
    * no binary blobs ~ fully OSS drivers and other support code, up
to a pre-defined level in the stack
    * driver coding standards for Linux, Windows and RTOSes to promote
openness, anti-buffer bloat, etc.
    * specific provision for the use cases mentioned in Jim's document
(e.g., multicast, mesh, IoT, etc. [pardon non orthogonal members])
    * specific rules on how to continue supporting legacy 802.11* with
completely parallel infrastructure (albeit in same sorry band)
    * two (no less) strong founding members, comprised of one wireless
chipset provider (of substance) and one OEM (ideal would be Intel and
Cisco - dream on) and incentive for the rest of the gang to join on
day 1 or 2
    * special extraordinary efforts to get Asia on board - China in
particular - to participate (concessions probably required, esp.
around security, as before)
    * start with a professional body management company (e.g., Global
Inventures) but envision a small professional staff, especially to
manage endowments and to instigate marketing
    * such a new group would need to 1) subsume the WiFi Alliance, 2)
co-opt it and effectively take its place, or 3) find a way to
complement the WiFi Alliance.  The alternative is to stage a putsch
and take over the WiFi Alliance from within, probably on the backs of
key sponsoring members (see
http://www.wi-fi.org/who-we-are/member-companies) (am I overstating
the actual importance of WFA?)

>> I liked his "BIG SOLUTION" below. For lack of a better branding, call
>> it "GoodFi" - or as he proposed "FireFi" - along the way fixing the
>> code, and revamping the standards and technologies to work well, in
>> all use cases, not relying just on blind, dumb, stupid bandwidth
>> driven benchmarks, educating the public, and delivering products,
>> techniques, and tools, that honestly work better in the real world
>> than what exists today, along with a new branding to help drive it.
>>
