#!/bin/bash
# script by Fortunato Ventre - http://www.voria.org - vorione@gmail.com
#
# "switch screen's layouts created with arandr"
#

case $LANG in
	it*)
		POPUP_TITLE="Uscita VGA"
		POPUP_BODY="Compiz è attivo. Per favore disabilitalo prima di attivare l'uscita VGA".
		;;
	*)
		POPUP_TITLE="VGA Output"
		POPUP_BODY="Compiz is enabled. Please disable it prior to enable the VGA output."
		;;
esac

if ps x | grep compiz.real | grep -v grep > /dev/null; then
	if which notify-send > /dev/null; then
		notify-send -u critical -i info "$POPUP_TITLE" "$POPUP_BODY"
	fi
	# Compiz is running. Do nothing in order to avoid to trigger bug LP:#419328.
	exit 0
fi

LAYOUTS_DIR="$HOME/.screenlayout"

if [ ! -d $LAYOUTS_DIR ]; then
	# Layouts directory does not exist, start arandr
	exec arandr
fi

cd $LAYOUTS_DIR

# Get a list of all the scripts in $LAYOUTS_DIR directory
SCRIPTS_LIST=(`ls -1 $LAYOUTS_DIR`)
# Count the scripts inside the $LAYOUTS_DIR directory
SCRIPTS_COUNT=`ls -1 $LAYOUTS_DIR | wc -l`

if [ $SCRIPTS_COUNT -eq 0 ]; then
	# No scripts found, start arandr
	exec arandr
fi

COUNTFILE=/tmp/screenlayout_count.$USER
COUNT=`cat $COUNTFILE 2>/dev/null`

# Increment counter to the next script
COUNT=$(expr $(expr $COUNT + 1) % $SCRIPTS_COUNT)
echo $COUNT > $COUNTFILE

# Launch the new script
exec ./${SCRIPTS_LIST[$COUNT]}
