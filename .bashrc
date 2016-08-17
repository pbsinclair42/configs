# Add flags by default
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir="mkdir -pv"

# Alias common commands
alias la='ls -A'
alias rename='mv'
alias back='cd $OLDPWD'

# less>more
alias more='less'

# Navigation aliases
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias cd-='cd -'

# Pretty print PATH
alias path='echo -e ${PATH//:/\\n}'

# Don't put duplicates in history
export HISTCONTROL=ignoredups

function bashrc(){
  vi ~/.bash_rc < `tty` > `tty`;
  source ~/.bash_rc
}

# Display count of commands from history
popular(){
  history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl | less
}

# cd into created directory
mcd(){
  mkdir -p -- "$1" &&
  cd -P -- "$1"
}

