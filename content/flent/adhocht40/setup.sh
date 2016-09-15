#!/bin/sh

C="lite-1 lite-2 lite-3 m2-1"

# Prepare to test

for i in $C
do
	ssh root@$i 'ifdown lan; exit;' &
done
wait
sleep 16
ip route
