#!/usr/bin/env bash


# Screenshot directory
dir="$HOME/Pictures/Screenshots"

# Filename
timestamp=`date +%Y-%m-%d-%H-%M-%S`
file="Screenshot_${timestamp}.png"

# Send a notification with a preview and Edit/Open options
# Edit opens swappy for scratchpad editing 
# Save saves it to the screenshot dir and opens the file manager
notification() {
    tempnotify='notify-send -u low --action=edit=Edit --action=save=Save --app-name Screenshot'
    wl-paste > $dir/$file
    temp=$(${tempnotify} -i  $dir/$file "Copied to clipboard.")
    rm $dir/$file
    if [ $temp = 'edit' ]; then
        wl-paste > $dir/$file
        swappy -f $dir/$file
        rm $dir/$file
    elif [ $temp = 'save' ]; then
        wl-paste > $dir/$file
        hyprctl dispatch exec '[float]' "kitty -d $dir -e zsh -c 'eza -alF --icons --color=always --hyperlink --group-directories-first -s=modified; kitty +kitten icat $file; exec zsh'"
    fi  
}

dmenu() {
    choice=$(printf "All\nWindow\nSelection" | rofi -dmenu -i)
    if [[ $choice == "All" ]];then
            delay 0
    elif [[ $choice == "Window" ]];then
            window
    elif [[ $choice == "Selection" ]];then
            selection
    fi
}


# timer
timer () {
    for sec in `seq $1 -1 1`; do
        notify-send -t 1000 "󱎫 Taking shot in : $sec" --app-name Screenshot
        sleep 1
    done
}

# full screenshot with delay option
delay () {
    timer $1
    sleep 0.5 && grim - | wl-copy
    notification
}

# window capture
window () {
    timer '1'
    area=$(hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])'$append'"')
    grim -g "$area" - | wl-copy
    notification
}

# selection capture
selection () {
    grim -g "$(slurp)" - | wl-copy
    notification
}

# open screenshot foler with kitty
open () {
    hyprctl dispatch exec '[float]' 'kitty -d ~/Pictures/Screenshots -e zsh -c "eza -alF --icons --color=always --hyperlink --group-directories-first -s=modified && exec zsh" '
}


# choose from input
# no input - full shot 0 delay

case $1 in
    "")
        delay 0
        ;;
    all)
        delay $2
        ;;
    window)
        window
        ;;        
    selection)
        selection
        ;;
    dmenu)
        dmenu
        ;;  
    open)
        open
        ;;
esac