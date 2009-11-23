#!/bin/sh
# script by Fortunato Ventre (voRia) - http://www.voria.org - vorione@gmail.com
# refactored by Stuart Herbert (stuart@stuartherbert.com)
#
# "Toggle bluetooth on/off on Samsung NC10"

case $LOCALE in
	de*)
		POPUP_TITLE="Bluetooth"
		BT_ON="Bluetooth eingeschaltet"
		BT_OFF="Bluetooth ausgeschaltet"
		;;
	fr*)
		POPUP_TITLE="Bluetooth"
		BT_ON="Bluetooth activé"
		BT_OFF="Bluetooth désactivé"
		;;
	it*)
		POPUP_TITLE="Bluetooth"
		BT_ON="Bluetooth attivato"
		BT_OFF="Bluetooth disattivato"
		;;
	pl*)
		POPUP_TITLE="Bluetooth"
		BT_ON="Bluetooth włączony"
		BT_OFF="Bluetooth wyłączony"
		;;
	tr*)
		POPUP_TITLE="Mavidiş"
		BT_ON="Mavidiş etkin"
		BT_OFF="Mavidiş devre dışı"
		;;
	*)
		POPUP_TITLE="Bluetooth"
		BT_ON="Bluetooth enabled"
		BT_OFF="Bluetooth disabled"
		;;
esac

ICON=bluetooth

disableBluetooth ()
{
	mustBeRoot
	hciconfig hci0 down
	modprobe -r $BLUETOOTH_MODULE
	# Save status
	if [ -n $BLUETOOTH_STATUS ]; then
		echo -n 0 > $BLUETOOTH_STATUS
	fi
}

enableBluetooth ()
{
	mustBeRoot
	modprobe $BLUETOOTH_MODULE
	hciconfig hci0 up
	# Save status
	if [ -n $BLUETOOTH_STATUS ]; then
		echo -n 1 > $BLUETOOTH_STATUS
	fi
	# Set device autosuspend
	if [ -n $BLUETOOTH_AUTOSUSPEND_PATH ]; then
		echo auto > $BLUETOOTH_AUTOSUSPEND_PATH
	fi
}

isBluetoothEnabled ()
{
	if lsmod | grep $BLUETOOTH_MODULE > /dev/null ; then
		return 0
	else
		return 1
	fi
}

toggleBluetooth ()
{
	if isBluetoothEnabled ; then
		disableBluetooth
	else
		enableBluetooth
	fi
	showStatus
}

showStatus ()
{
	if isBluetoothEnabled ; then
		showPopup $ICON critical "$POPUP_TITLE" "$BT_ON"
	else
		showPopup $ICON critical "$POPUP_TITLE" "$BT_OFF"
	fi
}

showSummary ()
{
	echo 'on|off|status - no params will toggle'
}

main ()
{
	case "$1" in
		on)
			enableBluetooth
			showStatus
			;;
		off)
			disableBluetooth
			showStatus
			;;
		help|--help|-h|-?)
			showHelp bluetooth
			;;
		status)
			showStatus
			;;
		summary)
			showSummary
			;;
		*)
			toggleBluetooth
			;;
	esac
}

main "$@"
