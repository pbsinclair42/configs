# TODO: add gitconfig installation

# if the bash profile link isn't there yet, make it
CMD="source ~/.bashrc"
if [ -f $HOME/.bash_profile ]; then
  if ! fgrep -q -e "$CMD" "$HOME/.bash_profile"; then
    printf "\n$CMD\n" >> $HOME/.bash_profile
  fi
else
  touch $HOME/.bash_profile
  printf "\n$CMD\n" >> $HOME/.bash_profile
fi

# if the bashrc link isn't there yet, make it
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CMD="source $DIR/.bashrc"
if [ -f $HOME/.bashrc ]; then
  echo $CMD
  if ! fgrep -q -e "$CMD" "$HOME/.bashrc"; then
    sed -i '' $'1s#^#'"$CMD"$'\\\n#' $HOME/.bashrc
  fi
else
  touch $HOME/.bashrc
  printf "$CMD\n" >> $HOME/.bashrc
fi
