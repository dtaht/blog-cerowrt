+++
date = "2016-03-30T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat" ]
title = "OSX vs ECN"
description = "You'd hope OSX would have got ECN right"
+++

ECN: It's the bomb, it's the bee's knees.  and it's not very necessary.

Fixme: take on cheshire's preso.

[osx_vs_ecn_issue]

And experimenters tend to use what is around the lab and easy to
configure, tends to use linux rather than windows or osx. As we are
trying to deploy this csort of code to all the machines on the internet,
NOT testing aagainst windows and linux has struck me as a bad idea.

However - just like all the experimenters - I'm on a low budget, so I
have exactly one OSX box to play with - and while I'm glad you can get
an intel compute stick with windows 10 pre-installed, it only can hook
up via wifi and that's not what we're testing here.

What's wrong with osx?

{{< figure src="/flent/cake_vs_everything/osx_vs_ecn_issue.svg" >}}


Thanks for calling today.

Here’s my presentation from last summer’s Apple Developer Conference:

<https://developer.apple.com/videos/wwdc/2015/?id=719>

Skip the first 15 minutes about IPv6, and you’ll get to my part where I talk about reducing networking delays using Smart Queueing, ECN, TCP_NOTSENT_LOWAT, and TFO. There are some interesting graphs showing how smart queueing (like CODEL) and ECN reduce delays and improve interactivity for things like streaming video.

Also do a Google search for Bufferbloat.
