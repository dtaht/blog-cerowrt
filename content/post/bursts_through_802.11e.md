+++
date = "2016-03-30T18:02:58+01:00"
draft = true
tags = [ "wifi", "bufferbloat" ]
title = "How do 802.11e queues behave?"
description = "802.11e is *weird*"
+++

via:

http://lists.infradead.org/pipermail/ath10k/2016-March/007070.html

I've re-tested selected cases with wmm_enabled=0 set on the DUT AP.
I'm attaching results.

Naming:
 * "old-" is without mac/ath10k changes (referred to as kvalo-reverts
previously) and fq_codel on qdiscs,
 * "patched-" is all patches applied (both mac and ath),
 * "-be-bursts" is stock "bursts" flent test,
 * "-all-bursts" is modified "bursts" flent test to burst on all 3
tids simultaneously: tid0(BE), tid1(BK), tid5(VI).


Michał

On 16 March 2016 at 19:36, Dave Taht <dave.taht at gmail.com> wrote:
> That is the sanest 802.11e queue behavior I have ever seen!  (at both
> 6 and 300mbit! in the ath10k patched mac test)
>
> It would be good to add a flow to this test that exercises the VI
> queue (CS5 diffserv marking?), and to repeat this test with wmm
> disabled for comparison.
>
>
> Dave Täht
> Let's go make home routers and wifi faster! With better software!
> https://www.gofundme.com/savewifi
>
>
> On Wed, Mar 16, 2016 at 8:37 AM, Dave Taht <dave.taht at gmail.com> wrote:
>> it is helpful to name the test files coherently in the flent tests, in
>> addition to using a directory structure and timestamp. It makes doing
>> comparison plots in data->add-other-open-data-files simpler. "-t
>> patched-mac-300mbps", for example.
>>
>> Also netperf from svn (maybe 2.7, don't remember) will restart udp_rr
>> after a packet loss in 250ms. Seeing a loss on UDP_RR and it stop for
>> a while is "ok".
>> Dave Täht
>> Let's go make home routers and wifi faster! With better software!
>> https://www.gofundme.com/savewifi
>>
>>
>> On Wed, Mar 16, 2016 at 3:26 AM, Michal Kazior <michal.kazior at tieto.com> wrote:
>>> On 16 March 2016 at 11:17, Michal Kazior <michal.kazior at tieto.com> wrote:
>>>> Hi,
>>>>
>>>> Most notable changes:
>>> [...]
>>>>  * ath10k proof-of-concept that uses the new tx
>>>>    scheduling (will post results in separate
>>>>    email)
>>>
>>> I'm attaching a bunch of tests I've done using flent. They are all
>>> "burst" tests with burst-ports=1 and burst-length=2. The testing
>>> topology is:
>>>
>>>                    AP ----> STA
>>>                    AP )) (( STA
>>>  [veth]--[br]--[wlan] )) (( [wlan]
>>>
>>> You can notice that in some tests plot data gets cut-off. There are 2
>>> problems I've identified:
>>>  - excess drops (not a problem with the patchset and can be seen when
>>> there's no codel-in-mac or scheduling isn't used)
>>>  - UDP_RR hangs (apparently QCA99X0 I have hangs for a few hundred ms
>>> sometimes at times and doesn't Rx frames causing UDP_RR to stop
>>> mid-way; confirmed with logs and sniffer; I haven't figured out *why*
>>> exactly, could be some hw/fw quirk)
>>>
>>> Let me know if you have questions or comments regarding my testing/results.
>>>
>>>
