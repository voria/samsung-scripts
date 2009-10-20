#!/bin/sh
# script by Fortunato Ventre (voRia) - http://www.voria.org - vorione@gmail.com
# based on script by Andrea Cimitan
# refactoring by Stuart Herbert (stuart@stuartherbert.com)
#
# "enable/disable screen backlight"
#

# temp file
BLOFF=/tmp/bloff

disableBacklight ()
{
	mustBeRoot
	vbetool dpms off
	touch $BLOFF
}

enableBacklight ()
{
	mustBeRoot
	vbetool dpms on
	rm -f $BLOFF
}

isBacklightOn ()
{
	if [ -f $BLOFF ]; then
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
