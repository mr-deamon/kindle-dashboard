#!/bin/bash

# This file is executed on a Kindle. It should check for a online-version of the config-file and download it. If this fails, simply continue with the local version. Then it runs some initialize-configurations to disable the screensaver and the power management, disable pillow, enable powersave and stop the framework and webreader. Then it checks if the device is connected to the internet and if so, it downloads the dashboard and displays it. If the device is not connected to the internet, it displays a error-image. After that, it waits for a certain amount of time and then starts the whole process again.
# If the battery is low, it displays a low-battery-image and waits for the battery to be charged. If the battery is charged, it starts the whole process again. If the charger is connected, it does not go to deepsleep and refreshes the dashboard every 30 seconds.


# Set the DEBUG-variable to true to enable debugging
DEBUG=${DEBUG:-false}
[ "$DEBUG" = true ] && set -x

# Set the DIR-variable to the directory of this file
DIR="$(dirname "$0")"

# Set the remote config-file url
REMOTE_CONFIG_URL="https://raw.githubusercontent.com/andreasgrill/kindle-dashboard/master/config.sh"

# download and execute the remote config-file
if wget -q -O /tmp/config.sh $REMOTE_CONFIG_URL; then
  . /tmp/config.sh
fi

# execute the local config-file
. $DIR/defaults.sh

# download sleep-picture if variable starts with http
if [[ $DASH_SLEEP_URL == http* ]]; then
  wget -q -O $DASH_SLEEP_PNG $DASH_SLEEP_URL
fi

# download battery-picture if variable starts with http
if [[ $DASH_BATTERY_URL == http* ]]; then
  wget -q -O $DASH_BATTERY_PNG $DASH_BATTERY_URL
fi

# initialize the kindle
    /etc/init.d/framework stop >/dev/null 2>&1
    /etc/init.d/cmd stop >/dev/null 2>&1
    /etc/init.d/phd stop >/dev/null 2>&1
    /etc/init.d/volumd stop >/dev/null 2>&1
    /etc/init.d/tmd stop >/dev/null 2>&1
    /etc/init.d/webreader stop >/dev/null 2>&1
    killall lipc-wait-event >/dev/null 2>&1
    mkdir /mnt/us/update.bin.tmp.partial -f # prevent from Amazon updates
    touch /mnt/us/WIFI_NO_NET_PROBE         # do not perform a WLAN test
    echo powersave > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    lipc-set-prop com.lab126.powerd preventScreenSaver 1
    lipc-set-prop com.lab126.pillow disableEnablePillow disable

