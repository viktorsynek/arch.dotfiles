#!/bin/bash
# =============================
# Startup apps + workspace layout
# =============================
sleep 1

# Workspace 1: terminal on primary
hyprctl dispatch workspace 1
hyprctl dispatch exec ghostty
sleep 1

# Workspace 2: browser on primary
hyprctl dispatch workspace 2
hyprctl dispatch exec brave
sleep 3

# Workspace 3: Discord + Spotify on secondary (vertical split)
hyprctl dispatch workspace 3
hyprctl dispatch exec discord
hyprctl dispatch exec spotify
sleep 7

# Stack them vertically - focus discord and move it up
hyprctl dispatch focuswindow class:discord
sleep 0.3
hyprctl dispatch movewindow u
# Resize discord to take 55% height
hyprctl dispatch resizeactive exact 1080 1030
