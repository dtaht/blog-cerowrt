+++
date = "2017-03-08T12:02:58+01:00"
draft = true
tags = [ "routing", "bufferbloat", "babel", "wifi", "rants" ]
title = "Some potential improvements for several routing daemons"
description = "Bit twiddling packet headers"
+++

One of my first loves is routing protocols, particularly those used to
govern the internet itself (BGP) and those in mesh networks. In both
cases I am a fan of the minimal knowledge required of "distance-vector"
and perpetually at odds with the "link-state" crowd... for going on 40
years.

While dealing with bufferbloat these past few years on multiple levels,
I've been unable to keep my hand in in the development of multiple
daemons and protocols that interest me - notably "babel". Last month I
finally got a a few weeks to poke into some nagging issues there, and I
have a few ideas for improving things, that I'm going to write up below.

The biggest thing that I really, really wanted, was "atomic route
updates", but after poking deeply into the problems, I ended up here:

fixme: xkcd

instead.

## Why Atomic Updates are needed - everywhere

It worked well. Everything was cerowrt based.

Stuck routes. Devices gone unreachable.

this can cause burps in

shift smoothly as it optimized and never disrupt traffic - other than
causing a bit of re-ordering here and there. It was generally my hope at
the conclusion of the fq_codel work, that, with short queues and fair
queuing and BQL everywhere, routing changes, and for that matter, flaps,
would be handled more gracefully and transparently than they ever had
been before.

Instead - I found a string of other problems

What was consistently biting me, as it turns out, was the interference
between babel's state machine and network-managers - or odhcpds -

Babel: delete a route
Other daemon: Oh someone deleted a route - lets send a signal to another
daemon
Babel: add the new route
other daemon: oh, someone added a route, let's recalcuate stuff, and
send another signal to that other daemon.

All these things can be fixed if everything does all their updates
atomically. "Netlink" has this ability - instead of doing an "del/add"
you do a modify.

### INFINITY
###
###

Along the way, I ended up poking deeply into all the codebases for these
daemons and found more than a few places where they can be improved or
sped up, and as I get time, I'll try to apply these ideas universally -
or - by writing these ideas up as I do below - those with interest can
go to town on implementing them themselves.

What I'm doing right now is slowly working my way back out of the
xkcd pit - writing tests - getting better measurements - having a sane
testbed and simulation environment -

... and then, back to writing code.

## Better Error handling

````
FIXME
````

There is a lot of code out there that looks like this - EINTR and EAGAIN
being the two most common error messages returned to the application -
but this is the bare bottom of the barrel of potential error messages
sendmsg can return. The other things that happen only once in a million
times, take seriously stressing out the system to find them. If you
don't find them, applications fail (mysteriously) in the field on real
workloads.

Worse, EINTR represents something entirely different than EAGAIN. EINTR
means your system call got interrupted (for some reason) and you should
try again, immediately (unless the source of EINTR was something you
cared about, like an alarm). EAGAIN, means that you should try again...
at some time in the future... after the error causing it has cleared.

What I came up with looks like this:

````
FIXME
````

There is a little known attribute of the select system call that is
bothersome - in that it will return "ok to write" to an application even
if only one byte is available. A successive > 1 byte call to write will
block, or return EAGAIN, (or is it ENOBUFS?) or only write that 1 byte - and
round and around we go.

I don't actually know if this limitation exists in the Linux kernel or
not (but some reading seems to say it does). This select-ism is an
integral attribute of painful things I learned about syscalls in the
80s! - and I'd hoped, solved, long since. (Here's one good article about
this endless debate about [the right thing wrong thing](fixme))

I'd like it if the select call could be tuned to only return when there
was sufficient space available for all the data you want to send as a
packet, rather than 1 byte.

In linux, you can do this for TCP, but not UDP, for no reason that I can
think of, via the SO_LOWAT setsockoption calls, which as near as I can
tell by inspecting the kernel, only works for TCP, not UDP, flows.

