+++
date = "2016-12-30T18:02:58+01:00"
draft = true
tags = [ "todo" ]
title = "Wifi and LTE-U co-existence"
description = ""
+++

Note: this is the portion of this draft from another author, I have my own contribution yet to fold in.

The Wifi Alliance's [co-existence test plan for wifi and LTE-U](specs/LTE-U-CoexistenceTestPlan_v0.8.4_0.pdf)
is currently seriously deficient in multiple areas.


I skimmed it, largely to contrast it with the test plan used by NIST to try to discover interactions between UWB gear and commercial GPS receivers back when we were trying to get UWB systems to be legalized. (and also the testing done by engineers under contract with NPR to demonstrate harm from so-called "Low Power FM" stations, protecting NPR stations from competition).

Technically, the weakest part of the test plan here is typical for these things. It's in the "test environment" section - section 2.1.1.

Based on my (and others') experience with indoor propagation and indoor operation in Multi-Unit Dwellings, residences, and corporate sites, characterized by significant multipath and path loss variability (10's of dB), there is no reason to believe that lab tests of this sort tell us anything about effects observed in the field... they are lab tests, with controlled attenuation (no multipath!) and no random signals that might cause one or the other MAC layer to behave in a non-standard way (microwave ovens, DECT phones, ...)

So if these tests are used as input to FCC type-certification (not operating rules, but the rules that decide what devices can be sold on the market to non-licensed purchaser/operators), they may or may not achieve effective co-existence in actual practice.



The errors can go either way:



1) disallowing devices that would happily co-exist.  Note that the FCC may decide that the fault is with WiFi devices that are not friendly with LTE-U devices.  This would essentially damage innovation in uses of the U-NII band, highly desired by both the WiFi alliance (which wants to bar alternatives to WiFi from entering the market), and the LTE-U creators (who want to control or reduce the market share of WiFi or any new alternative using U-NII).



2) allowing devices that appear to co-exist, but which in fact do not.  Note that LTE-U does not "cooperate" in any way with the WiFi stations that can hear it.  It does not use LBT to mitigate interaction with the WiFi MAC.  Instead it assumes that the only WiFi stations that will be disrupted are those that are "heard" on the average.  Some WiFi uses transmit *very rarely*, so the average traffic is almost impossible to detect.  Then they transmit a few packets and go to sleep for long periods.  Unless the LTE-U *stations* (not just the access points) have their receivers *always turned on*, they won't see this traffic *at all*.  And since they don't use LBT, they will obliterate such WiFi stations's tiny use of the spectrum.

A cautionary tale from the UWB-NIST study suffices.   (It should be clarified that one use of UWB competes in the market with satellite-based GPS, because UWB networks can provide "mesh-based geolocation" that can be accurate to centimeter lengths, and works indoors).  The "test setup" involved just such an unrealistic plan - using the cheapest off-the-shelf GPS receivers of the time, and putting prototype UWB systems within a meter of the GPS receivers, and requiring that *none of the GPS receivers lose lock* as a compatibility test.  This extreme test was promoted by the FAA because it claimed that GPS loss-of-lock would cause airplane catastrophes.  (though only folks in Piper Cubs use cheap commercial GPS receivers that they can hold in their hand while flying).



The result of the acceptance of this test's results by NTIA and FCC OET was to legalize UWB, *only if the spectrum mask was such that none of the GPS band could be included - and that GPS band coexists with many, many other high-powered radio services*.  And the radiated power of UWB transmitters was reduced to the level such that any practical range was around 2 meters.   In other words, the marketable UWB possibilities became tiny, killing the whole industry, while seeming to "legalize UWB".



So-called "unlicensed operation" has simple operating rules (Part 15).  But the *type-certification* rules are arbitrary.



Since this whole mess is about setting "type-certification" rules and not operating rules, it's easy to get confused about what is happening here.



It is "type certification" that is forcing the industry in the US to "lock up" access points with DMCA-like software locks.



In my personal view, it is a terrible strategy (and thus terrible tactics) to negotiate monopolies on "type certification rules" that divide up the pie between WiFi and LTE-U, especially with flawed compatibility tests.



Generally, I tend to represent the technologies *yet to be invented* (though technically feasible and better than current ones).  So while I feel for the WiFi guys in their battle against LTE-U guys, there is a third party, the public interest in better stuff in the future, that is going to get screwed.  Just as they got screwed in UWB and in Low Power FM, and in Northpoint, etc. Perfectly compatible and better technologies will be destroyed before they are born by badly drawn type certification rules (which aren't even "spectrum" rules).



Nobody pays me to get involved in every spectrum and licensing battle on the technical side. I can't afford (not being Gilmore) to pursue this stuff on behalf of the "uninvented".  But I do spend money on it occasionally.



So it is really useful to get a sense of what kind of deal the WiFi Alliance is going for with the LTE crowd.  Because they will settle on a deal, and it will be commercially as good as possible for both. No one will represent any alternatives, and things like peer-meshes, better MACs (for either LTE-U or WiFi), propagation sensing and cooperation, asymmetric connections, mutual assistance, and other architectural improvements will be ruled out, unless some very clever interventions happen.  In the "deal" it is almost certain that firmware openness will be the first thing to be lost - it's already lost, in fact - how will the high-level MAC coexistence be "proven" unless all of the software is locked down bia strong encryption at type-certification time.


* it doesn't handle HD video testing - it's just VoIP for low jitter
and then bulk transfer. For what we're doing at work (live HD video
streaming) we care about jitter /and/ throughput at around 20-30mbit
per stream.
* it has a limited set of very nearby APs and STAs, which doesn't map
to devices at home.
* - yes, 30 APs, but also there's upwards of 10 devices in the average
home these days, and they're all doing a variety of live and not live
streaming stuff.
* it's only UNII-1 and UNII-3, without at all working on the DFS
channels. It's kinda annoying; it's almost like they're avoiding DFS.
(I would've thought that this would be great for DFS channels, as it's
mostly indoors..)

