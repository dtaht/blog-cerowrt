+++
date = "2016-04-07T22:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat" ]
title = "so-far failed ideas in CeroWrt"
description = "CeroWrt was hopelessly ambitious"
+++

We broadened the scope of the project, to solve other problems that needed solving - like ipv6 - and adding dnssec to dnsmasq - 
At about 2m/year. We did it on much less. But that came at a cost I'm unwilling to pay again.

## Tackling too much

CeroWrt ended up being a substantial fork of openwrt which became a maintenence burden. It grew tougher and tougher to trade
patches back and forth. One inadvertant result is that we made openwrt more robust for getting routing, rather than bridging to work better,
but still, quite often, even today, routing rather than briging can be a PITA.

## Stateless firewall

Presently most firewalls have to reload when an IP address changes or an interface is added. This leaves a window of vulnerability, it breaks nat, and it causes hiccoughs in connectivity.

In CeroWrt, we'd come up with a simple scheme to avoid all that, or so I'd hoped. I renamed devices based on their security model, and type, and
depended on an obscure facility in iptables to pattern match against those devices - "g+" for the guest networks, "s+" for the "secure"
networks, and so on. 

What happened instead? Well, 1

## Bad projections

The headlong explosion in web page size went flat

## Privoxy/Polipo

## Local web services

## Sensors

## Mesh Networking

## BCP38

## Time to make the donuts

## PR

If you want attention, you have to buy it.

## Stablizing things

turris omnia, in particular.

## Funding model

now all those problems are here. 
