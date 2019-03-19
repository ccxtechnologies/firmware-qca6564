#!/bin/sh

# reads the WLAN MAC Address from a special bootrgs passed from
# ubbot (ccx.wlanmac) and makes sure the wlan firmware has the
# propper MAC set before loading the driver

log() {
	printf "<$1>wlan-set-mac: $2\n" >/dev/kmsg
}

# Do nothing if the module is already loaded
grep -qws 'wlan' /proc/modules && exit 0

for x in $(cat /proc/cmdline); do
    [[ $x = ccx.wlanmac=* ]] || continue
   MAC_ADDR=${x#ccx.wlanmac=}
done

if [ -z "$MAC_ADDR" ]; then
	log "4" "No WiFi MAC Address passed from boot-loader"
	exit 0
else
	log "6" "Bootloader MAC Address is ${MAC_ADDR}"
fi

BIN_MAC=${MAC_ADDR//:}
BIN_MAC=$(echo "$BIN_MAC" | tr '[:lower:]' '[:upper:]')

MACFILE="/lib/firmware/wlan/wlan_mac.bin"

if grep -Fq "=$BIN_MAC" ${MACFILE}; then
	log "6" "MAC Address already set"
else
	echo "Intf0MacAddress=${BIN_MAC}" > ${MACFILE}
	log "5" "MAC Address changed to ${MAC_ADDR}"
fi

modprobe wlan
