# History config
# **************

# Don't put duplicate commands or those starting with a space into history
export HISTCONTROL=ignoreboth
# Save history FOREVER
HISTSIZE=""
HISTFILESIZE=""
shopt -s histappend

HISTIGNORE="pwd:?:??"

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

# Don't create .pyc files
export PYTHONDONTWRITEBYTECODE=True

# Make vi the default editor
export EDITOR='vi'
export VISUAL='vi'

# Custom prompt
# *************
export PS1="\[\033[0;34m\][\W]:\[\033[0m\] "
export PS2="\[\033[0;34m\]>\[\033[0m\] "

# Aliases and functions
# *********************

# Add flags by default
alias cp='cp -i'
alias mv='mv -i'
alias mkdir="mkdir -pv"
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'


# Alias common commands
alias la='ls -A'
alias rename='mv'
alias panic='reset'
alias back='cd $OLDPWD'
alias g='git'

# Only use less if output is big enough to need it
alias less='less -FX'
alias more='less'

# Fix typos
alias gti='git'
alias gt='git'

# Navigation aliases
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias cd-='cd -'

# Use ~ instead of home in pwd
alias wd='echo ${PWD/$HOME/"~"}'

# Copy working directory path
alias cwd='pwd | tr -d "\n" | xclip -selection clipboard'

# Pretty print PATH
alias path='echo -e ${PATH//:/\\n}'

# Search history
alias hgrep='history | grep'

# BEEP
alias beep='echo -e "\a"'

# Display all terminal colours and their codes
alias colours='for code in $(seq -w 0 255); do for attr in 0 1; do printf "%s-%03s %bTest%b\n" "${attr}" "${code}" "\e[${attr};38;05;${code}m" "\e[m"; done; done | column -c $((COLUMNS*2))'

# Just for fun
alias busy='cat /dev/urandom | hexdump -C | grep "ca fe"'

# Save the directory of this file
export CONFIG_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Edit and reload bashrc
function bashrc(){
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
function gitconfig(){
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
function cl(){
  params=""
  while test $# -gt 0; do
    case "$1" in
      -*)
        params="${params}$1 "
        shift
        ;;
      *)
        cd "$1"
        ls $params ./
        shift
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

# unzip any compressed file
extract () {
 if [ -f $1 ] ; then
  case $1 in
   *.tar.bz2)	tar xvjf $1 && cd $(basename "$1" .tar.bz2) ;;
   *.tar.gz)	tar xvzf $1 && cd $(basename "$1" .tar.gz) ;;
   *.tar.xz)	tar Jxvf $1 && cd $(basename "$1" .tar.xz) ;;
   *.bz2)	bunzip2 $1 && cd $(basename "$1" /bz2) ;;
   *.rar)	unrar x $1 && cd $(basename "$1" .rar) ;;
   *.gz)	gunzip $1 && cd $(basename "$1" .gz) ;;
   *.tar)	tar xvf $1 && cd $(basename "$1" .tar) ;;
   *.tbz2)	tar xvjf $1 && cd $(basename "$1" .tbz2) ;;
   *.tgz)	tar xvzf $1 && cd $(basename "$1" .tgz) ;;
   *.zip)	unzip $1 && cd $(basename "$1" .zip) ;;
   *.Z)		uncompress $1 && cd $(basename "$1" .Z) ;;
   *.7z)	7z x $1 && cd $(basename "$1" .7z) ;;
   *)		echo "don't know how to extract '$1'..." ;;
  esac
 else
  echo "'$1' is not a valid file!"
 fi
}

# creates an archive (*.tar.gz) from given directory.
function maketar() {
 tar cvzf "${1%%/}.tar.gz"  "${1%%/}/";
}

# create a ZIP archive of a file or folder.
function makezip() {
 zip -r "${1%%/}.zip" "$1" ;
}

# view a pretty printed JSON file
function json(){
 cat $1 | jq '.' | less
}
