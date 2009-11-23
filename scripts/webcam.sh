#!/bin/sh
# script by Fortunato Ventre (voRia) - http://www.voria.org - vorione@gmail.com
# refactored by Stuart Herbert (stuart@stuartherbert.com)
#
# "Toggle webcam on/off on Samsung NC10"
#

case $LOCALE in
	de*)
		POPUP_TITLE="Webcam"
		WC_ON="Webcam eingeschaltet"
		WC_OFF="Webcam ausgeschaltet"
		WC_INUSE="Webcam in Benutzung.
Die Webcam kann im Moment nicht ausgeschaltet werden."
		;;
	fr*)
		POPUP_TITLE="Webcam"
		WC_ON="Webcam activée"
		WC_OFF="Webcam désactivée"
		WC_INUSE="Webcam en cours d'utilisation.
Le périphérique ne peut être désactivé pour le moment."
        ;;
	it*)
		POPUP_TITLE="Webcam"
		WC_ON="Webcam attivata"
		WC_OFF="Webcam disattivata"
		WC_INUSE="Webcam in uso.
Al momento non puo' essere disattivata."
		;;
	pl*)
		POPUP_TITLE="Webcam"
		WC_ON="Webcam włączony"
		WC_OFF="Webcam wyłączony"
		WC_INUSE="Webcam w użyciu.
Nie można wyłączyć kamery w tym momencie."
		;;
	tr*)
		POPUP_TITLE="Dahili Kamera"
		WC_ON="Kamera etkin"
		WC_OFF="Kamera devre dışı"
		WC_INUSE="Kamera kullanımda.
Şu an için devre dışı bırakılamaz."
		;;
	*)
		POPUP_TITLE="Webcam"
		WC_ON="Webcam enabled"
		WC_OFF="Webcam disabled"
		WC_INUSE="Webcam in use.
At the moment it can't be disabled."
		;;
esac

ICON=camera-web

disableWebcam ()
{
	mustBeRoot
	modprobe -r $WEBCAM_MODULE > /dev/null
	# Save status
	if [ -n $WEBCAM_STATUS ]; then
		echo -n 0 > $WEBCAM_STATUS
	fi
}

enableWebcam ()
{
	mustBeRoot
	modprobe $WEBCAM_MODULE
	# Save status
	if [ -n $WEBCAM_STATUS ]; then
		echo -n 1 > $WEBCAM_STATUS
	fi
	# Set device autosuspend
	if [ -n $WEBCAM_AUTOSUSPEND_PATH ]; then
		echo auto > $WEBCAM_AUTOSUSPEND_PATH
	fi
}

isWebcamEnabled ()
{
	if lsmod | grep $WEBCAM_MODULE > /dev/null; then
		if ! modprobe -r -n $WEBCAM_MODULE > /dev/null 2>&1; then
			# webcam is enabled, and in use!
			return 1
		else
			# webcam is not in use.
			return 0
		fi
	else
		# webcam is not enabled
		return 2
	fi
}

showStatus ()
{
	isWebcamEnabled
	case "$?" in
		0)
			showPopup $ICON critical "$POPUP_TITLE" "$WC_ON"
			;;
		1)
			showPopup $ICON critical "$POPUP_TITLE" "$WC_INUSE"
			;;
		*)
			showPopup $ICON critical "$POPUP_TITLE" "$WC_OFF"
			;;
	esac
}

showSummary ()
{
	echo "on|off|status - no params will toggle"
}

toggleWebcam ()
{
	isWebcamEnabled
	if [[ $? == 0 || $? == 1 ]] ; then
		disableWebcam
	else
		enableWebcam
	fi
}

main ()
{
	case "$1" in
		on)
			enableWebcam
			showStatus
			;;
		off)
			disableWebcam
			showStatus
			;;
		help|-h|-?|--help)
			showHelp webcam
			;;
		status)
			showStatus
			;;
		summary)
			showSummary
			;;
		*)
			toggleWebcam
			showStatus
			;;
	esac
}

main "$@"
