#!/bin/sh
# script by Fortunato Ventre (voRia) - http://www.voria.org - vorione@gmail.com
# based on script by Andrea Cimitan
# refactoring by Stuart Herbert (stuart@stuartherbert.com)
#
# "enable/disable screen backlight"
#

# temp file
BRIGHTNESS=/tmp/lcdonoff-brightness
XBL_OPTIONS="-time 100 -steps 5"
BL_LEVEL=`xbacklight -get`

disableBacklight ()
{
	# save backlight level
	echo $BL_LEVEL > $BRIGHTNESS
	# disable screen backlight
	xbacklight $XBL_OPTIONS -set 1
	xset dpms force off
}

enableBacklight ()
{
	# restore screen backlight and remove temp file
	if [ -f $BRIGHTNESS ]; then
		xbacklight $XBL_OPTIONS -set `cat $BRIGHTNESS`
		rm -f $BRIGHTNESS
	else
		xbacklight $XBL_OPTIONS -set 50
	fi
	xset dpms force on
}

isBacklightOn ()
{
	if [ `echo $BL_LEVEL | cut -c 1` = "0" ]; then
		return 1
	else
		return 0
	fi
}

showSummary ()
{
	echo "on|off - no params will toggle"
}

toggleBacklight ()
{
	if isBacklightOn ; then
		disableBacklight
	else
		enableBacklight
	fi
}

main ()
{
	case "$1" in
		on)
			enableBacklight
			;;
		off)
			disableBacklight
			;;
		help|--help?-h|-?)
			showHelp lcd
			;;
		summary)
			showSummary
			;;
		*)
			toggleBacklight
			;;
	esac
}

main "$@"
