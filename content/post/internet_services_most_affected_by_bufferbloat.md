+++
date = "2019-01-30T18:02:58+01:00"
draft = true
tags = [ "bufferbloat", "benchmarks" ]
title = "The kinds of tests others do"
description = "I really should do more of these"
+++

One of my disappointments in the bufferbloat effort is how little the cloudy services have recognised that this problem along the edge affects their businesses, and taken steps to inform their users and incent their ISPs to make things better. There is only so much reach the bufferbloat mailing list, reddit, and blog entries like mine can have!

Google *totally* gets it and of any company out there, has made the biggest dent in bufferbloat, both in the linux tcp and quic stacks and in their google wifi and chrome products.  Multiple DCs - including linode - get it. Apple - shipping fq_codel by default last year on OSX - totally gets it.

Everybody else, not so much. 

For a long time I wrote it off to the fact that only early adopters had fq_codel and cake available to them on their openwrt, ubnt, duma, routers, etc - but now that bufferbloat solutions fill the marketplace, I'd hoped the cloudy services would get on board, and drive bufferbloat fixes to an ubiquitous level.

DropBox, for example, with millions of customers, is critically
dependent on uploads for their business to exist in the first
place. While they've published some great blog entries about how they've improved their data center, there's been not a peep about how their customers can get a better dropbox experience by fixing their routers.

Steam - long abusing tcp in their downloads - not a peep.

I've actually gone personally and had meetings with valve and dropbox in the hope that they would take a timeout to better educate their customers about bufferbloat. 

# VOIP/Video providers - the freeswitch folk totally get it - and a few of the service providers do - but 

And then there are all the huge outsourcing - oracle, salesforce.com, intuit, 

The gaming field largely gets it, but has there been a blog on fixing bufferbloat from twitch? Nope... [just stuff from their users](). 

Another sadness is I keep getting questions like "is bufferbloat still a problem in 2019" - and I look at the stats, worldwide, and sigh - as *especially* in the places where bufferbloat fixes are most needed - in South America, Africa, and so on - [the bufferbloat meme has not yet penetrated](fixme). Short of composing a good tutorial or rant in every language of the world, I don't know how to address this. My "home town" of San Juan Del Sur, Nicaragua, has been debloated in multiple places merely by me wandering around and setting up openwrt for people, and then by word of mouth, but that's just one town, in a very big continent. 

I'd like 2019 to be the year where bufferbloat awareness and fixes crossed the chasm and 