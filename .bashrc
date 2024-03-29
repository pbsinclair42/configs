# History config
# **************

# Don't put duplicate commands into history
export HISTCONTROL=ignoredups
# Save history FOREVER
HISTSIZE=""
HISTFILESIZE=""
shopt -s histappend

HISTIGNORE="pwd:?:??:hgrep*:history*:  *:git st:g st:git status:g status"

# Make a backup of history 5% of the time
if (( RANDOM % 20 == 0 )); then
  d="$(date '+%Y-%m-%dT%H:%M')"
  \cp -f ~/.bash_history ~/.history_backups/.bash_history_$d.bak
fi

# save multiline commands as one command in history
shopt -s cmdhist

# Shell behaviour config
# **********************

# path/to/dir == cd path/to/dir
shopt -s autocd

# try and fix spelling mistakes in cd
shopt -s cdspell
shopt -s dirspell

# alert any running jobs on exiting terminal
shopt -s checkjobs

# check for window resize after every command
shopt -s checkwinsize

# include .files in filename expansion
shopt -s dotglob

# use ** to match any number of subdirectories
shopt -s globstar

# Don't create .pyc files
export PYTHONDONTWRITEBYTECODE=True

# Make vi the default editor
export EDITOR='vi'
export VISUAL='vi'

# Custom prompt
# *************
_generate_prompt_and_title(){
  local GREEN BLUE PURPLE GREY NC PYTHON_VIRTUALENV PREFIX SSH_NOTIFICATION GIT_BRANCH WD PROMPT TITLE
  GREEN="\[\e[0;38;05;64m\]"
  BLUE="\[\e[0;34m\]"
  PURPLE="\[\e[1;38;05;127m\]"
  GREY="\[\e[2;97m\]"
  NC="\[\e[m\]"
  if test -z "$VIRTUAL_ENV" ; then
    PYTHON_VIRTUALENV=""
  else
    PYTHON_VIRTUALENV="${PURPLE}* "
  fi
  if [ $(date '+%m') == 12 ] ; then
    PREFIX="☃ "
  else
    PREFIX=""
  fi
  if test -z "$SSH_CLIENT" ; then
    SSH_NOTIFICATION=""
  else
    SSH_NOTIFICATION="☁️ "
  fi
  GIT_BRANCH=`git branch --column 2> /dev/null | tr '\n' ' ' | sed 's/.*\* \([^ ]*\).*/<\1> /g'`
  PROMPT="${PREFIX}${PYTHON_VIRTUALENV}${GREEN}${GIT_BRANCH}${GREY}${SSH_NOTIFICATION}${BLUE}[\W]:${NC} "
  if [ -z ${TEMPORARY_TITLE+x} ]; then
    WD=`echo ${PWD/#$HOME/'~'} | sed 's/.*\/\([^\/]*\)/\1/g'`
    TITLE="\[\e]0;${SSH_NOTIFICATION} ${WD}\a\]"
  else
    TITLE="\[\e]0;$TEMPORARY_TITLE\a\]"
    unset TEMPORARY_TITLE
  fi
  export PS1=$PROMPT$TITLE
}
PROMPT_COMMAND='_generate_prompt_and_title'
export PS2="\[\e[0;34m\]>\[\e[m\] "
title(){
  TEMPORARY_TITLE=$1
}

# Change cursor to a blinking bar
if [ "$PS1" ]; then
  echo -e -n "\x1b[\x35 q"
fi

# Aliases and functions
# *********************

# Add flags by default
alias cp='cp -i'
alias mv='mv -i'
alias mkdir="mkdir -pv"
alias ls='ls --indicator-style=slash --group-directories-first --color=auto --time-style=+"%y/%m/%d-%H:%m"'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'


# Alias common commands
alias la='ls -A'
alias ll='ls -lgGAhN'
alias lld='ll | sort -k4'
alias rename='mv'
alias panic='reset'
alias back='cd $OLDPWD'
alias g='git'
alias calc='bc -l'
alias st='git st'
alias lg='git lg'

# Only use less if output is big enough to need it (-FX)
# Use colours (-R)
# Show search results in the middle of the screen (-j.5)
alias less='less -FXRj.5'
alias more='less'

# Fix typos
alias gti='git'
alias gt='git'
alias sl='ls'
alias bakc='back'

# Navigation aliases
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias cd-='cd -'

# Copy to clipboard
alias copy='xclip -selection clipboard'

# Use ~ instead of home in pwd
alias wd='echo ${PWD/$HOME/"~"}'

# Copy working directory path
alias cwd='pwd | tr -d "\n" | xclip -selection clipboard'

