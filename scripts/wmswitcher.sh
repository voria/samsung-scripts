#!/bin/sh
# script by Fortunato Ventre (voRia) - http://www.voria.org - vorione@gmail.com
#
# "Switch between Metacity and Compiz window managers"
#

# we assume metacity is not in use
METACITY_IN_USE=0
for pid in `pidof metacity`; do
    if ps ux | grep $pid | grep -v grep > /dev/null; then # check if the current metacity process is ours
        METACITY_IN_USE=1
        break
    fi
done

if [ $METACITY_IN_USE -eq 1 ]; then
	compiz --replace > /dev/null 2>&1 &
else
	metacity --replace > /dev/null 2>&1 &
fi
exit 0
