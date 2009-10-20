#!/bin/sh
# script by Fortunato Ventre (voRia) - http://www.voria.org - vorione@gmail.com
# refactoring by Stuart Herbert (stuart@stuartherbert.com)
#
# "Manage CPU governors and show CPU info"
#

# IGNORE_GOVERNORS: List of governors we don't want to use.
# 'ondemand' and 'performance' are supposed to be always available.
# So, they will be used even if you add them to the list.
# Example: we want to use 'ondemand' and 'performance' governors only, then:
# IGNORE_GOVERNORS="userspace powersave conservative"
IGNORE_GOVERNORS="userspace conservative"

CURRENT_GOVERNOR=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`
AVAILABLE_GOVERNORS=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors`

# remove unwanted governors
for GOVERNOR in $IGNORE_GOVERNORS; do
	AVAILABLE_GOVERNORS=`echo $AVAILABLE_GOVERNORS | sed "s/$GOVERNOR//"`
done

# determine next governor to switch to
# we assume that 'ondemand' and 'performance' governors are always available
case $CURRENT_GOVERNOR in
	userspace)
		if echo $AVAILABLE_GOVERNORS | grep powersave > /dev/null; then
			NEXT_GOVERNOR="powersave"
		else
			NEXT_GOVERNOR="ondemand"
		fi
		;;
	powersave)
		NEXT_GOVERNOR="ondemand"
		;;
	ondemand)
		if echo $AVAILABLE_GOVERNORS | grep conservative > /dev/null; then
			NEXT_GOVERNOR="conservative"
		else
			NEXT_GOVERNOR="performance"
		fi
		;;
	conservative)
		NEXT_GOVERNOR="performance"
		;;
	performance)
		if echo $AVAILABLE_GOVERNORS | grep userspace > /dev/null; then
			NEXT_GOVERNOR="userspace"
		else
			if echo $AVAILABLE_GOVERNORS | grep powersave > /dev/null; then
				NEXT_GOVERNOR="powersave"
			else
				NEXT_GOVERNOR="ondemand"
			fi
		fi
		;;
esac

# set language strings
case "$LOCALE" in
	fr*)
		popup_title="Processeur"
		cpu_temp="Température:"
		cpu_freq="Fréquence:"
		cpu_governor="Mode:"
		;;
	it*)
		popup_title="CPU"
		cpu_temp="Temperatura:"
		cpu_freq="Frequenza:"
		cpu_governor="Modalità:"
		;;
	pl*)
		popup_title="CPU"
		cpu_temp="Temperatura:"
		cpu_freq="Częstotliwość:"
		cpu_governor="Zarządca:"
		;;
	tr*)
		popup_title="İşlemci"
		cpu_temp="Sıcaklık:"
		cpu_freq="Hız:"
		cpu_governor="Yönetim:"
		governor_powersave="güç tasarrufu"
		governor_ondemand="talep üzerine"
		governor_conservative="tutumlu"
		governor_performance="tam güç"
		governor_userspace="kullanıcı tanımlı"
		;;
	*)
		popup_title="CPU"
		cpu_temp="Temperature:"
		cpu_freq="Frequency:"
		cpu_governor="Governor:"
		;;
esac

CPU0_SCAL_GOV=/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
CPU1_SCAL_GOV=/sys/devices/system/cpu/cpu1/cpufreq/scaling_governor

currentCpuFreq ()
{
	cat /proc/cpuinfo | grep MHz | head -n 1 | awk '{ print $4, $2 }' | sed -e 's|\.\([0-9]\+\)||;'
}

currentGovernor ()
{
	cat $CPU0_SCAL_GOV
}

currentGovernorIcon ()
{
	gov=`currentGovernor`
	case "$gov" in
		powersave)
			icon=25
			;;
		ondemand)
			icon=50
			;;
		conservative)
			icon=75
			;;
		performance)
			icon=100
			;;
		*)
			icon=na
			;;
	esac

	echo /usr/share/pixmaps/cpufreq-applet/cpufreq-$icon.png
}

currentTemperature ()
{
	cat /proc/acpi/thermal_zone/TZ00/temperature | awk '{ print $2, $3 }'
}

nextGovernor ()
{
	mustBeRoot
	echo $NEXT_GOVERNOR > $CPU0_SCAL_GOV
	echo $NEXT_GOVERNOR > $CPU1_SCAL_GOV
}

# this replaces the original python script
showStatus ()
{
	freq=`currentCpuFreq`
	gov=`currentGovernor`
	transGov=`translateGovernor $gov`
	icon=`currentGovernorIcon`
	temp=`currentTemperature`

	message="$cpu_temp $temp
$cpu_freq $freq
$cpu_governor $transGov"

	showPopup "$icon" critical "$popup_title" "$message"
}

showSummary ()
{
	echo "auto|status - no params will switch to next perf option"
}

translateGovernor ()
{
	gov=governor_$1
	transGov=${!gov}
	if [[ -z $transGov ]]; then
		echo $1
	fi

	echo $transGov
}

main ()
{
	case "$1" in
		help|--help|-h|-?)
			showHelp cpuperf
			;;
		auto)
			PNUM=`ps ux | grep "nc10 cpuperf auto" | grep -v grep -c`
			if [ $PNUM -gt 2 ]; then
				nextGovernor
			fi
			showStatus
			if [ $DISTRO = 1 ]; then # Kubuntu: we need to sleep some time for handling governor switch. 
				sleep 2
			fi
			;;
		status)
			showStatus
			;;
		summary)
			showSummary
			;;
		*)
			nextGovernor
			showStatus
			;;
	esac
}

main "$@"
