+++
date = "2016-04-06T18:02:58+01:00"
draft = false
tags = [ "notes" ]
title = "Math is maddening in html"
description = "Mathjax is helpful, latex is no fun"
+++

Doing math well in email or on the web rarely happens. The best solution
is mathjax, for which I just added support on this website. I will
probably revise it some as we go along, but it is a relief to be able to
type in an equation and have it show up like this:

When $a \ne 0$, there are two solutions to \(ax^2 + bx + c = 0\) and they are
$$x = {-b \pm \sqrt{b^2-4ac} \over 2a}.$$

I wish more programming languages had full support for representing
things in the code as how they look in the math, everything from != (
$\ne $), to classic symbols like omega, beta, theta and so on ($ \omega,
\beta, \theta $ ), I think it would lead to a LOT fewer programming
errors in translating algorithms from math to code - and if more coders
read the math we'd all be better off.

Still, relying on mathjax is a crutch, in those basic cases, as UTF-8
support exists for all the basic symbols (&#937;) which is simpler to
use, and [easily referenced from web resources online](http://www.fileformat.info/info/unicode/char/03a9/index.htm). I suspect I will
use the UTF-8 codes for the simple stuff and only lean on mathjax for
complicated equations.