# Pretty print PATH
alias path='echo -e ${PATH//:/\\n}'

# Search history
alias hgrep='history | grep'

# Line count
alias lc='wc -l'

# Word wrap
alias wrap='fold -w $COLUMNS'
alias wraps='wrap -s'

# Edit ssh config
alias sshconfig='$EDITOR ~/.ssh/config'

# Just for fun
alias busy='cat /dev/urandom | hexdump -C | \grep "ca fe" --color=always'

# Save the directory of this file
export CONFIG_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Import bookmarks functionality
source "$CONFIG_DIR/bookmarks"

# Import git autocompletion functionality
source "$CONFIG_DIR/git_autocomplete"

# Import ssh autocompletion functionality
source "$CONFIG_DIR/ssh_autocomplete"

# Show size of all directories and files
size(){
  local esc=$(printf '\e');
  if [ $# -gt 0 ]; then
    if [ $1 == "-s" -o $1 == "--sort" -o $1 == "--sorted" ]; then
      { du -sh */ | sort -rh | sed "s#\t\([^/]*\)#\t${esc}[1;34m\1${esc}[m#g"; find -maxdepth 1 -type f -exec du -sh {} + | sed 's\./\\' | sort -rh; } | cat;
    else
      echo "Usage: size [-s]";
    fi
  else
    { du -sh */ | sed "s#\t\([^/]*\)#\t${esc}[1;34m\1${esc}[m#g"; find -maxdepth 1 -type f -exec du -sh {} + | sed 's\./\\'; } | cat;
  fi;
}

# BEEP
beep(){
  ( ( speaker-test --frequency 400 --test sine >>/dev/null ) & pid=$!; sleep 0.2s; kill -9 $pid; )
}

# Remove duplicate lines without sorting
uniqq(){
  awk '!x[$0]++'
}

# Display all terminal colours and their codes
colours(){
  USAGESTR="Usage: colours [(-s | --simple | --simp)] [(-w | --word) <word to colour>]"
  SIMPLE_FLAG=false
  WORD='Test'
  while [ $# -gt 0 ]; do
    if [ $1 == "-s" -o $1 == "--simple" -o $1 == "--simp" ]; then
      SIMPLE_FLAG=true
      shift
    elif [ $1 == "-w" -o $1 == "--word" ]; then
      if [ $# -lt 2 ]; then
        echo "Option requires an argument:" $1
        echo $USAGESTR
        return
      fi
      WORD=$2
      shift
      shift
    else
      echo 'Unknown option:' $1
      echo $USAGESTR
      return
    fi
  done
  if [ "$SIMPLE_FLAG" = true ]; then
    echo "Example: \e[(0 or 1);(code)m"
    for code in {30..37} {90..97}; do
      for attr in 2 0 1; do
        printf "%s-%02s %b${WORD}%b\n" "${attr}" "${code}" "\e[${attr};${code}m" "\e[m";
      done
    done | column -c $((COLUMNS))
    return
  else
    echo "Example: \e[(0 or 1);38;05;(code)m"
    for code in $(seq -w 0 255); do
      for attr in 2 0 1; do
        printf "%s-%03s %b${WORD}%b\n" "${attr}" "${code}" "\e[${attr};38;5;${code}m" "\e[m";
      done;
    done | column -c $((COLUMNS*2))
  fi
}

# Display custom aliases and functions
aliases(){
  aliass=$(_getAliases ~/.bashrc)
  echo "$aliass" | sed 's/=/ = /1' | awk 'BEGIN {i=0 ; max=0} {res[i]=$1; $1=""; res[i+1]=$0; res[i+2]=length(res[i]); if(res[i+2]>max)max=res[i+2]; i=i+3; } END {for (j=0;j<i-1;j++){ t=""; for(k=0;k<max-res[j+2];k++){t=t " "};print res[j] t, res[j+1];j+=2}}' | awk '!x[$0]++'
}
_getAliases(){
  theseAliases=$(cat "$1" | grep "^alias " | sed 's/alias //g' | sed "s/[\'\"]\(.*\)[\'\"]$/\1/g")
  customFunctions=$(cat "$1" | grep -B 1 "^[^_][a-zA-Z0-9_-]*() *{" | sed 's/() *{//g' | paste -d'\t' - - - | sed 's/--//' | sed 's/# \(.*\)\t\(.*\)\t/\2=\1/')
  if [ "$theseAliases" == "" ]; then
    theseAliases=$customFunctions
  fi
  if [ "$customFunctions" != "" ]; then
    theseAliases="$theseAliases
$customFunctions"
  fi
  nextfiles=$(cat "$1" | grep ^source | sed 's/source //g')
  for file in $nextfiles; do
    file=${file//"~"/$HOME}
    morealiases=$(eval "_getAliases $file")
    if [ "$theseAliases" == "" ]; then
      theseAliases=$moreAliases
    fi
    if [ "$morealiases" != "" ]; then
      theseAliases="$theseAliases
$morealiases"
    fi
  done
  if [ "$theseAliases" != "" ]; then
    echo "$theseAliases"
  fi
}

# Edit and reload bashrc
bashrc(){
  if [ $# -gt 0 ]; then
    if [ $1 == "-l" -o $1 == "--local" -o $1 == "-g" -o $1 == "--global" ]; then
      vi ~/.bashrc < `tty` > `tty`;
      source ~/.bashrc
    elif [ $1 == "-u" -o $1 == "--universal" ]; then
      vi "$CONFIG_DIR"/.bashrc < `tty` > `tty`;
      source ~/.bashrc
    else
      echo "usage: bashrc [-l | -u]"
    fi
  else
    vi "$CONFIG_DIR"/.bashrc < `tty` > `tty`;
    source ~/.bashrc
  fi
}

# Edit and reload gitconfig
gitconfig(){
  if [ $# -gt 0 ]; then
    if [ $1 == "-g" -o $1 == "--global" ]; then
      git config --global -e
    elif [ $1 == "-l" -o $1 == "--local" ]; then
      git config --local -e
    elif [ $1 == "-u" -o $1 == "--universal" ]; then
      vi "$CONFIG_DIR"/.gitconfig < `tty` > `tty`;
      "$CONFIG_DIR"/install.sh
    else
      echo "usage: gitconfig [-l | -g | -u]"
    fi
  else
    vi "$CONFIG_DIR"/.gitconfig < `tty` > `tty`;
    "$CONFIG_DIR"/install.sh
  fi
}

# Edit and reload gitignore
gitignore(){
  if [ $# -gt 0 ]; then
    if [ $1 == "-g" -o $1 == "--global" ]; then
      vi +1 '+/# Global ignores' "$HOME"/.gitignore < `tty` > `tty`
    elif [ $1 == "-l" -o $1 == "--local" ]; then
      vi "$(git rev-parse --show-toplevel)/.gitignore"
    elif [ $1 == "-u" -o $1 == "--universal" ]; then
      vi "$CONFIG_DIR"/.gitignore < `tty` > `tty`
    else
      echo "usage: gitignore [-l | -g | -u]"
    fi
  else
    vi "$CONFIG_DIR"/.gitignore < `tty` > `tty`
  fi
}

# Display count of commands from history
popular(){
  USAGESTR="usage: popular [-c] [-n #] [-h]"
  CFLAG=false
  NFLAG=false
  while [ $# -gt 0 ]; do
    if [ $1 == "-h" -o $1 == "--help" ]; then
      echo $USAGESTR
      echo
      echo "Displays the most commonly used commands from your bash history"
      echo
      echo "Options:"
      echo " -c, --commands, --no-params   Count based on commands alone, ignoring parameters"
      echo " -n NUM, --number NUM          Count the number of times you used NUM commands consecutively"
      echo " -h, --help                    Display this message"
      return
    elif [ $1 == "-c" -o $1 == "--commands" -o $1 == "--no-params" ]; then
      CFLAG=true
      shift
    elif [ $1 == "-n" -o $1 == "--number" ]; then
      if [ $# -lt 2 ]; then
        echo "Option requires an argument:" $1
        echo $USAGESTR
        return
      elif [[ $2 =~ '^[1-9]+[0-9]*$' ]]; then
        echo "Invalid number of consecutive commands:" $2
        return
      else
        NFLAG=$2
        shift
        shift
      fi
    else
      echo 'Unknown option:' $1
      echo $USAGESTR
      return
    fi
  done
  if [ "$CFLAG" = false ]; then
    if [ "$NFLAG" = false ]; then
      history | awk '{$1 = "";CMD[$0]++;count++;}END { for (a in CMD)print CMD[a] "¬" CMD[a]/count*100 "%¬" a;}' | column -c3 -s "¬" -t | sort -nr | nl -n ln | less
    else
        export POPULAR_N=$NFLAG
        history | awk '{n=ENVIRON["POPULAR_N"]; $1 = ""; lastcommands=""; for (i=1; i<n; i++){ lastcommands=lastcommands";"last[i]}; CMD[lastcommands";"$0]++; for (i=1; i<n-1; i++){ last[i]=last[i+1]};last[n-1]=$0; count++; }  END { for (a in CMD){msg=substr(a,3); print CMD[a] "¬" CMD[a]/count*100 "%¬" msg;} }' | grep -v "^;|^ *$" | column -c3 -s "¬" -t | sort -nr | nl -n ln | less
        unset POPULAR_N
    fi
  else
    if [ "$NFLAG" = false ]; then
      history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl -n ln | less
    else
        export POPULAR_N=$NFLAG
        history | awk '{n=ENVIRON["POPULAR_N"]; $1 = ""; lastcommands=""; for (i=1; i<n; i++){ lastcommands=lastcommands"; "last[i]}; CMD[lastcommands"; "$2]++; for (i=1; i<n-1; i++){ last[i]=last[i+1]};last[n-1]=$2; count++; }  END { for (a in CMD){msg=substr(a,2); print CMD[a] "¬" CMD[a]/count*100 "%¬" msg;} }' | grep -v "^;|^ *$" | column -c3 -s "¬" -t | sort -nr | nl -n ln | less
        unset POPULAR_N
    fi
  fi
}

# cd and look
cl(){
  params=""
  while test $# -gt 0; do
    case "$1" in
      -*)
        params="${params}$1 "
        shift
        ;;
      *)
        cd "$1"
        shift
        ls $params $@ ./
        return
        ;;
    esac
  done
}

# cd into created directory
mcd(){
  mkdir -p -- "$1" &&
  cd -P -- "$1"
}

# cd into directory of moved file
mvcd(){
  mv "$1" "$2" &&
  cd ${2%/*}
}

# colour find in the same way as ls
finc(){
  find "$1" -exec ls --color -d {} \;
}


# List details of all processes with name
# Usage: psof python
psof(){
  ps aux | grep $1
}

# Execute last command as sudo
please() {
  sudo $(history -p \!\!)
}

# unzip any compressed files
extract() {
  if [ $# -eq 0 ]; then
    extract *
  fi
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  NC='\033[0;0m'
  while [ $# -gt 0 ]; do
    printf "${RED}"
    if [ -f $1 ]; then
      case $1 in
        *.tar.bz2) tar xvjf $1   2>&1 >/dev/null;;
        *.tar.gz)  tar xvzf $1   2>&1 >/dev/null;;
        *.tar.xz)  tar Jxvf $1   2>&1 >/dev/null;;
        *.bz2)     bunzip2 $1    2>&1 >/dev/null;;
        *.rar)     unrar x $1    2>&1 >/dev/null;;
        *.gz)      gunzip $1     2>&1 >/dev/null;;
        *.tar)     tar xvf $1    2>&1 >/dev/null;;
        *.tbz2)    tar xvjf $1   2>&1 >/dev/null;;
        *.tgz)     tar xvzf $1   2>&1 >/dev/null;;
        *.zip)     unzip $1      2>&1 >/dev/null;;
        *.Z)       uncompress $1 2>&1 >/dev/null;;
        *.7z)      7z x $1       2>&1 >/dev/null;;
        *)         (exit 1);;
      esac
      if [ $? -eq 0 ]; then
        echo -e "${GREEN}Successfully extracted $1"
        if [ -f $1 ]; then
          rm $1
        fi
      else
        echo -e "${RED}Unable to extract $1"
      fi
      shift
    elif [ $1=="*" ]; then
      shift
    else
      echo -e "${RED}File not found: '$1'";
      shift
    fi
  done
  printf "$NC"
}

# creates an archive (*.tar.gz) from given directory.
maketar() {
 tar cvzf "${1%%/}.tar.gz"  "${1%%/}/";
}

# create a ZIP archive of a file or folder.
makezip() {
 zip -r "${1%%/}.zip" "$1" ;
}

# view a pretty printed JSON file
json(){
 cat $1 | jq -C '.' | less -R
}

# An extension to json which allows passing arguments
jqless() {
    if [[ $# -ge 2 ]] ; then
        exp=$2
    else
        exp=.
    fi
    if [[ "$1" == *.gz ]] ; then
        cmd1="gzip -dc"
    else
        cmd1="cat"
    fi
    eval $cmd1 $1 | jq -C $exp | less
}


# Display sorted count of unique lines
tally() {
  sort | uniq -c | sort -rn
}

# Display an epoch time in a human readable format
epoch_to_human() {
  if [[ ${#1} != 13 && ${#1} != 10 ]]; then
    echo "Expected length 10 (seconds) or 13 (millis). Got ${#1}."
    return
  fi

  TSTAMP=$1

  if [[ ${#1} == 13 ]]; then
    TSTAMP=${1:0:-3}
  fi

  if [[ "${OSTYPE//[0-9.]/}" == "darwin" ]]; then
    date -r $TSTAMP
  else
    date -d @$TSTAMP
  fi
}
