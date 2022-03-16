# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/USER/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"
# ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
export PATH="$HOME/.pyenv/bin:$PATH"
export PATH="$GOROOT/bin:$PATH"
export PATH="$PATH:$GOPATH/bin"

# jq - change colors to show better in gruvbox lite
# export JQ_COLORS="1;30:1;31:1;32:0;37:0;32:1;30:1;30"

# Profile1 Config
export AWS_ACCESS_KEY_ID=AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=AWS_SECRET_ACCESS_KEY

# Profile2 Config
# export AWS_ACCESS_KEY_ID='AWS_ACCESS_KEY_ID'
# export AWS_SECRET_ACCESS_KEY='AWS_SECRET_ACCESS_KEY'
# aws configure [--profile profile-name]
# aws configure --profile profile1   # Fill profile1 credentials
# aws configure --profile profile2   # Fill profile2 credentials
alias awsp1="export AWS_PROFILE=profile1"
alias awsp2="export AWS_PROFILE=profile2"
export AWS_PROFILE=profile1
eval "$(pyenv init -)"
eval "$(goenv init -)"
# eval "$(pyenv virtualenv-init -)"
alias zshrc="code ~/.zshrc"
alias zsh_history="code ~/.zsh_history"

mntsj () {
    if [ ! -z $1 ]
    then
        md /mnt/$1/{dev,stage,prod}/{full,delta}
    else
        echo "Please provide folder name to be created in /mnt"
    fi
}

sshm () {
    declare -A options
    local keys
    local selected
    while IFS== read -r key value; do
        options[$key]="$value"
    done < <(jq -r 'to_entries|map("\(.key)=\(.value)")|.[]' /mnt/scratchpad/sshLogins.json)
    keys=(${(k)options})
    # echo ${keys[1]}
    # echo "count of keys = "${#keys[@]}
    # echo ${keys}
    keys=$(printf '%s\n' "${(o)keys[@]}")
    selected=$(fzf --header="Select a server to ssh into" <<<${keys})
    echo ${selected}
    ssh ${options[${selected}]}

}

gj () {
    local keys
    local selected
    local filetype
    local res
    local done1
    declare -a commandset
    keys=$(cat config.json  | jq -rS '.customFiles | keys[]')
    selected=$(fzf --header="Select a file to run grunt commands" <<<${keys})
    echo ${selected}
    filetype=$(tr '[:upper:]' '[:lower:]' <<<"${selected: -3}")
    if [[ $filetype = "css" ]]
    then
        commandset=("bundlecss" "uploadcss" "invalidatecss")
    elif [[ ${filetype: -2} = "js" ]]
    then
        commandset=("bundlejs" "uploadjs" "invalidatejs")
    else
        echo "Neither JS nor CSS"
        exit
    fi
    for i in "${commandset[@]}"
    do
        res=$(grunt $i --custom=$selected)
        echo $res
        done1=$(awk -F "," '{w=$1} END{print w}' <<<${res} | tr '[:upper:]' '[:lower:]' | sed -E "s/[[:cntrl:]]\[[0-9]{1,3}m//g")
        echo $res
        if [[ $done1 = "done" ]]
        then
            echo "$i of $selected successful"
        else
            echo "$i of $selected failed"
            exit
        fi
    done
}

sjm (){
    local START
    local SJDIR
    local CURRDIR
    local keys
    local selected
    local commitmessage
    START="/Users/USER/Desktop/FeedWork/source"
    SJDIR="/Users/USER/Desktop/FeedWork/repo-dir"
    CURRDIR=$PWD
    cd $SJDIR
    keys=$(\ls -d */)
    # echo "test"
    keys=$(printf '%s\n' "${(o)keys[@]}" | tr -d /)
    # echo $keys
    selected=$(fzf --multi --header="Select a folder to migrate" <<<${keys})
    echo ${selected}
    # echo $CURRDIR
    # echo "Entered $START Folder"

    cd $START
    rm -rf REPO
    git clone git@github.com:USER/REPO.git
    cd REPO
    git checkout master
    git filter-repo --path $selected --force
    cd ../REPO-v2

    # git checkout main
    # git fetch upstream main
    # git pull upstream main
    git checkout -b ${selected}-port
    git remote add remotename ../REPO/
    git pull remotename master --allow-unrelated-histories
    git mv ${selected}/ src/
    commitmessage=$(sed "s/folder/${selected}/g" <<< "init(folder): Port from REPO/folder")
    echo "commit message is"
    echo $commitmessage
    gcmsg "$commitmessage"
    git push --set-upstream origin ${selected}-port

    echo "Reached correct folder"
    cd $CURRDIR
    # rm -rf REPO
}