And there doesn't seem to be any explicit coexistence designed for
say, integrated 5GHz wifi + LTE-U proposals. Ie, I'd kinda like to
have some idea of how this could work, as I'm sure people will want to
build integrated units so the LTE doesn't interfere with the 5G wifi,
and vice versa. But, this is just a coexistence test, not a
coexistence document..

Thank you for the link. That test plan is seriously flawed in multiple ways -

0) the test environment is absurdly simplified, an inadequate number
of stations and aps are in the test environment and...

I have no idea what to do about it besides complain. Is there some
path where comments like these might be heard?

1) they are lab tests, with controlled attenuation (no multipath!) and
no random signals that might cause one or the other MAC layer to
behave in a non-standard way (microwave ovens, DECT phones, ...) -
indoor propagation and indoor operation in Multi-Unit Dwellings,
residences, and corporate sites, are characterized by significant
multipath and path loss variability (10's of dB)

There is no reason to believe that lab tests of this sort tell us
anything about effects observed in the field.

2) it assumes that the only WiFi stations that will be disrupted are
those that are "heard" on the *average*.  Some WiFi uses transmit
*very rarely*, so the average traffic is almost impossible to detect.
Then they transmit a few packets and go to sleep for long periods.
Unless the LTE-U *stations* (not just the access points) have their
receivers *always turned on*, they won't see this traffic *at all*.
And since they don't use LBT, they will obliterate such WiFi
stations's tiny use of the spectrum.

And when wifi is in heavy use - say, for example with
videoconferencing or HAS traffic, or merely with a large number of
active stations, interference with other APs and stations is already
unbearable for 2.4ghz and getting that way for 5ghz.

I'm pretty sure LTE-U will work at 4AM, and also pretty sure that
"average" conditions don't exist in businesses 9-5, or in homes -
18:00-23:00. One of my fav demos of that was nobody - not one
corporate reviewer - was ever able to get a chromecast to work in
their office spaces.

3) So-called "unlicensed operation" has simple operating rules (Part
15).  But the *type-certification* rules are arbitrary. Since this
whole mess is about setting "type-certification" rules and not
operating rules, it's easy to get confused about what is happening
here.

It is "type certification" that is forcing the industry in the US to
"lock up" access points with DMCA-like software locks.

4) My own work is focused on improving the efficiency of wifi, by, in
part, by improving mac efficiency to a level we have not yet seen from
802.11ac - and would not be demonstrated by the tests on any current
AP, except maybe cisco's gear.

5) The simple up and download tests specified were totally unlike
typical web traffic and stress tests like flent's rrul tests would be
more revealing.

6) Is the Wifi alliance aiming for a "deal"? or are they trying to
keep LTE-U out of this spectrum?

## Other test results

urprisingly the LTE-U Forum has actually posted the slides from the workshop we attended last week:

http://www.lteuforum.org/workshop.html

The Qualcomm deck has a bunch of results showing WiFi behaving poorly to other WiFi:

http://www.lteuforum.org/uploads/3/5/6/8/3568127/lte-u_coexistence_mechansim_qualcomm_may_28_2015.pdf

eg.., last slide in the deck.

```
Minstrel was specifically designed to deal with this kind of
interference; there was a generation of analog video cameras and
cordless phone systems that showed similar behaviour.  Other systems
may behave very poorly.

I do think 100 ms cycles at 50% duty cycle is a very, very poor
choice, both for coexistence with other spectrum users and for general
usefulness of LTE-U.  That will lead to really horrible queueing
behaviour inside the LTE-U stream, for one, which will make it useless
for gaming and VoIP (noting that some parties may regard the latter as
a feature).  And also, consider that the natural time scales in the
general environment are wifi's default 102.4 ms beacon interval plus
50 and 60 Hz AC interference from microwave ovens, analog video
cameras and wireless HDMI repeaters.  The strobing of a 100 ms cycle
against these is going to cause repeating patterns of poor performance
for all users of the band.

I strongly recommend choosing something else: 20, 12.8 or 25.6 ms at
50% duty cycle would be far, far preferable, and faster than that
would be better.  Best of all would be to use some sort of adaptive
coexistence.```
