# Add the universal gitconfig from the repo to the computer's global settings

if [ -f ~/.gitconfig ]; then
  sed -i '' '/# Universal config/,/# Global config/d' $HOME/.gitconfig
  \cp $HOME/.gitconfig .temp
  printf "# Universal config\n" > ~/.gitconfig
  cat .gitconfig >> ~/.gitconfig
  printf "\n# Global config\n" >> ~/.gitconfig
  cat .temp >> ~/.gitconfig
  \rm .temp
else
  touch ~/.gitconfig
  printf "# Universal config\n" > ~/.gitconfig
  cat .gitconfig >> ~/.gitconfig
  printf "\n# Global config\n" >> ~/.gitconfig
fi

# Copy the gittemplate
\cp .gittemplate ~/.gittemplate

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
  if ! fgrep -q -e "$CMD" "$HOME/.bashrc"; then
    # add $CMD to start of ~/.bashrc
    sed -i '' $'1s#^#'"$CMD"$'\\\n#' $HOME/.bashrc
  fi
else
  touch $HOME/.bashrc
  printf "$CMD\n" >> $HOME/.bashrc
fi
