#!/bin/bash
playerctl --player=spotify metadata --format '{{title}}|{{artist}}' --follow | while IFS='|' read -r title artist; do
    notify-send -i spotify "Now Playing" "$artist - $title"
done
