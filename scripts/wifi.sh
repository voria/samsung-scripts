#!/bin/sh
# script by Fortunato Ventre (voRia) - http://www.voria.org - vorione@gmail.com
# refactored by Stuart Herbert (stuart@stuartherbert.com)
#
# "Toggle wireless on/off on Samsung NC10"
#

if [ -f /etc/default/nc10-scripts ]; then
	. /etc/default/nc10-scripts
else
	# Set the default wireless module
	WIRELESS_MODULE="ath5k"
fi

case $LOCALE in
	de*)
		POPUP_TITLE="Funknetzwerk"
		WIFI_ON="Funknetzwerk eingeschaltet"
		WIFI_OFF="Funknetzwerk ausgeschaltet"
		;;
	fr*)
		POPUP_TITLE="Réseau sans fil"
		WIFI_ON="Réseau sans fil activé"
		WIFI_OFF="Réseau sans fil désactivé"
		;;
	it*)
		POPUP_TITLE="Wireless"
		WIFI_ON="Wireless attivato"
		WIFI_OFF="Wireless disattivato"
		;;
	pl*)
		POPUP_TITLE="Sieć bezprzewodowa"
		WIFI_ON="Sieć bezprzewodowa włączona"
		WIFI_OFF="Sieć bezprzewodowa wyłączona"
		;;
	tr*)
		POPUP_TITLE="Kablosuz Bağlantı"
		WIFI_ON="Kablosuz bağlantı etkin"
		WIFI_OFF="Kablosuz bağlantı devre dışı"
		;;
	*)
		POPUP_TITLE="Wireless"
		WIFI_ON="Wireless enabled"
		WIFI_OFF="Wireless disabled"
		;;
esac

ICON_CONNECTED=notification-network-wireless-none
ICON_DISCONNECTED=notification-network-wireless-disconnected 

disableWifi ()
{
	mustBeRoot
	modprobe -r $WIRELESS_MODULE
}

enableWifi ()
{
	mustBeRoot
	modprobe $WIRELESS_MODULE
}

isWifiEnabled ()
{
	if lsmod | grep $WIRELESS_MODULE > /dev/null; then
		return 0
	else
		return 1
	fi
}

showStatus ()
{
	if isWifiEnabled ; then
		showPopup $ICON_CONNECTED critical "$POPUP_TITLE" "$WIFI_ON"
	else
		showPopup $ICON_DISCONNECTED critical "$POPUP_TITLE" "$WIFI_OFF"
	fi
}

showSummary ()
{
	echo "on|off|status - no params will toggle"
}

toggleWifi ()
{
	if isWifiEnabled ; then
		disableWifi
	else
		enableWifi
	fi
}

main ()
{
	case "$1" in
		on)
			enableWifi
			showStatus
			;;
		off)
			disableWifi
			showStatus
			;;
		help|--help|-?|-h)
			showHelp wifi
			;;
		status)
			showStatus
			;;
		summary)
			showSummary
			;;
		*)
			toggleWifi
			showStatus
			;;
	esac
}

main "$@"
