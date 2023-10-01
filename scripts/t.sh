#!/usr/bin/env bash

# if not currently in tmux
if [ -z "$TMUX" ]; then
  # save fzf to variables
  ZOXIDE_RESULT=$(zoxide query -l | fzf \
    --height=30% \
    --border \
    --info=inline \
    --border-label=' Select folder ' \
    --prompt='  ' \
    --header=' You can search from the list of zoxide result' )

  # if empty exit
  if [ -z "$ZOXIDE_RESULT" ]; then
    exit 0
  fi

  FOLDER=$(basename "$ZOXIDE_RESULT")

  # lookup tmux session name
  SESSION=$(tmux list-sessions | grep "$FOLDER" | awk '{print $1}')
  SESSION=${SESSION//:/}
  echo "$SESSION"
  
  if [ -z "$SESSION" ]; then
    # jump to directory
    cd "$ZOXIDE_RESULT" || exit
    # create session
    tmux new-session -s "$FOLDER"
  else
    # attach to session
    tmux attach -t "$SESSION"
  fi
else
  # tmux is active
  # save fzf to variables
  ZOXIDE_RESULT=$(zoxide query -l -s | sed "s#$HOME#~#" | fzf --reverse \
    --header=' You can search from the list of zoxide result' \
    --prompt '🔭 ' \
    --no-sort \
    --min-height=40 \
    --height=40%)

  # if no result exit
  if [ -z "$ZOXIDE_RESULT" ]; then
    exit 0
  fi

  ZOXIDE_RESULT=$(echo "$ZOXIDE_RESULT" | sed "s#~#$HOME#" | xargs | cut -d" " -f2)
  zoxide add "$ZOXIDE_RESULT"
  FOLDER=$(basename "$ZOXIDE_RESULT")
  # lookup tmux session name
  SESSION=$(tmux list-sessions | grep "$FOLDER" | awk '{print $1}')
  SESSION="${SESSION//:/}"

  if [ -z "$SESSION" ]; then
    # jump to directory
    cd "$ZOXIDE_RESULT" || exit
    # create session
    # echo "tmux new-session -d -s $FOLDER -c $ZOXIDE_RESULT"
    tmux new-session -d -s "$FOLDER" -c "$ZOXIDE_RESULT"
    # attach to session
    tmux switch-client -t "$FOLDER"
  else
    # attach to session
    # switch to tmux session
    tmux switch-client -t "$SESSION"
  fi
fi
