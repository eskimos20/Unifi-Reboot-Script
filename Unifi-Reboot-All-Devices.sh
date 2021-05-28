#!/bin/bash

#This script is a remake of https://github.com/stevejenkins reboot script but modified by Daniel Lindvall.
#The script will reboot any Unifi device. Tested with USG, US-150W, US-AC-PRO.

#Syntax below is for 'IP' 'Reboot privileges' 'Reboot delay'
#First 'IP' is set on the device you want to reboot ex: 192.168.1.1 then followed by colon and 'Reboot privileges'
#'true' or 'false' depending on IF the device you want to reboot needs admin privileges, Unifi USG needs true and
#accesspoints and switches like US-150W and US-AC-PRO needs false. Then next colon and 'Reboot delay'. It is how
#long you want the code to wait until it tries to reboot next device, this can be useful if you want to
#wait for your USG to get online until we try to shutdown next device. This code waits 200 seconds for 192.168.1.1
#and 0 seconds for 192.168.1.2/192.168.1.3.



# USER-CONFIGURABLE SETTINGS
username=ubnt
password=ubnt
known_hosts_file=/dev/null

#Declare your device ips
declare -a arr=("192.168.1.1:true:200" "192.168.1.3:false:0" "192.168.1.2:false:0")

function pause(){
 sleep $1
}

for i in "${arr[@]}"
do
        IP="$(cut -d':' -f1 <<<$i)"
        TYPE="$(cut -d':' -f2 <<<$i)"
        WAIT="$(cut -d':' -f3 <<<$i)"

        printf "\n%s\n" "Checking server connectivity on ip:$IP"

        while ! nc -zw1 $IP 22 &> /dev/null
        do
                printf "\n%s\n" "No connectivity..."
                sleep 1
        done

        printf "\n%s\n" "Server is online, rebooting device at $IP..."

        if $TYPE ; then
                if sshpass -p $password ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=$known_hosts_file $username"@$IP" sudo shutdown -r now; then
                        printf "\n%s\n" "Device at $IP rebooted!"
                        printf "\n%s\n" "Waiting for $WAIT seconds.."
                        pause $WAIT
                else
                        printf "\n%s\n" "Could not reboot device $IP."
                fi
        else
                if sshpass -p $password ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=$known_hosts_file $username"@$IP" reboot; then
                        printf "\n%s\n" "Device at $IP rebooted!"
                        printf "\n%s\n" "Waiting for $WAIT seconds.."
                        pause $WAIT
                else
                        printf "\n%s\n" "Could not reboot device at $IP."
                fi
        fi

done

exit 0