I hope that now that more and more high speed udp daemons (quic anyone?),
that this limitation vanishes in some future linux kernel version. I
might start turning on this setsockopt in the blind hope that one day,
it will work....

The sched_yield() trick I've used a lot on threaded processes (it is, in
fact, needed) - but I'm not sure if it does what I want in the single
process case! My goal here was to give up the process slot and let the
kernel or other daemon catch up on processing data. It makes the
syscall - the abstraction is there - but maybe the select alone will do
it... I don't know.

Anyway, so far, this cuts the amount of worst case error processing to
5ms or 50ms down from 500ms, and does more of the right thing on EINTR,
EAGAIN, and friends, and I'm happier with it than the original...

I'm still chasing a bug that may or may not exist on netlink (once in a
million times, and only under stress), returning errno as the first 4
bytes of it's data.

It would be great to have the "one true" network daemon error handler
used universally, sanely, by everything on linux. Anyone got one?

I keep thinking that having my own ring buffer in front of every
possible syscall that can mess up and a giant state machine for all the
ways things can mess up and be recovered from is the right answer.

... and then I take drugs to blot it all out.

## Track timing out on compute or error intensive tasks

If you have no sleep calls in your daemon, you can now use the ancient
"alarm" call to signal your application that you've unexpectedly (like,
while, doing too much error processing) taken too much time to process
the data you need to process within your deadline, and then do something
about it.

I first used this technique back in the 80s, and it has apparently
fallen into disuse.

Tom Duff's "first law of systems programming" - never check for an error
condition you don't know how to handle, is cynical, but applies. On the
other hand, at least logging that error condition is very helpful while
you come up with how to handle that error condition.

## Netlink deserialization

Nearly every daemon I've looked at multiplexes all the netlink multicast
data sources into one, and then bundles them into a single socket. If
you care about certain events more than others, this strikes me as the
wrong idea, because it causes head of line blocking - and you should
instead, listen on one socket per event type and prioritize them via
your own select call.

(which you can fix using the BPF trick)

Does this buy anything? I'm not sure. I'd have to log a few million
state machine interactions to find out.

## State machine modifications

Construct a kernel state machine that explains every possible transition
then we could really get somewhere. *someone* coping with the need for
highly reliable network daemon code in linux must have already done
this. Haven't they?

## Compilation tricks

Most folk working on low end routers tend to compile their daemons with
-Os to reduce space on flash and space in memory. Nowadays, we don't
care about flash or memory as much as we used to, and serious benefits
can be had by compiling code that need to run fast and all the time
(like routing daemons) at higher optimization levels. Sure - busybox
probably doesn't need -O3!

But ensuring correct compilation with -O3 is helpful, and most routing
daemons are very small compared to modern-day code-bases. For example
babeld grows from 60k to 110k in size, but it seems to be much faster.
I've also made babeld compile as "one big program", and the compiler has
found multiple other optimization opportunities there, shrinking the
binary size by a few k while also inlining some things that benefited
from being inlined.

## Adding comparisons for (in)equality rather than memcmp

Much of the code I've looked at bottlenecks on memcmp.

memcmp is usually an efficient library call for values larger than, say,
32 bytes - but can much better be done inline on smaller values, on
constant size bitstrings, particularly on arches with 64 or 128 bit
support.

Furthermore, in like 85% of cases, memcmp is used as a simple
substitute for measuring equality or inequality, e.g. :

````
if(memcmp(a,b,16) == 0) { do something }
````

and is not used for all the extra work memcmp does for "greater or less
than". Mere (in)equality can be much faster performed by a sequence of
xors and ors. Inequality is actually one operation less than equality!
It looks like this, on a 32 bit architecture:

and it takes constant time where the memcmp code takes a branch on every
word.

You can do this test.

