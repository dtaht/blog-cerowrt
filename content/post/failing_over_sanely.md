+++
date = "2016-09-08T10:02:58+01:00"
draft = true
tags = [ "babel", "lab", "routing", "wifi" ]
title = "Routing wifi right is hard"
description = ""
+++

What happens if you set up a topology like this?

<pre>
           S1
	   | 
A ------ B-|
+   \/     |
+   /\	   |
C ------ D-|
	   |  
           S2
</pre>

A,B,C,D can all reach each other over wifi.  S1 and S2 can both get to B and D at equal cost because they are on a switch.

## A couple rules of thumb

### More transmitters = more interference

### Route flaps are bad

## What can go wrong?

## ARP delay

### Lost or out of order packets

### non-atomic del-add for the new route

### Triangular routing

### Minstrel underrun

### Codel overrun

## What should happen?

I haven't got the faintest clue what will happen. But I'll enjoy
getting data on it.
