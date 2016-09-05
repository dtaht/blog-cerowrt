+++
date = "2016-09-05T10:02:58+01:00"
draft = false
tags = [ "ui", "distractions", "rants" ]
title = "Blinkenlights: A debugging aid AND a curse"
description = "Too many LEDs! Give me back the stars!"
+++

Engineers sink loads of time into making the LEDs on their devices do useful things and have meaningful patterns - Me, most of the time, I just want them *off*. They are distracting. I put black tape over them, I hide them behind other things, put them in boxes and drawers and cabinets... but until now, I never tried really hard to turn them off *in software*. I don't know why I'd never tried that before.

## Evoking meaning from binary digits, when that's all you have

There are whole manuals on all the different meanings of blink patterns in the POST step
on x86 hardware. 4 long, 2 short means something entirely different than 2 short 4 long. Everything has a "power is on" light, everything has multiple indicator lights
that indicate something important. Your car has a *low oil* light.

But the common availability of cheap LEDs have led to a profusion of lights always on, or blinking in some pattern, that must mean something, that my subconcious is always attempting to extract meaning from.

The "blinking 12:00" that coffee makers and microwaves have have driven multiple generations
nuts. It's an Internet meme all by itself.

I've worked really hard in my life to get that first board to come up far enough to actually
enable an LED, and done a little dance of triumph when it finally did. But:

My laptop has 3 VERY bright led's indicating... power, and I don't know what.

The beaglebone green wireless has four lights that have a pair flash back and forth, all the time, after booting. There's other fancy programming indicating when a firmware load is happening, all the lights go off when a reflashing is done, the lights flash in sequence a bit like "kit" when the OS is booting.

On routers, there's usually a golden ethernet light indicating 1Gbit, and green indicating 100Mbit - or is it the other way around? There's one for each port. Then there's that light for power, another for each of the wireless radios, and one for while WDS is active.

Everyone is trying to encode meaning into these things, because, well, that's what you do. They
are there, you gotta use them for something.

LED programming is a great pastime. The guy that programmed the connection machine's blinkenlights is a geek hero - because he had no API and he had to co-ordinate each processor's (out of 64000!) 
general activity in sync with all the others to create pretty patterns for movies like Jurassic Park. Programming those LEDs was a full time job! People get gigs making them do cool things at events and parties and burning man, and you'll see endless projects using led strips on various hackboards. LEDs can be *cool*!

I'm not immune to using LEDs to convey meaning - for example, my meshy APs usually
blink red when they are talking over the wireless mesh, and in locations that are not
supposed to be especially meshy, a lot of red lights means something has failed somewhere else.

Still, too many blinkenlights is a curse, when your bedroom is too well lit and you
can't sleep - Even the power light is a curse - 
"*I know the power's on! I have a route for it, and it's pingable*. I'll get an 
email alert if it goes down!"


I finally hit my limit when I deployed two new APs [ubnt UAP AC Lites](/post/uap_ac_lite) in the [yurtlab](/tags/lab), yesterday. I've added a dozen boxes to the lab in the last few days, but
these got mounted up high, so I had to lie here, and watch the on light (white) be constantly on, and see the blue light flash out of the corner of my eye when traffic was present. "Traffic is always present, what kind of traffic is it?" I'm trying to sleep, watching these things blink in crazy ways, and illuminate the entire room - and the added brightness made it
impossible to see the stars through the dome in the roof. The room now was well enough lit to be able to clearly see all the walls in the dead of night.

*Gimme back the stars!*

*One* light in a room - triggered by motion - is useful and comforting. This self-inflicted sea of blinkinglights really got under my skin. And my gf's.

OK... I'd had enough. So at 2AM... I figured out...

## There's an API for that

Linux has gradually evolved to have a standard API for dealing with
blinkenlights. The UAP Lite supports it.  Soooo:

<pre>
echo 0 > /sys/devices/platform/leds-gpio/leds/ubnt:blue:dome/brightness
echo 0 > /sys/devices/platform/leds-gpio/leds/ubnt:blue:dome/brightness
</pre>

And UAP lights went out! 

More generally, anything that exports this api can just be turned off. So I pushed out a 
little snippet of brute force code applied to every device I have (I use pdsh to do stuff like that)

<pre>
for i in /sys/devices/platform/leds-gpi/leds/* /sys/class/leds/*
do
	echo none > "$i/trigger"
	echo 0 > "$i/brightness"
done
</pre>

and fired it up. I dimmed the bedroom by about 2/3s!

Still: Many lights had no userspace controls. None of the beaglebone green wireless's gpios
seemed to change anything. And: Power in particular - I lay awake 
getting grumpy at my power strips.  Does someone make a power strip without a power on light?

I know I'm not alone is wanting the LEDs off. All the googling I did for multiple products
had someone else trying, desparately, to find some way to turn them off, and coming up
empty.

## Stealthy switch

On the wndr3800 - I have 3 of these - out went the wifi lights! Out went the uplink light! In most cases I don't have all the switch ports populated, but, darn it, those lights 
stayed on... ok....

OpenWrt/Lede's swconfig utility lets you address which light blinks on each switch port but there is seemingly no way to turn off the lights entirely. You CAN disable blinking...

<pre>
swconfig dev rtl8366s set blinkrate 0
swconfig dev rtl8366s set apply
</pre>

But there seemingly is no way to turn the darn things off entirely.

Sigh. Out came the black tape, again!

And I - in the end - slept like a baby. Yes, this is what an irasible old hacker does
at 3AM when he can't sleep.

I woke up this morning, unable to figure out if anything in the room was still
working, attached to anything, or functioning at all. All those indicators had had
some meaning, after all.

Hmm... maybe a cron job to re-enable everything at 7AM? I could save all the
previous states in that script and then restore...

Sigh. Now I have to reboot everything to try that out.

So if I have any one UI lesson here, is that if you have an indicator light, it
should *mostly* be used only if *something  wrong*. I'd love it if our "power on" lights
actually were only on when there was no power! (and our UPSes only beep when they
were nearly out of power, but that's [another rant](/post/siliencing_the_ups_beep))

## Using the blinkenlights productively for make-wifi-fast

This exercise gave me an idea that I woke up with. One of the things we are trying to do is shave all the latency and jitter out of WiFi. If I could have a utility that put out a periodic message (multicast or unicast) and could blink multiple devices simultaneously, I'd get a grip on how well we were doing...

I could rig up a high speed camera to it all, capture stuff at 1000 fps, and gather up how good it all is with some machine learning! Put dozens of blinkenlights to good use exhibiting 
parallelism - And then, maybe, I could sync everything to music! Or leverage Linux's sound
system's abilitity to do so! Even if I'm not playing music....

I hit caps-lock a number of times while thinking about how to do that...
and went back to bed. 

Someone no doubt has code for this! If not, maybe I could ping the connection machine guy,
if I could just remember who he was.

Bonus Link: [Richard Feynman's contribution to the connection machine](http://longnow.org/essays/richard-feynman-connection-machine/). (so far as I know he had nothing to do with the blinkenlights!)
