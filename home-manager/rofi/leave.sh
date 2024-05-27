#!/usr/bin/env bash

choice=$(printf "Lock\nLogout\nSuspend\nReboot\nShutdown" | rofi -dmenu -i) # case insensitive
if [[ $choice == "Lock" ]];then
    swaylock --image "$HOME/Pictures/village.jpg" \
	    --clock \
            --indicator \
            --indicator-radius 100 \
            --indicator-thickness 7 \
            --effect-blur 7x5 \
            --effect-vignette 0.5:0.5 \
            --ring-color 192330 \
            --key-hl-color 9d79d6 \
            --line-color 000000 \
            --inside-color c94f6d \
            --separator-color 000000 \
            --grace 3 \
            --fade-in 0.5 
elif [[ $choice == "Logout" ]];then
    pkill -KILL -u "$USER"
elif [[ $choice == "Suspend" ]];then
    swaylock --image "$HOME/Pictures/village.jpg" \
	    --clock \
            --indicator \
            --indicator-radius 100 \
            --indicator-thickness 7 \
            --effect-blur 7x5 \
            --effect-vignette 0.5:0.5 \
            --ring-color 192330 \
            --key-hl-color 9d79d6 \
            --line-color 000000 \
            --inside-color c94f6d \
            --separator-color 000000 \
            --grace 3 \
            --fade-in 0.5 \
	    -f && sleep 2 && systemctl suspend
elif [[ $choice == "Reboot" ]];then
    systemctl reboot
elif [[ $choice == "Shutdown" ]];then
    systemctl poweroff
fi
