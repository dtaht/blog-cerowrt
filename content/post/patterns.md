+++
date = "2016-09-08T10:02:58+01:00"
draft = true
tags = [ "ath10k", "ath9k", "osx", "rrul", "wifi", "ubnt-uap-lite" ]
title = "Pulling wifi performance data out of queue-patterns"
description = "My life is full of patterns that can scarcely be controlled - Paul Simon"
+++

Kelly Johnson could "See air". I've come to know a lot of people that
can "see packets" - that can tear apart a network trace at a glance
and say "There's your problem." I'm getting to be like that myself,
divining data from packet captures, overseeing simulations, running
many iterations of all the flent tests across all the technologies.
Toke asked me to try and refine how to look at the
[crypto+fq](/post/crypto_fq] bug, so we could better see it in the
future, so I spent the weekend trying to see patterns in it.

Such a good intro. FIXME

I never got around to testing the crypto fix, I started off with a
laptop with last month's code and never got anything that worked well
enough in the first place to move on to the crypto stuff!

Normal users won't care.

Encode it in the IP.

Going through all these gyrations "to pass the test" - is not what happens to normal people. 

{{< figure src="/flent/patterns/patterns.svg" title="Patterns" >}}

Got it under control.

The next problem was less obvious - the target server did not have
enough cpu to drive the test so it started sending less data, which
allowed for a better balance of up to down - but was not a valid test.

I switched to another test server to get this result.

I worry about other people's test servers and clients. A lot use
Windows, which didn't see any of Linux's TCP improvements until
windows 10. Most of my tests of lower end hardware show it peaking out
at around 300Mbit in one direction, and usually asymmetrically slowing
when exercised by the rrul test. The wndr3800 peaks at 200 in one
direction and 130 in the other.  The apu2 - otherwise one of the best
pieces of test gear I have, starts getting wonky at about
600Mbit/600Mbit up and down. It can drive either direction fully but
flails on the rrul. Or my network switch has issues.

Lastly, I seriously distrust other folks often reported "single" value for TCP. Here's a plot of some long term behavior for a different AP, using the minstrel rate selection algorithm.

{{< figure src="/flent/patterns/patterns.svg" title="Patterns" >}}

What do you take? the min? the mean? the median? the value at the
conclusion of the test?

"There is no information about about demand or load contained in the
average." - Van Jacobson

Worldwide bufferbloat is partially the result of accidentally
"engineering to the test". People used speedtest, which ends in 20
seconds, to test the path, and sized their buffers to suit. The test
did not check for received data, but only sent, and it didn't matter
to anyone til we got started if the network exploded if you ran the
test for 21 seconds rather than 20. Which is what happens.

Aside: I worry about people engineering to rrul.

6 always

{{< figure src="/flent/patterns/ath10k_60ms.svg" title="no fq_codel'd ath10k 180mbit 60ms latency" >}}

2

{{< figure src="/flent/patterns/fixedbufferingsucks.svg" title="no fq_codel'd ath10k 180mbit 60ms latency" >}}

3

{{< figure src="/flent/patterns/linux_no_channelscan_5ghz_60ms_latency.svg" title="no fq_codel'd ath10k 180mbit 60ms latency" >}}


patterns.svg

Seeing something on a 30,60,120 second period is usually an indicator of a problem in some daemon somewhere.


   <div id="toc" class="well col-md-4 col-sm-6">
    {{ .TableOfContents }}
   </div>
    
## Disabling channel scans

{{< figure src="/flent/patterns/channel_scan_impact_5ghz.svg" title="no fq_codel'd ath10k 180mbit 60ms latency" >}}

Let's disable channel scan by locking the box to the BSSID

{{< figure src="/flent/patterns/no_channel_scan_5ghz_linux.svg" title="no channel scan 5ghz" >}}

Much better. Still, see those drops in throughput? At the time, I was
pacing back and forth, thinking, between the two devices under test,
trying to figure out what the cause of all the problems were,
generating interference!

It may well be that all the fixes to power save, the retry path, etc,
that Felix has been landing, will make channel scans less damaging.

### 

### Network Manager

Wildcard channel scans damaging to *all* the APs in the area which
have to respond.

IMHO, a client, should lock itself to BSSID and only scan for the same
SSID on that and other channels when the signal level drops too low,
(it does this already for WPA Professional).

Note: for normal use, you have to tell network manager to lock the
same BSSID(s), once, manually, which I do, regularly.  Except when I
forget.

