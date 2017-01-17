#!/bin/bash

#Hi, this is disgusting. Goodbye.

SLEEP_SEC=1
#loops forever outputting a line every SLEEP_SEC secs
while :; do
	eval $(awk '/^MemTotal/ {printf "MTOT=%s;", $2}; /^MemFree/ {printf "MFREE=%s;",$2}' /proc/meminfo)
	
	MUSED=$(( $MTOT - $MFREE ))
	MUSEDPT=$(( ($MUSED * 100) / $MTOT ))
	MEM_STR="Mem: ${MUSEDPT}%"
	CPU="CPU: $(mpstat -P ALL | grep all | awk '{ print (100 - $13) }')%"
	TEMP="Temp: $(acpi -tf | awk '/0:/ {print $4}')°F"
	if [  $(acpi -a | awk -F '[^A-Z^a-z]+' '{ print $2 }') = "on" ]; then
		BAT="Bat: $(acpi -b | awk -F '[^0-9]+' '{ print $3 }')% (Plugged in)"
	else
		BAT="Bat: $(acpi -b | awk -F '[^0-9]+' '{ print $3 }')% (Discharging)"
	fi
	VOL="Vol: $(amixer sget -M Master | grep "%" | sed -n 1p | awk -F '[^0-9]+' '{ print $3 }') $(amixer sget -M Master | sed -n 6p | cut -d "]" -f 2- ) "
	
	NOWPLAYING=""
	if [ $(pgrep "mpd") > /dev/null ]; then
		NOWPLAYING="| $(mpc | sed -n 2p | cut -d "[" -f2 | cut -d "]" -f1 | sed s/./P/1): $(mpc | sed -n 1p)"
	fi
	#echo -e "$POWER_STR  $TEMP_STR  $CPUFREQ_STR  $CPULOAD_STR  $MEM_STR  $WLAN_STR"
	DATE_STR=`date +"%H.%M %a %d %b"`
	echo -e "$DATE_STR | $MEM_STR | $CPU | $TEMP | $BAT | $VOL $NOWPLAYING"
 
        #alternatively if you prefer a different date format
        #DATE_STR=`date +"%H:%M %a %d %b`
	#echo -e "$DATE_STR   $POWER_STR  $TEMP_STR  $CPUFREQ_STR  $CPULOAD_STR  $MEM_STR  $WLAN_STR"

	sleep $SLEEP_SEC
done
