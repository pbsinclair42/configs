# History config
# **************

# Don't put duplicate commands or those starting with a space into history
export HISTCONTROL=ignoreboth
# Save history FOREVER
HISTSIZE=""
HISTFILESIZE=""

HISTIGNORE="pwd:?:??"

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
  history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl | less
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