# md /mnt/folderName/{dev,stage,prod}/{full,delta} # making folders in mnt
# alt + <- go left by word; alt + -> go right by word
# alt + d <- cut word after cursor

# https://github.com/ohmyzsh/ohmyzsh/wiki/Cheatsheet

alias gitlog="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"
alias :nt="open -n -a alacritty"
# git clone url
# gcl url
# cd repo-folder-name
# git checkout -b branch-name
# gcb branch-name
# git diff
# gd
# git status -sb # short form status while showing branch
# gsb
# git status -u # status for current branch listed at top
# gst -u
# git add .
# ga .
# git commit -m "Commit Message"
# gcmsg "Commmit Message"
# git commit -a -m "Commit Message"
# gcam "Commmit Message"
# git push origin branch-name
# ggp
# git push origin --delete branch-name # Deletes remote branch
# git branch -d branch-name # Deletes local branch
# gbd branch-name
# git branch -D branch-name # Deletes local branch forcefully, even if not merged into master

# https://stackoverflow.com/a/53246204
# Fetch someone's PR
# git checkout -b <branch>
# git pull origin pull/PRNumber/head
# git pull upstream pull/PRNumber/head


# git push origin +branch # use after rebasing to show only 1 commit in PR


# User->Features->Terminal and look for the section called "Integrated > Tabs:Enabled" and un-check it.
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export FZF_DEFAULT_OPTS="--cycle --preview-window wrap,follow,cycle --preview 'bat --style=numbers --color=always --line-range :2000 {}' --layout=reverse --inline-info"
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color fg:#ebdbb2,bg:#282828,hl:#fabd2f,fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f
  --color info:#83a598,prompt:#bdae93,spinner:#fabd2f,pointer:#83a598,marker:#fe8019,header:#665c54'

alias cat='bat --paging=never'
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Changing "ls" to "exa"
alias ls='exa -al --color=always --group-directories-first' # my preferred listing
alias la='exa -a --color=always --group-directories-first'  # all files and dirs
alias ll='exa -l --color=always --group-directories-first'  # long format
alias lt='exa -aT --color=always --group-directories-first' # tree listing
alias :q=exit

export LS_COLORS="$(vivid generate molokai)"
# export LS_COLORS="$(vivid generate snazzy)"

# Bat Theme
# export BAT_THEME="ansi"
# bat --list-themes | fzf --preview="bat --theme={} --color=always /Users/USER/config.json"
export BAT_PAGER="less -R"

export START="Desktop"
if [[ $PWD == $HOME ]]; then
    cd $START
fi

# vi mode
# bindkey -v
# export KEYTIMEOUT=1

bindkey -s '^v' 'sshm^M'

export SPARK_HOME="/Users/USER/bigdata/spark"
export PYTHONPATH="$PYTHONPATH:$SPARK_HOME/python:$SPARK_HOME/python/lib"
export PATH="$PATH:$SPARK_HOME/bin"

# git stash -u # Stash untracked files as well
# git stash -a # Stash all 
# git stash pop stash@{2} # Pass identifier as last argument to pop and apply the particular stash
# git stash save "message" # Save stash with message
# git stash clear # Delete all stashes
# git stash pop # Apply last stash to the branch and remove the stash
# git stash pop "stash@{N}" # Apply Nth stash to the branch and remove the stash
# git stash apply # Apply last stash to the branch without removing the stash

# 2to3 -w .
# pipreqs . --force

# docker rm -vf $(docker ps -a -q)
# docker rmi -f $(docker images -a -q)

# docker build --force-rm --progress=plain -t imageName .
# docker run -it imageName sh



# git push -f <remote> <branch>
# git push -f origin branch-name

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# place this after nvm initialization!
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# Created by `pipx` on 2021-12-21 08:57:02
export PATH="$PATH:/Users/USER/.local/bin"

# cd to folder where venv is required
# python -m venv venv 
# source venv/bin/activate
