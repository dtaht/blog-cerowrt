+++
date = "2016-03-30T18:02:58+01:00"
draft = true
tags = [ "fq_codel" ]
title = "Fixing udp packet floods in fq_codel"
description = "Inelastic traffic sucks"
+++

It's a hostile world out there. Script kiddies equipped with ion
cannons, whole businesses founded on

cpu overloaded,

bad things happen. With fq_codel different bad things happened.

{{< figure src="/flent/fixing_floods/cpu_before_after.svg" >}}

It didn't matter - fifo_tail drop,

dithered around,

Circuit breakers
```
Really
```
