#!/usr/bin/env bash

dmenu () {
    choice=$(printf "Lock\nLogout\nSuspend\nReboot\nShutdown" | rofi -dmenu -i) # case insensitive
    if [[ $choice == "Lock" ]];then
        lock
    elif [[ $choice == "Logout" ]];then
        pkill -KILL -u "$USER"
    elif [[ $choice == "Suspend" ]];then
        lock && sleep 2 && systemctl suspend
    elif [[ $choice == "Reboot" ]];then
        systemctl reboot
    elif [[ $choice == "Shutdown" ]];then
        systemctl poweroff
    fi
} 

lock () {
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
	    -f
}

case $1 in # $1 is the first argument passed to the script
    "") # if no argument is passed to the script then run dmenu
        dmenu
        ;;
    lock)
        lock
        ;;
esac