#!/bin/zsh
## I can write these functions in as a plugin and add it to .zshrc file. 


# extract function for common arch files

extract() {                                     
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xvjf $1       ;;
      *.tar.gz)    tar xvzf $1       ;;
      *.bz2)       bunzip2 -v $1     ;;
      *.rar)       unrar x $1        ;;
      *.gz)        gunzip -v $1      ;;
      *.tar)       tar xvf $1        ;;
      *.tbz2)      tar xvjf $1       ;;
      *.tgz)       tar xvzf $1       ;;
      *.zip)       unzip $1          ;;
      *.Z)         uncompress -v $1  ;;
      *.7z)        7z x $1           ;;
      *)     echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

## ip lookups

# Public ip
myip() { curl -s ifconfig.me }
# Private ip
ipLocal() {
  for i in $(hostname -I); do
    name=$(ip a | grep $i | grep -oE '[^ ]+$')
    mac=$(ip -o link | grep $name | awk '$2 != "lo:" {print $(NF-2)}')
    echo "$name - ip : $i - mac : $mac"
  done
}

## system information

my_ps() { ps $@ -u $USER -o pid,%cpu,%mem,start,time,bsdtime,command ; }
infos() {
  echo -e "Currently logged on        : ${HOST}"
  echo -e "Additional information:    : $(uname -a)"
  echo -e "Current date:              : $(date)"
  echo -e "Machine stats:             : $(uptime)"
  echo -e "Public facing IP Address   : $(myip)"
  echo -e "Users logged on:           : \n$(w -h|sed "s/^/\t\t\t     /")"
  echo
}


## decode bas64 
gpg_decode () {
  echo "$1" | base64 --decode | gpg
}

