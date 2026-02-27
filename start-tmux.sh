#!/bin/bash

SESH="mydev"

tmux has-session -t $SESH 2>/dev/null

if [ $? != 0 ]; then
    tmux new-session -d -s $SESH -n "vim"
    tmux send-keys -t $SESH:vim "cd /home/cnek/" C-m
fi

tmux attach -t $SESH
