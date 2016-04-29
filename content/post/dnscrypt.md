+++
date = "2016-04-28T07:02:58+01:00"
draft = false
tags = [ "lab" ]
title = "Dancing with dnscrypt"
description = "Writing stuff up after that first cup of coffee"
+++

Last night the dns failed to the whole lab, again,
[just like it did yesterday](/post/lab_setup_woes). This time I had more
brain cells available to poke at the problem, and ultimately it turned
out that disabling dnscrypt and talking to upstream nameservers directly
cleared it up.

The builds I am using have both tor and dnscrypt support enabled, which,
while improving privacy, leads to chunky dns. I'd rather have fast dns
that always works.

It still made no sense for stuff going to 8.8.8.8 from inside my network
to NOT work, but perhaps I have dnssec on more universally than I
thought.

It also makes no sense to always acquire the same DNS servers for dns via
dhcp or dhcpv6, so I ended up hardcoding my provider's (comcast) into the
openwrt /etc/config/dhcp file.

These are likely to be stable for all of eternity.

Lastly, I think it was foolish to rely *just* on openwrt's upstream ntp
pool and I added a few other dns servers to handle my internal dns. If I
ever get to having stable ipv6 addresses for these...

I will probably go add my own ntp server at some point.

```
        option dnssec '1'
        option noresolv '1'
        option cachesize '5000'
        option localservice '0'
        list rebind_domain 'onion'
        list server '2001:558:FEED::1'
        list server '2001:558:FEED::2'
        list server '75.75.75.75'
        list server '75.75.76.76'
        list server '/onion/127.0.0.1#9053'
        list server '/0.openwrt.pool.ntp.org/8.8.8.8'
        list server '/1.openwrt.pool.ntp.org/8.8.8.8'
        list server '/2.openwrt.pool.ntp.org/8.8.8.8'
        list server '/ntp.ubuntu.com/8.8.8.8'
        list server '/hm.taht.net/172.26.18.1'
        list server '/gw.taht.net/172.26.16.1'
```
