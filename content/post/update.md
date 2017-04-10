+++
date = "2017-04-10T16:02:58+01:00"
draft = false
tags = [ "bufferbloat", "life" ]
title = "Putting stability back into my networks (and life)"
description = "Spring cleaning"
+++

So, after lede shipped in late january with all the main products of
the bufferbloat effort in it - working (which took some doing) - and
the last bits of make-wifi-fast made the mainline kernel - I took time
out for a vacation, and returned to try to do a post-mortem on what
went right and wrong, and what I could do to improve things, and relax
a little bit, and refocus.

First up was: after working on the fundamental layers of the internet
for so long, and traveling so much, I was surrounded by half
implemented, partially broken network things. So I started converting
over infrastructure that for normal people, is reliable, but for me,
hadn't been - all my core routers are now running the lede stable
release (and they are going to stay that way for a while). I got rid
of a bunch of servers I don't use, merged others, moved to mainline
kernels, stopped using OSX and android, etc. With all that stability I
could put back in things I needed - like stable DNS, and NAS servers,
and things like that. For 5 years now - at any given point some
fragment of my testbed and main network was being flaky for some
reason or another - so I couldn't rely on basic services to work.

An example is that using irc OR ssh is hard when your connectivity may
vanish from minute to minute - no longer. It was MADDENING.

I've isolated the flaky stuff to just a testbed network. I have about
20 routers that I need to reflash from serial ports, whenever I get
around to it.

The second thing I tackled was that I resurrected some old work (1998)
towards
a
[very different network simulator](https://github.com/dtaht/libv6/blob/master/erm/doc/philosophy.org),
reviewing the ideas in light of newer knowledge. It was great fun to
*not* have to deal with gerrit, a high volume mailing list, or someone
elses' coding style, and to start wiping some rust off my C coding
skills without having to think about the work being of "grand import",
and to fiddle with learning ARM neon assembly, and playing with the 16
core parallela chip in particular.

After a short exploration of rust - (Rust may be a nicer form of BDSM
than C++, but I didn't stay in the dungeon long enough to find out),
and go (LOVED CSP, didn't much care for the rest of the language), I
settled on trying to make C11 bend to my will, and while I'm not
succeeding on multiple fronts, some of the problems are beginning to
yield.

I did spend more time ranting than coding - but I really needed to get
it out of my system!

The third one - and a fallout of these two things, and my prior blog
post, is that I finally sat down to re-learn enough emacs lisp to
re-automate big portions of my life, and after a few weeks of doing
it, my stress level for dealing with context switches has dropped
enormously. I have integrated org-mode, email, news, irc, again. I
have all my terminals hanging of of $machinename, so I can be on 12+
machines and switch with a keystroke. Org mode - which I use to manage
projects, is automated quite a bit more - and many things that I do
repetitively are all back on function keys where they belong. I can
spell check a whole buffer with a function key, for example. I don't
know about you but I HATE what inline as you go spell checking does to
my ability to pound out ideas!

(it will still take me YEARS to get emacs back in shape, blogging is
not quite as automated as I'd like - I would rather write in org than
markdown - but I hope that I will retain enough lisp in my head to
keep automating out new things as they come along again. I had a whole
bunch of more complicated things I'd used - like a procmail to voice
notifier and some custom window splitting routines - left to recreate)

Along the way I found some new tools - "ripgrep" is great - things
like ecb can be made less annoying - and I'm still in a losing battle
with clang-format to let me switch between project styles and emacs's
styles, but hopefully I'll get there.

And now it's mid-april, I've turned down two contracts in QCA's
products, and I could easily spend a few more months just fiddling
around knocking things off my personal todo list.

I've really, really, really enjoyed not thinking about bufferbloat for
a while. It might be time to change focus - work on higher end
hardware, or shift to mucking with FPGAs... or to finally build the
jamaphone.

I just put a [resume up](https://plus.google.com/u/0/107942175615993706558/posts/VP5hVjfn35G). I'm glad that 6 years of work has all landed,
and have no idea what will happen next. Is there some big problem out
there that my skillset needs - that I can make a living on solving?
This time?

I've been dusting off some old notes on m/m/1 queues, otherwise, that
needs publication, as well as some essential missing steps in the
papers we've published to date on the results of the bufferbloat
effort.
