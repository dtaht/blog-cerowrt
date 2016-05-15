+++
date = "2016-04-24T22:02:58+01:00"
draft = true
tags = [ "lab", "wifi", "bufferbloat" ]
title = "Salvaging IPv6"
description = ""
+++

Everything important had gained a fully static ip address.

Then they came for my ipv6. Despite having a static ipv6 tunnel for
a decade, the ISPs decided to disenfrancise everybody and reassign
ipv6 addresses

I'm told I can buy a /48 from comcast. I'm still waiting.

I assign a single static identifier - an IPv6 ULA subnet.

dozens, hundreds, they dont care

It's a router

Too many moving parts.

ruptime. rwho

useful services

it's a shorter identifier than IPv4, and easier to type.

Covering routes.

proto static misused
proto dhcp not used correctly at all
proto homenet not defined

root@dancer:~# ip -6 addr add fd98::128/128 dev lo help
Usage: ip address {add|change|replace} IFADDR dev IFNAME [ LIFETIME ]
                                                      [ CONFFLAG-LIST ]
       ip address del IFADDR dev IFNAME [mngtmpaddr]
       ip address {show|save|flush} [ dev IFNAME ] [ scope SCOPE-ID ]
                            [ to PREFIX ] [ FLAG-LIST ] [ label LABEL ] [up]
       ip address {showdump|restore}
IFADDR := PREFIX | ADDR peer PREFIX
          [ broadcast ADDR ] [ anycast ADDR ]
          [ label IFNAME ] [ scope SCOPE-ID ]
SCOPE-ID := [ host | link | global | NUMBER ]
FLAG-LIST := [ FLAG-LIST ] FLAG
FLAG  := [ permanent | dynamic | secondary | primary |
           [-]tentative | [-]deprecated | [-]dadfailed | temporary |
           CONFFLAG-LIST ]
CONFFLAG-LIST := [ CONFFLAG-LIST ] CONFFLAG
CONFFLAG  := [ home | nodad | mngtmpaddr | noprefixroute | autojoin ]
LIFETIME := [ valid_lft LFT ] [ preferred_lft LFT ]
LFT := forever | SECONDS

The come and go, 

I want permanent identifiers. Not only do I want permanent identifiers,
I want the connections to the to never drop.

ever since ipx/spx died, and we split out naming from the core protocol,
getting persistent identifiers has been a problem.
#routing
redistribute ip fd99::/128 eq 128 allow 


```
auto lo
iface lo inet loopback
        post-up ip -6 addr add fd99::5/128 dev lo proto static
```

```
redistribute ip fd99::5/128 eq 128 allow
redistribute ip 172.26.48.0/24 eq 24 allow
redistribute local deny
```

Proto static. This ommission on where an address comes from 

DHCP, DHCPv6, dhcp-pd, SLAAC, Privacy Addresses, HNCP, static, and various
forms of vpn.

There are insufficient "hints" applied to figure out which is which.

I've thought about using the scope identifier to fix it, but that
doesn't get me anywhere.

ip route add proto static
ip addr add proto static

This problem is really curious in that source address selection can be 
improved, a bit, where applications more readily aware of what could be
used to

Let's take registering in DNS as an example. Privacy addresses should
not be registered in the global address space (probably) - unless that's
all you got and you want to provide a world visible service.

If we had stable ipv6 addressing this would not be such a problem.

Take mdns, also  - 

tried to encode the source address selection into the bits.

But that fails also. For example, since I rarely have been able to get
a native dhcp-pd delegation.

##  

## Trust


