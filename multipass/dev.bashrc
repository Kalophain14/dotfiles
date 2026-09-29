# =============================================================
# ~/.dev_bashrc — sourced from ~/.bashrc (pure bash, no frameworks)
# Only runs for interactive shells
# =============================================================
case $- in
  *i*) ;;
  *) return ;;
esac

# =============================================================
# SHELL OPTIONS  (zsh setopt -> bash shopt)
# =============================================================
shopt -s checkwinsize   # update LINES/COLUMNS after each command
shopt -s cdspell        # fix minor typos in cd
shopt -s autocd         # type a dir name to cd into it
shopt -s globstar       # ** matches recursively
shopt -s nocaseglob     # case-insensitive globbing

# =============================================================
# HISTORY
# zsh                      -> bash
# HISTSIZE/SAVEHIST        -> HISTSIZE/HISTFILESIZE
# HIST_IGNORE_DUPS/SPACE   -> HISTCONTROL=ignoreboth:erasedups
# SHARE_HISTORY            -> histappend + PROMPT_COMMAND 'history -a; history -n'
# HIST_VERIFY              -> shopt histverify
# EXTENDED_HISTORY         -> HISTTIMEFORMAT
# =============================================================
HISTSIZE=50000
HISTFILESIZE=50000
HISTFILE=~/.bash_history
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT='%F %T  '
shopt -s histappend
shopt -s histverify
PROMPT_COMMAND='history -a; history -n'

# =============================================================
# EDITOR / PATH
# =============================================================
export EDITOR='nano'
export VISUAL='nano'
export TERM=xterm-256color
export PATH="$HOME/.local/bin:$PATH"

# =============================================================
# COMPLETION
# =============================================================
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  fi
fi
bind "set completion-ignore-case on"
bind "set show-all-if-ambiguous on"

# =============================================================
# KEYBINDINGS  (replaces history-substring-search)
# Type the start of a command, then Up/Down to cycle matches
# =============================================================
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# fzf: Ctrl-R fuzzy history, Ctrl-T fuzzy file picker (replaces z / autosuggestions)
[ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && . /usr/share/doc/fzf/examples/key-bindings.bash

# =============================================================
# PROMPT  (replaces powerlevel10k)
# user@host:dir (git-branch) — green on success, red arrow on failure
# =============================================================
__git_branch() {
  local b
  b=$(git symbolic-ref --short HEAD 2>/dev/null) && printf ' (%s)' "$b"
}
__set_prompt() {
  local ec=$?
  local arrow='\[\e[32m\]'
  [ "$ec" -ne 0 ] && arrow='\[\e[31m\]'
  PS1="\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0;33m\]\$(__git_branch)\[\e[0m\] ${arrow}\\$\[\e[0m\] "
}
PROMPT_COMMAND="__set_prompt; $PROMPT_COMMAND"

# =============================================================
# ALIASES - GENERAL
# =============================================================
alias reload='source ~/.bashrc'
alias bashrc='nano ~/.dev_bashrc'
alias ll='ls -alh --color=auto'
alias ls='ls --color=auto'
alias lt='ls -R'
alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'
alias grep='grep --color=auto'

# =============================================================
# ALIASES - GIT
# =============================================================
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gcm='git commit -m'
alias gacm='git add . && git commit -m'
alias gp='git push'
alias gpul='git pull'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gpsup='git push --set-upstream origin "$(git branch --show-current)"'
alias gb='git branch'
alias gm='git merge'
alias gma='git merge --abort'
alias gmc='git merge --continue'
alias glog='git log --graph --pretty=format:"%C(yellow)%h%Creset -%C(cyan)%d%Creset %s %C(green)(%cr)%Creset %C(blue)<%ae>%Creset" --abbrev-commit --all'
alias gtree='git log --graph --oneline --decorate --all'
alias gd='git diff'
alias gds='git diff --staged'
alias gst='git stash'
alias gsp='git stash pop'
alias grb='git rebase -i'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'

gacp() {
  if [ -z "$1" ]; then
    echo "Usage: gacp \"commit message\""
    return 1
  fi
  git add . && git commit -m "$1" && git push
}

gbrm() {
  local protected=(main master develop) b confirm
  if [ -z "$1" ]; then
    echo "Usage: gbrm <branch>"
    return 1
  fi
  for b in "${protected[@]}"; do
    if [[ "$1" == "$b" ]]; then
      echo "Protected branch '$1' -- use git directly if you really mean it."
      return 1
    fi
  done
  read -r -p "Delete '$1' locally and on origin? [y/N] " confirm
  if [[ $confirm == [yY] ]]; then
    git branch -d "$1" && git push origin --delete "$1"
    echo "Deleted."
  else
    echo "Cancelled."
  fi
}

# =============================================================
# ALIASES - DOCKER
# =============================================================
alias dkps='docker ps'
alias dklog='docker logs -f'
alias dkex='docker exec -it'
alias dkcu='docker compose up -d'
alias dkcd='docker compose down'
alias dkcub='docker compose up --build'
alias dkclean='docker container prune -f && docker image prune -f'

dkprune() {
  local confirm
  read -r -p "This removes ALL unused Docker images, containers, networks, and build cache. Continue? [y/N] " confirm
  if [[ $confirm == [yY] ]]; then
    docker system prune -af
    echo "Pruned."
  else
    echo "Cancelled."
  fi
}

# =============================================================
# ALIASES - POSTGRESQL
# =============================================================
alias pgconn='psql -U postgres'

# =============================================================
# ALIASES - SECURITY / PORTS
# =============================================================
alias connections='sudo lsof -i'
alias procs='ps aux | grep -v grep'
alias ports-all='netstat -an | grep LISTEN'

# =============================================================
# ALIASES - SYSTEM MONITORING
# =============================================================
alias meminfo='free -h'
alias diskinfo='df -h'
alias dfi='df -hi'
alias diskusage='du -sh * | sort -rh'
alias cpuinfo='lscpu'
alias osinfo='cat /etc/os-release'
alias uptime-pretty='uptime -p'
alias topcpu='ps aux --sort=-%cpu | head -15'
alias topmem='ps aux --sort=-%mem | head -15'
alias watch-cpu='watch -n 1 "ps aux --sort=-%cpu | head -15"'

# =============================================================
# ALIASES - SYSTEMD / SERVICES
# =============================================================
alias sc='sudo systemctl'
alias scs='sudo systemctl status'
alias scr='sudo systemctl restart'
alias sce='sudo systemctl enable'
alias scd='sudo systemctl disable'
alias jctl='sudo journalctl -xe'
alias jctlf='sudo journalctl -f'
alias jctlu='sudo journalctl -u'

# =============================================================
# ALIASES - PACKAGE MANAGEMENT (Ubuntu/Debian — apt)
# Note: 'install' shadows /usr/bin/install in interactive shells only
# =============================================================
alias update='sudo apt update && sudo apt upgrade -y'
alias install='sudo apt install -y'
alias search='apt search'
alias remove='sudo apt remove -y'
alias listpkgs='apt list --installed'

# =============================================================
# ALIASES - NETWORK
# =============================================================
alias localip="hostname -I | awk '{print \$1}'"
alias publicip='curl -s ifconfig.me'
alias myip='echo "Local: $(hostname -I | awk "{print \$1}") | Public: $(curl -s ifconfig.me)"'
alias pingg='ping -c 4 8.8.8.8'
alias openports='sudo ss -tulnp'
alias whoisme='curl -s ipinfo.io'

# =============================================================
# ALIASES - FILE OPS
# =============================================================
alias biggest='du -ah . | sort -rh | head -20'
alias countfiles='find . -type f | wc -l'

extract() {
  if [ -z "$1" ] || [ ! -f "$1" ]; then
    echo "Usage: extract <archive>"
    return 1
  fi
  case "$1" in
    *.tar.gz|*.tgz)   tar -xvzf "$1" ;;
    *.tar.bz2|*.tbz2) tar -xvjf "$1" ;;
    *.tar.xz)         tar -xvJf "$1" ;;
    *.tar)            tar -xvf  "$1" ;;
    *.zip)            unzip "$1" ;;
    *.gz)             gunzip "$1" ;;
    *) echo "Don't know how to extract '$1'" ; return 1 ;;
  esac
}

