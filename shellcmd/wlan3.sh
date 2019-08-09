#!/bin/bash
wpa_supplicant -d -Dnl80211 -c /etc/wpa_supplicant.conf -iwlan3 -B
