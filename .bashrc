# History config
# **************

# Don't put duplicate commands or those starting with a space into history
export HISTCONTROL=ignoreboth
# Save history FOREVER
HISTSIZE=""
HISTFILESIZE=""
shopt -s histappend

HISTIGNORE="pwd:?:??"

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

# Aliases and functions
# *********************

# Add flags by default
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir="mkdir -pv"

# Alias common commands
alias la='ls -A'
alias rename='mv'
alias panic='reset'
alias back='cd $OLDPWD'

# Only use less if output is big enough to need it
alias less='less -FX'
alias more='less'

# Fix typos
alias gti='git'

# Navigation aliases
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias cd-='cd -'

# Copy working directory path
alias cpwd='pwd | tr -d "\n" | pbcopy'

# Pretty print PATH
alias path='echo -e ${PATH//:/\\n}'

# Display all terminal colours and their codes
alias colours='for code in $(seq -w 0 255); do for attr in 0 1; do printf "%s-%03s %bTest%b\n" "${attr}" "${code}" "\e[${attr};38;05;${code}m" "\e[m"; done; done | column -c $((COLUMNS*2))'

# Just for fun
alias busy='cat /dev/urandom | hexdump -C | grep "ca fe"'

# Edit and reload bashrc
function bashrc(){
  vi ~/.bashrc < `tty` > `tty`;
  source ~/.bashrc
  #TODO: update git repo bashrc automatically
}

# Display count of commands from history
popular(){
  USAGESTR="usage: popular [-c] [-n #] [-h]"
  if [ $# -gt 0 ]; then
    if [ $1 == "-h" -o $1 == "--help" ]; then
      echo $USAGESTR
      echo
      echo "Displays the most commonly used commands from your bash history"
      echo
      echo "Options:"
      echo " -c, --commands, --no-params   Count based on commands alone, ignoring parameters"
      echo " -n NUM, --number NUM          Count the number of times you used NUM commands consecutively"
      echo " -h, --help                    Display this message"
    elif [ $1 == "-c" -o $1 == "--commands" -o $1 == "--no-params" ]; then
      history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl -n ln | less
    elif [ $1 == "-n" -o $1 == "--number" ]; then
      if [ $# -lt 2 ]; then
        echo "Option requires an argument:" $1
        echo $USAGESTR
      elif [[ $2 =~ '^[1-9]+[0-9]*$' ]]; then
        echo "Invalid number of consecutive commands:" $2
      else
        #TODO: make compatible with -c
        export POPULAR_N=$2
        history | awk '{n=ENVIRON["POPULAR_N"]; $1 = ""; lastcommands=""; for (i=1; i<n; i++){ lastcommands=lastcommands";"last[i]}; CMD[lastcommands";"$0]++; for (i=1; i<n-1; i++){ last[i]=last[i+1]};last[n-1]=$0; count++; }  END { for (a in CMD){msg=substr(a,3); print CMD[a] "¬" CMD[a]/count*100 "%¬" msg;} }' | grep -v "^;|^ *$" | column -c3 -s "¬" -t | sort -nr | nl -n ln | less
        unset POPULAR_N
      fi
    else
      echo 'Unknown option:' $1
      echo $USAGESTR
    fi
  else
    history | awk '{$1 = "";CMD[$0]++;count++;}END { for (a in CMD)print CMD[a] "¬" CMD[a]/count*100 "%¬" a;}' | column -c3 -s "¬" -t | sort -nr | nl -n ln | less
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

# List details of all processes with name
# Usage: psof python
psof(){
  ps aux | grep $1
}

# Execute last command as sudo
please() {
  sudo $(history -p \!\!)
}