Still, exposing this behavior as we did has been useful for seeing
issues in wifi multicast, and hopefully we'll find and fix more
problems.

### What should the AQM component do? 

### What should an endpoint do?

When doing a channel scan, or a route change, all your assumptions
about the path are about to go to hell.

There's no e2e "pause" command in tcp, nothing to signal the stack to tell it to re-evaluate its current state.

The Linux plug scheduler was designed to handle vm migration, but it too
makes invalid assumptions - queues will build uncontrollably while the
changeover happens. Queues also (in the current mac80211) code can
build uncontrollably when a device drops offline or offchannel
temporarily. The AP has to issue a wakeup call on a DTIM (multicast)
interval when its acrued packets for a station that's asleep.

eNode-B - whenever you see someone bragging about fast channel
switching, ask them how big their queues were, also, in the first
place?

They were on, all the time.

One advantage of having short queues is the damage done by a changeover is minimized. I hope to show
channel switching being less damanaging in some future paper or blog post.

## Multiple flow disparity

Upsets bulkier technichs lik GRO and TSO from working as fully as they might.

## Uplink/Downlink disparity

## Babel breakage

In converting this device from being a router to bridge, I'd
accidentally left babel on. A transparent bridge advertising its own
IP as a viable routable destination is a bad thing. Routing is almost
always slower than bridging.

If you are going to run a routing protocol on a transparent bridge:
what should it do? My desire to run it is based on the idea to have a
well known control channel to be able to manage it - it needs an IP
for that. Some folk use management vlans to do this, others mac
identification tricks, me I just want to announce a distinct IPv6 ULA
to the network - grab local dns and a ipv4 address also, so the device
can get updates from the cloud - and otherwise not care - not try to
route anything itself.

(There are other issues with doing transparent bridging - you want to
disable split horizon processing on all routers on either side of the
link - *they* don't know the bridge is there, that's the point of it
being "transparent".)

Lastly:

A transparent bridge should not, under any circumstance, offer its own
IP addresses as a possible routing opportunity.  Babel will do that,
briefly. I'm not sure why its local IP wins, in the first place, but
it does.

<pre>
root@nemesis:~# ip route
default via 172.26.128.17 dev wlp3s0  proto babel onlink  # bridged babel wins
default via 172.26.128.1 dev wlp3s0  proto static  metric 600  # wifi doesn't
172.20.2.0/24 via 172.26.128.17 dev wlp3s0  proto babel onlink 
...
</pre>

After 30-60 seconds, it starts getting the right "1-hop" route.

<pre>
root@nemesis:~# ip route
default via 172.26.128.1 dev wlp3s0  proto babel onlink 
default via 172.26.128.1 dev wlp3s0  proto static  metric 600 
172.20.2.0/24 via 172.26.128.1 dev wlp3s0  proto babel onlink 
...
</pre>

Going back to the test series that kicked off this blog post, I can
guess that the powersave/multicast bugs being fixed elsewhere also led to
that 2 hop route being chosen before the 1 hop route - or babel saw a
new routerid and flooded it faster with info than the others. Or both.

Ironically - When I converted it to being a bridge, I'd LOST this AP
prior to seeing babel find it again. I'd configured it to get its
address from dhcp and dhcpv6. There was a rogue dhcp server on the
network, AND the dhcpv6 address assignment failed for some reason. I
was afraid I'd have to reflash it from scratch. :whew:

Philosophically, I'd rather wifi and ethernet NOT be bridged together
as they are today, but fixing that requires changing the universe to
have things like mdns, sdp, pcp, and upnp "just work" in a routed environment,
and they don't. Normal users will bridge everything, so we have to
test that scenario more heavily than we have before.

Adding in a wifi-aware routing protocol does help for making better
choices as to which wifi AP to use or a bunch of wifi APs to self
select which are the best to use.

And I'd like all my APs to be reporting in.

I've tried various configurations of various allow/deny rules
to no avail.

<pre>
redistribute ip fd42:a3d6:5621::1/64 allow
redistribute local deny
redistribute ip deny
# It still announces itself as a router sometimes
out if br-lan deny # leave in this line I don't get fd42 exported
out if br-lan ip fd42:a3d6:5621::1/64 allow
# leave it out and .17 gets announced

</pre>

There's something I haven't tried yet (the install filter).

Anyway, I kind of gave up on making babel work on the bridge, and
tossed the question to the mailing list.