# =============================================================
# ALIASES - MISC / SHELL
# =============================================================
alias envshow='env | sort'
alias pathshow='echo $PATH | tr ":" "\n"'
alias hist='history | tail -30'
alias whereami='pwd && hostname'

mkcd() { mkdir -p "$1" && cd "$1" || return; }

killport() {
  if [ -z "$1" ]; then
    echo "Usage: killport <port>"
    return 1
  fi
  sudo lsof -ti tcp:"$1" | xargs -r sudo kill
}

# Pretty-print JSON: jsonpp '{"a":1}'  or  curl -s url | jsonpp
jsonpp() {
  if [ -n "$1" ]; then echo "$1" | jq .; else jq .; fi
}

ports() {
  local p
  for p in 8080 5432 6379; do
    echo "=== $p ==="
    sudo ss -ltnp "sport = :$p" | tail -n +2 | grep . || echo "free"
  done
}

envnew() {
  if [ -e .env ]; then
    echo ".env already exists -- not overwriting."
    return 1
  fi
  cat > .env << 'ENVEOF'
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/dbname
SPRING_DATASOURCE_USERNAME=postgres
SPRING_DATASOURCE_PASSWORD=password
SERVER_PORT=8080
ENVEOF
  echo ".env created"
}

# =============================================================
# HELP  (named 'cheat' so it doesn't shadow bash's builtin 'help')
# =============================================================
cheat() {
  cat << 'CHEATSHEET'
============================================================
  BASH DEV VM CHEATSHEET
============================================================
NAVIGATION:  ll  ls  lt  ..  ...  c  mkcd <name>
GIT:         gs  gaa  gcm "msg"  gacp "msg"  gp  gpul  gco  gcb
             glog  gtree  gd  gst/gsp  gbrm <name>
DOCKER:      dkps  dklog  dkex  dkcu  dkcd  dkclean  dkprune
MONITORING:  meminfo  diskinfo  dfi  diskusage  cpuinfo  osinfo
             topcpu  topmem  watch-cpu  uptime-pretty
SYSTEMD:     sc <svc>  scs  scr  sce/scd  jctl  jctlf  jctlu <svc>
PACKAGES:    update  install <pkg>  search <term>  remove <pkg>
NETWORK:     localip  publicip  myip  pingg  openports  whoisme
FILE OPS:    biggest  countfiles  extract <file>
SHELL:       envshow  pathshow  hist  whereami
MISC:        reload  bashrc  envnew  jsonpp  killport <port>  ports
KEYS:        Ctrl-R fuzzy history   Ctrl-T fuzzy file   Up/Down prefix search
CHEATSHEET
}

# =============================================================
# WELCOME MESSAGE  (once per shell)
# =============================================================
# Shown once per shell, not again on 'reload'
if [[ -z ${_WELCOME_SHOWN:-} ]]; then
  _WELCOME_SHOWN=1
  echo "Welcome to your dev VM, $(whoami)!"
  date '+%A, %d %B %Y'
  echo "Type 'cheat' to see all your shortcuts"
fi
