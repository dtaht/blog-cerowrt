+++
date = "2016-05-15T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat", "ath10k" ]
title = "ECN handing is broken on OSX Mavericks"
description = ""
+++

ECN handling is broken on OSX Mavericks. nearly half of my tests thus far
have been using ecn enabled by default on the OSX box, in order to
provide a comparison between the high speed card in the osx box vs
the slower speed ath9k in the linux box.

{{< figure src="/flent/apu2/mavericks_is_broken_with_ecn.svg" >}}

