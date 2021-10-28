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

## Executable search path
export PATH=/usr/local/sbin:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.local/sbin:$PATH

## Export time
export DATE=$(date +%Y-%m-%d)


## Make ISO image. Query values interactively.

mkiso() {
	echo "Enter volume name:"
	read volume
	echo "Enter ISO Name (ie. tmp.iso):"
	read iso
	echo "Enter input directory or file:"
	read files
	echo "Building '$HOME/$iso'"
	mkisofs -o ~/$iso -A $volume -allow-multidot -J -R -iso-level 3 -V $volume -R $files
}

## reload terminal session
reload() {
	if [[ "$#*" -eq 0 ]] ; then
		[[ -r ~/.zshrc ]] && . ~/.zshrc
	else
		local function
		for function in "$@"; do
			unfunction $function
			autoload -U $funtion
		done
	fi
}

      
# Clone any repo and cd into it 
clone() {
    cloneUsage() {
        echo "\n⚠️  Usage:\nclone <url*> <dir>\nclone <org*>/<repo*> <dir>\nclone <org*> <repo*> <dir>\n* denotes required arguments"
    }

    gitClone() {
        CYAN="\033[1;36m"
        NOCOLOR="\033[0m"
        echo "🤖 Cloning $1"
        git clone $2 $directory && cd $directory || (cloneUsage && return 1)
        # If an error code was returned from the last command, return an error code
        if [[ "$?" == 1 ]]; then
            return 1
        fi
        echo "🚚 Moved to directory ${CYAN}$directory${NOCOLOR}"
    }

    if [[ -z $1 ]]; then
        cloneUsage
        return 1
    fi

    gitURL="$1"
    gitURL="${gitURL%.git}" # Remove .git from the end of the git URL
    if [[ $gitURL =~ ^git@ ]]; then
        gitURL="$(echo $gitURL | sed 's/git@//')" # Remove git@ from the start of the git URL
        org="$(echo $gitURL | sed 's/.*\://' | sed 's/\/.*//')" # Pull the org from the git URL
        repo="$(echo $gitURL | sed 's/.*\///')" # Pull the repo name from the git URL
        directory=${2:-"$repo"}
        gitClone "$org/$repo" $1
    elif [[ $gitURL =~ ^https?:// ]]; then
        # Force SSH
        github="$(echo $gitURL | cut -d'/' -f3)"
        org="$(echo $gitURL | sed 's/.*\.com\///' | sed 's/\/.*//')" # Pull the org from the git URL
        repo="$(echo $gitURL | sed 's/.*\.com\///' | sed 's/.*\///')" # Pull the repo name from the git URL
        directory=${2:-"$repo"}
        gitClone "$org/$repo" "git@$github:$org/$repo.git"
    elif [[ ! -z $1 && ! -z $2 && "$1" != *\/*  ]]; then
        directory=${3:-"$2"}
        gitClone "$1/$2" "git@github.com:$1/$2.git" # Replace with GitHub Enterprise URL (if applicable)
    else
        repo="$(echo $1 | sed 's/.*\///')"
        directory=${2:-"$repo"}
        gitClone "$1" "git@github.com:$1.git" # Replace with GitHub Enterprise URL (if applicable)
    fi
}
        
