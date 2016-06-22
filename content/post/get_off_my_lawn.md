+++
date = "2016-04-24T22:02:58+01:00"
draft = true
tags = [ "lab", "wifi", "bufferbloat" ]
title = "Some hackerboards for benchmarking networks"
description = "Cheaping out for the sake of science"
+++



On Wed, Jun 22, 2016 at 4:31 AM, Juliusz Chroboczek <jch@pps.univ-paris-diderot.fr> wrote:
>> The preinstalled OS has sufficient compiler and onboard flash space to
>> build a current babeld from git, and I'm happy to report IPV6_SUBTREES
>> is compiled in by default.
>
> Dave,
>
> It's not the first time that I notice with wonder that you're compiling on
> the devel boards.  Are you aware that cross-compiling babeld to armhf is
> so easy it's not even funny?
>
>   sudo apt-get install gcc-arm-linux-gnueabihf
>   make CC=arm-linux-gnueabihf-gcc

I have a tendency to need to compile things vastly more complex than babel, often more bleeding edge than what is supplied in a repo, and *knowing* that an apt-get build-dep something; then checking it out from git, will actually work with minimal effort, is a joy.

The short answer is: "You kids, get off my lawn!" :)

...

This thread spawned a string of remembrances about how we got to where we are are today. TL;DR:

* In 1990, when I was working for the (pre-evil) SCO, it took 3 days to compile a kernel. The build broke so much that we were lucky to get something that booted to a prompt in under a month. Even after you got to a stable kernel, you still had to somehow distribute the OS, and as I recall, the open desktop distribution (which included X and ingress), had to go out on about 140 floppies - no "network install" was possible - the odds of one of those floppies failing were significant.

to me, the only thing that kept the company's stuff useful for devs was "SCO skunkware"

* In 1993 - when working for interbase (which had got bought by borland) - I had to port a test suite to 9 different architectures, 8 different variants of unix, and 3 very majorly different versions of C, with code that had been originally written in pre-ansi C for the apollo workstations (that had their own pre-plan 9 sets of I/O innovations in particular). The authors had thought that using "$" symbols in identifiers was a good things, there were no prototypes, and the underlying OSes ranged from stuff that was v3 based to bsd based... to OS/2 and windows and Vax. People there thought "Xenix" was a toy OS, compared to the big sequents in the back room. People still thought that SYSV - and that the OSI network stack would triumph.

After hitting more issues with that test suite and the OEM compilers than I care to remember, I discovered it was easier to port (or leverage a port to) gcc to the most troublesome systems, and a whole bunch of gnu libraries, then get interbase to run on top of this, than port the test suite

as you might imagine, running gcc... at borland... at the time... did not go down very well with management.

* In 1998 DEC set up a whole bunch of "itsy" arm boxes in the cloud, with a shared nfs filesystem, and offered ssh accounts to anyone that wanted to port packages to it. It took days to build X11, as I recall, and the origin of the ipk format came from that as we had, at best, 16MB of flash to deal with to make something that worked, and every bit of fat had to be trimmed from the code and the packaging, starting with the man pages, and extending out to arbitrary allocations of malloc(1024*1024); There were huge debates over

* Given the performance disparity between cross compilation *then*, a whole bunch of companies were founded to build distros that cross compiled. Work was needed across all the compilers

One of the "inheritances" from that period was the carry of the single system image (SSI) model from earlier embedded efforts
where you had to build everything, every week, because of all the compiler bugs still being fixed, the ABI breakage, and the lack of co-operation between manufacturers and OS shops in the first place.

*

2005-2008 - I spent *years* trying to get the custom FPU in the ep9302 to work at all. It wasn't until 2 years after the product was killed by the manufacturer that a viable toolchain appeared.

*

So while I applaud the work linaro in particular has completed (which took 5 years) - of unifying the toolchains, stablizing the ABIs, and (especially) unifying the arm kernels - and the gang that - in 3 months - made armhf possible on the raspi 4 years or so ago - and overturned an industry that had almost, but not quite, finally converged on the EABI...

Ending up with the arm ecosystem that we have today - where I can get 5 boards from different manufacturers, with one or more cores - with a C compiler with only minor differences between them - with

is still a wonderment to me.

Mips is still not like that. PPC isn't either.

> Shncpd is a little bit trickier, since it depends on libbsd.  I think I'll
> remove the dependency before relase, but in the meantime you may either
> build yourself an armhf libbsd, or install libbsd0:armhf on your system
> (which requires setting up a multiarch environment), or set up
> a cross-compilation chroot, or simply copy libbsd.so from the target system.

My point, exactly. Get off my lawn!!! :)

>
> -- Juliusz