I left it running but I block babel with br-lan whatever (now that I
found the device again, on its real subnet, I don't care if it has a
ipv6 management address).

Now, when a device first connects, I get a bunch of *unreachable*
routes to the right box that quickly convert over to being reachable,
for the right box. Why are they are first "unreachable"? Am I
getting routes installed before dhcp completes? An arp fails? 

Another issue: When I change to another radio on the same (bridged) IP
- sometimes all my routes vanish and stay vanished for a very long
time. Multicast group enter/leave delay? what?

I'd like to be able to rapidly switch bridges when circumstances
allow. My hope is that I'll see saner behavior when I do that at the
BSSID level, rather than the whole up/down sequence of losing an ip
and regaining it.

OSX is much smarter than Linux in these regards, it memorizes the last
few ips it had by SSID, and tries to default to those, saving on a few
DHCP exchanges.

## 5ghz 

{{< figure src="/flent/patterns/ath10k_60ms.svg" title="no fq_codel'd ath10k 180mbit 60ms latency" >}}

Then I realized that this was a new device with the ath10k in it, which
has not had *any* of the fq_codel patches applied to it yet. AHA! That
fixed relationship between buffering and latency is what we're trying
to break with fq_codel in the first place - try to get the right
amount of buffering for the given bandwith, even if it changes.

You can see bandwidth dropping off for some reason, here, and the
resulting climb in latency. This is a drop from 200Mbit to 100Mbit,
essentially tripling the latency. Imagine dropping to 10Mbit... or
less, as wifi often does.

The bandwidth was nice, though - we can reference this data after the
fq_codel code for the ath10k goes in to see if we helped or hurt
anything.

You can see the elongated TCP sawtooths, the excessive buffering
causes, changing sides as they should.

A tenet of the bufferbloat project's effort is that the lower the
latency, the faster TCP is to grab or release bandwidth. Nearly
everything you can do to reduce the RTT helps TCP.

So I moved back to testing 2.4ghz.

## 2.4ghz

Breaking the 

{{< figure src="/flent/patterns/no_channel_scan_2.4ghz.svg" title="fq_codel'd ath9k 2.4ghz 65mbit 20ms latency" >}}

Either HT40 mode is not supported, or there's too much interference in
the lab for it to be used. My bet's on the first one. I don't care too
much (using HT40 is hard on the available 2.4ghz channels - I'd rather
have 3 non-interfereing channels to play with than 2), but I should
poke into it harder and bug report it.

{{< figure src="/flent/patterns/fixme" title="Minstrel, MCS4, MCS1 compared" >}}

Anyway, 2.4ghz shows the nice flat latency we get at all rates,
now. :whew:. (the above plot is from the [wndr3800](fixme) data.

## Minstrel takes too long to find the right rate

More than anything else, the above test points to flaws in Minstrel -
taking 40 seconds to find the right rate is far too long.

Long period tcp traffic, primarily. This is not how most people use
wifi: They pop up, grab a web page, and get off, in under 6
seconds. Netflix operates at a fairly fixed rate (<20Mbit) and while
what they do is bursty it usually runs at below the wifi rate (except
when it doesn't)

Expansion of the search space. Taking 40 seconds to find the right
rate is far from ideal.

An ideal finding would be - find the right rate within 100ms. There
are multiple features in the 802.11ac standard (not 802.11n) which
might make it easier - "sounding" for mu-mimo, there's a new set of
fields in the header that can tell the AP how the client is doing, and
so on.

One thing I didn't know is that minstrel also continuously tests the
same rate with a short and a long guard interval. I'm not sure why it
has to do that - but that too, explodes the parameter space at HT40
to *43* possible rates.

## Testing the airtime fairness code (finally)

I set up an OSX mavericks box to compete against the Linux box in a new airtime fair test. 

{{< figure src="/flent/patterns/osx_grabs_disproportionate_amount_of_bandwidth.svg" title="wtf" >}}

Conclusion: the OSX box *is cheating*, grabbing the most airtime for
itself (probably) by using a contention window smaller than the
default standard for "best effort" traffic. This is bad for everybody
else on the link - and even bad for itself, when it wants to transmit
data in both directions at the same time!

{{< figure src="/flent/patterns/osx_relatoinship_between_bandwidth_latency.svg" title="OSX relationship between bandwidth and latency" >}}

## Conclusions

Despite all these issues, we're doing good. The ubnt-uap-lite appears to be an ideal product for the make-wifi-fast
project.