There was - in the 80s - a much more efficient library and often in-line call -
[bcmp](http://man7.org/linux/man-pages/man3/bcmp.3.html) - for precisely
this sort of comparison, but it was deprecated by POSIX.1-2008, because,
I guess, the compiler guys thought we'd always do memcmp right in the
case of constants, and thus far, in my explorations - it doesn't.

Similarly memset tends to perform badly on 8 and 16 byte quantities.
[bzero](http://man7.org/linux/man-pages/man3/bzero.3.html) - again, an
old, now obsolete, call - did exactly what we wanted here - and is also
deprecated. And even then, although most libraries still have these,
they don't use the co-processor registers by default. Although the
compiler does seem to do the basic things need for natural small
quantities (risc architectures have a "zero" register so it just writes
that), I do think it can do better, persisently, for 16.

Anyway:

Assuming you already have one SSE or NEON register all zeroed you can
write 4,8,12, or 16 bytes in a single instruction. You can get zeros (or
ones), in one instruction. (you can get ones by comparing any register
with itself, or zeros by xoring any register with itself. If you don't
already know these things in your gut, please spend a few hours reading
[Bit twiddling hacks](FIXME) or put a copy of "Hackers Delight" on your
shelf)

The aarch64 NEON can write 32 bytes in a single ST4 instruction. With 4
64bit (not 2 128 bit, and I have no idea why) registers all pre-zeroed -
32 free zeros! The *largest* structure in babel is 64 bytes...

It seems plausible, in the case of getting good register-ization to
achieve a set of of combining wins, but mere individual optimizations
like the above may well turn out to be a lose.

I am not a huge believer in micro-benchmarks - but overall, using the
128 bit side of a processor generates less total instructions and bytes
in the input stream. It might stall more often, but if the processor is
also bottlenecked on dma, or memory loads futher down the pipeline, it
remains a potential win, and I hope, that 128 bit stuff correctly
sprinkled through the code will end up being a consistent win, reducing
register pressure, and so on.

That said, actually doing all the work, then measuring, is backwards
from how people want to work, and vectorization takes time to think
about and hurts arches that don't have these co-processors (primarily
mips).

I'm actually sufficiently annoyed at the ABI to use up a whole NEON
register permanently for zeros, to save a clock cycle. and half of one,
for ones. My v4mapped check just became a vcombine instruction, loading
ones and zeros from these two registers in 16 bit mode each. Instead of
a single non-callee saved register. I'm mad about losing the clock, I am!

## Qsort

Babeld currently calls qsort exactly once. Arguably, it needs to do it 3
times, maybe 5 times, total, or (IMHO preferably) sort two different
ways on an insert - but I found myself deep in alternative sorting
algorithms and didn't get around to fixing the actual problem.

The C++ std::sort - because it relies on on strong typing - can
frequently outperform C qsort. There are some hairy C preprocessor
driven versions of qsort that I'm tempted to try... and I want to leave
all this stuff in registers all the time which inlining will ensure -
but I'm not actually sure that any of the base comparisons or sorts are
actually the best choice for searching large tables of ipv6 values!

A btree, or trie might be better. Or a skip list... or a red-black
tree - or... I really don't know! I feel compelled to fit bits into the
pointer (cause there's four extra), but am trying to restrain the
urge...

What if I load a whole bunch of ipv6 values at a time into registers,
bulk compare and do a table lookup on the result? Etc....

That said, I did make a major improvement in the NEON version of the
code by forcing the base part of the comparison always into a [neon
register and keeping it there](FIXME):

````
#ifdef HAVE_NEON
struct xroute *
find_xroute(const unsigned char *prefix, unsigned char plen,
            const unsigned char *src_prefix, unsigned char src_plen)
{
    int i;
    // FIXME: My grumpy evaluation of the NEON CSE generated code
    // is that we end up reloading the relatively static
    // prefix and src_prefix every time into registers.
    // We can also put a prefetch here, and both ways might help.
    // So this version also keeps more work in the neon unit
    // by using the local orr of the two vars, and the
    // compiler smartly reschedules around the load and
    // skips the NEON compare and save entirely if plen or src_plen
    // Smart compiler!

     uint32x4_t up1 = vld1q_u32((const unsigned int *) prefix);
     uint32x4_t up2 = vld1q_u32((const unsigned int *) src_prefix);

    for(i = 0; i < numxroutes; i++) {
        __builtin_prefetch(&xroutes[i+1].prefix,0,2);
        uint32x4_t p1 = vld1q_u32((const unsigned int *) &xroutes[i].prefix);
        uint32x4_t p2 = vld1q_u32((const unsigned int *) &xroutes[i].src_prefix);
        if(xroutes[i].plen == plen &&
                xroutes[i].src_plen == src_plen &&
                !is_not_zero(vorrq_u32(veorq_u32(p2,up2),veorq_u32(p1,up1))))
            return &xroutes[i];
    }
    return NULL;
}

````

(At least, it moved the measured bottleneck somewhere else, and later on
realized that the last "or" could be removed for a 64 bit arch. I saved
a clock in the core loop! Joy! Rapture! People used to make their livings with
optimizations like this... and this could be *easily* unrolled)

And the src_prefix and prefix are right next to each other in the
vld4 - if you want to use 64 bit registers....

I am mostly thinking about "the right way" to do it as a circuit, not as
C code, and that sometimes gets in the way. One idea I'm contemplating
is using "popcount" as an essential seed to the top level portion of a
hash-like starting structure (this op is nearly free on SSE and NEON
architectures), perhaps leveraged against the length of the mask.

One of the things I really love about red/black trees is that [massively
parallel implementations are possible](http://ac.els-cdn.com/S0304397500002875/1-s2.0-S0304397500002875-main.pdf?_tid=5f608c2c-03b4-11e7-99d6-00000aab0f6c&acdnat=1488946068_f7a2601a8c99d3f62a122f1b107ceb19).

And lookie, here, a parallella and a bunch of FPGAs lying here,
unused...


## Alignment

In general, processors like aligned data more than unaligned data. A
little padding here and there and aligning up stuff seemed to help.

which leaves a gaping 3 or 7 byte "hole" in the struct on 32 bit or 64 architectures.

finding alternate representations of greater than and less then

## Embracing 64-bitness

64 bit is the way of x86-land and arm is soon to follow. My primary arm
development box has become the odroid C2, which (aside from the ancient
kernel) is really quite fun to work with.

Take the above inequality operation and do it in 64 bits instead. It
comes to 5 operations and branch in the core of the loop, instead of 11.

a = bottom 64 bits
b = top 64 bits

c = load 64 bits
d = load 64 bits

c = a xor c
d = b xor d
e = c or d

if(e==0) they are equal.

with 128 chocolately bitness, this is *3* operations - except that you have to
work to get the branch value back to where you can deal with it in the
main ALU, and that is expensive, unless you have a lot of operations.

I counted, 12 potentially register to register comparisons in the core babel
code loop, so if all of those can be expressed as pure boolean operations it
seems like a win (particularly with the 8 stage pipeline)

### Aside - the double xor trick

This brings me to one of my all time favorite xor tricks - you can get
back the original value you started with with another xor against the
original value. I don't think it's as
[obvious as the xor swap](https://en.wikipedia.org/wiki/XOR_swap_algorithm)
(although it is the same thing) to do this to very large values...

You can "bring back" the original data by re-xoring the resulting
data with the other variable. To extend on the above example:

````

a = bottom 64 bits
b = top 64 bits

c = load 64 bits
d = load 64 bits

c = a xor c
d = b xor d
e = c or d

if(e==0) they are equal, do something

// double xor trick: get back your original values without reloading

c = a xor c
d = b xor d

... do more stuff...

````

It's still more efficient, if you have registers to spare, and a 3 op
arch like the NEON, to just keep c and d around as their original
values, but, it's a cool trick and saves a register at the cost of two
clocks you are not going to use anyway.

The SSE and the x86 instruction set, in particular, are two op - the
dest register is always clobbered, and you only have two operands. You
*need* this trick there! If you are doing this 4 word compare on a 32
bit arch you can restore your state with 4 words back again... without a load!

I have no idea, if, over the years, this trick has actually made it into
any compilers, but I've used it a lot, and it works well in circuits
where you don't have a place to store (delay) the value at that point in
time, so you just regenerate it later on in the chain. It's also used in
what's called a
[XOR linked list](https://en.wikipedia.org/wiki/XOR_linked_list)....
(hmm... maybe I could use that... for something)

## Calling convention changes

## Net Benefits

I honestly don't know the ultimate benefit of making all these changes,
aside from the fact they will be synergetic. *Usually* after doing these
sorts of optimizations I've been able to speed up code by over 40%.

Sometimes I've won really big, even by Amdahl's law, and since the
collapse of Denard scaling I keep hoping that the kinds of low level
optimizations I know how to make in my gut will come back in vogue.

The choice of these optimizations also influences the form of future
algorithmic optimizations, and vice versa. Still, better algorithms are
generally the sources of huge wins, far more so than low level ops that
I've discussed me so far.

... if only the memcmp and friends usage didn't offend me so much.

## BPF support

## parallel netlink

## Coping with link down events

On a link down event - the linux kernel overhelpfully flushes all the
routes for you.

These are rare but the results, catastrophic. Thankfully newer linux
kernels support the IPv6 "noprefixroute" option which separates the
address assignment from the route assignments.

Still, I wish there was a "let my daemon do the routing" mode.

Perhaps a better approach would be to keep 2 or 3 routes for every
destination in the kernel tables. I'm well aware that introduces ANOTHER
state machine and 3 times more memory usage and a bit more lookup
overhead in the kernel...

but: "Nuke it from orbit. it's the only way to be sure."

## Epoll

Epoll exists for a set of reasons. Whether those reasons apply to
netlink and udp facing code is up for thought.

## API change for vectorizing ipv6 values

Nearly every piece of code I've seen for ipv6 treats it as a 16 byte
string of bytes. Modern arm and x86_64 processors and their C calling
conventions allow for passing structures of even this size in registers,
and both gcc and llvm have ABI support for passing really big stuff up
and down the software stack in their 128 bit registers, rather than on
the stack.

But they don't like "strings of bytes" for that. They do like - vectors.

Vectors have been a standard extension to the c compiler since the late
90s - although they were often implemented significantly differently and
often had strange restrictions - and were - usually - targeted at
offloading small integer (8-16 byte) or floating point computations. But
those registers are still 128 bits wide... so you can actually treat ipv6
addresses as vectors and keep them inside the processor.

My world has devolved to two compilers (gcc and llvm) that treat vectors
almost exactly the same.

I'm exploring how to do this idea well in the [libv6](fixme) repository
for (primarily) the arm neon instruction set which is nicely 3 op and
far more symmetrical than SSE2 is. I have high hopes that by keeping
essential ipv6 constants in registers and passing route related values
within registers always, that a dramatic speedup can be obtained.

The way you deal with vectors is different from how you deal with it as
a string of bytes, but you can cover up that difference with a union,
thusly:

so in this form, what used to be an

address[11];

address.c[11];

when you want to treat it as bytes

and address.usimd when you want to treat it as a vector. You have to be
*VERY* careful while flipping between these two representations. Worse,
you have to use that union only when flipping between these
representations, if you declare a function that takes that union, the
compiler has no idea what regs to pass it in!

That said, vectorization is hard, big-bit-endian is turning out harder,
128 bit shifts, SSE does really badly - and every time I turn around
I've found some strange limitation in the aarch64 compiler or ABI that
is maddening. Most recently I found that - after I tossed several
essential 128 bit constants like a v4mapped prefix check into dedicated
registers, thusly:

register usimd v4_prefix asm ("q15");

that the aarch64 ABI only requires that the bottom half of
those registers be preserved across a function call.

Now... *I* compile my own libc every few hours and can fix this, but
cannot trust the rest of the world to follow my lead.

## Algorithmic improvements

Despite my delight in talking about all these neat bit-twiddling hacks
dating back to the original HAKMEM memo and immortalized in the
bit-comparisons web page and the book "hackers delight" - which should
be on every geek's shelf, right next to all of Knuths work -

There really is no substitute for better algorithms themselves.

After doing all the optimization work to rabel that I described -
killing memcmp with xor tricks, moving things to neon regs,


Referred.

Naive set difference.

Now: I'd have not found that problem had I not gone and optimized the
heck out of rabeld - all I could see from profiling via the (awesome)
linux "perf" tool was the complete bottleneck on memcmp and some "noise"
from the core routines calling it.

Which leads to a whole other problem as to the most efficient sorting
and searching algorithms for ipv6 routes, and I don't know the answers
to that... but at some point, soon, I'll try applying the double sort on
the way in, come up with some sort of tagging (popcount?) or hashing
algorithm, or something to make that portion of the code integrally and
algorithmically faster. After I get done the fun with the bit twiddling
tricks!

## Metric sharing

Let's say you get a 1000 routes from somewhere that are constant.

They are all *always* going to have the same metric. Instead of carrying
the metric individually with each route, they can be merged and then
computed once.

This does involve some hairy merging code and garbage collection that
might yield to a RCU derived technique, but solving the nexthop metrics
once per group of routes - rather than 2000 times - seems to be a win.

## CPU bloat

## Protocol Bloat

## BPF filtering

## Co-processor support & FPGAs

A lot of products out there have a "route co-processor" that runs along
side the main packet forwarding engine. Some are offloading the route
calculations entirely (in the bgp case) to another box - and just
dumping the most frequently used routes into the CAM memories of the
switches, punting the misses to the "smarter" box that can handle the
exceptional cases.

My naive anticipation before tackling the rabeld work was that the code
which is both computationally intense - and potentially - "embarrasingly
parallel".

Embarrassingly parallel problems yield to FPGA implementations - and it
just so happens I have several of these, with more on the way.

I like, very much, the idea of a offloaded route processor completing
its work in constant time and not costing the forwarding engine any
cycles.

In addition to exploring

FPGA

might yield to tossing to another thread - or a coprocessor

## Hardware offloads in general

## Now t

that you have efficient data structures, algorithms, code, and so on...
your application is STILL going to fail at some point if it gets overloaded?

Something that used to crash in 3k routes, now crashes in 5k routes.

Get to 60k routes

And lest you think that's a lot, with babel's current data structures
that's only 6.4MB of ram per node....

what are you going to do on actual overload? How do you correctly best
shed load?

You. still. have. to. shed. load. somehow. Which loads do you shed? in
order of priority, hellos/ihus have got to always go out in under X
seconds. Route updates can be spread out in time. Default routes have
got to stay out, the best choices for routes to drop due to lack of
space are the ones you aren't using.

The LRU ones.

A dirty little secret of most routing protocols (not all, see [reactive
routing](http://www.olsr.org/docs/report_html/node16.html) for another
approach) is that they try to retain the total state of connectivity to
every possible destination - and most of the time, you don't care about
most of those.

But there's no way to find the LRU routes in the existing linux kernel.
As no counters are defined for traffic through routes, you are stuck,
unless you try to write something that works within the BPF tracing
subsystem (which I'm rather inclined to do, actually)

long tail

I haven't been watching the lit for BGP offloads closely, but I think
that maybe using a bloom filter to retain the routes you are no longer
preserving might be part of an answer. Or that tossing stuff to
userspace that you are not "currently willing to route", would be best.

"circuit breakers"

and my interests co-incide with applying the same technques we've been
applying to packet processing and queue depth - to routing daemons.

And finally, obscurely, I'm back at chasing the same problems I've been
chasing for years with packet processing, with protocol processing.

What I hope I've come up with is a rational distributed algorithm for
dropping routes while preserving connectivity, but the answer is too
long to fit into the margins of this blog, and will require
restructuring things even more than I've already described than to take
all these bit twiddling tricks.

## Conclusion

I love concluding mysteriously.
