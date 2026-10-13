# =============================================================
# ~/.dev_bashrc — sourced from ~/.bashrc. Pure bash, native commands.
# =============================================================
case $- in
  *i*) ;;
  *) return ;;
esac

# ---------- SHELL OPTIONS ----------
shopt -s autocd         # type a dir name (or ..) to cd into it
shopt -s cdspell        # fix minor typos in cd
shopt -s dirspell       # fix typos in dir names during tab completion
shopt -s globstar       # ** matches recursively
shopt -s nocaseglob     # case-insensitive globbing
shopt -s checkwinsize   # refresh LINES/COLUMNS after each command
shopt -s cmdhist        # multi-line commands stay one history entry

# ---------- HISTORY ----------
HISTSIZE=50000
HISTFILESIZE=50000
HISTCONTROL=ignoreboth:erasedups   # skip dups and space-prefixed commands
HISTIGNORE='ls:cd:pwd:exit:clear:history'
HISTTIMEFORMAT='%F %T  '
shopt -s histappend     # append, don't overwrite, on exit
shopt -s histverify     # !! and !$ expand for review before running

# ---------- ENV ----------
export EDITOR=nano VISUAL=nano
export PATH="$HOME/.local/bin:$PATH"
# Terminals like Ghostty send TERM=xterm-ghostty, unknown to the VM -> clear/nano/less/htop break.
# Fall back to a universal type when the VM has no terminfo entry for it.
infocmp "$TERM" >/dev/null 2>&1 || export TERM=xterm-256color
export LESS='-R'
# colored man pages
export LESS_TERMCAP_mb=$'\e[1;31m' LESS_TERMCAP_md=$'\e[1;36m' \
       LESS_TERMCAP_me=$'\e[0m'    LESS_TERMCAP_se=$'\e[0m' \
       LESS_TERMCAP_so=$'\e[1;33;44m' LESS_TERMCAP_ue=$'\e[0m' \
       LESS_TERMCAP_us=$'\e[1;32m'

# ---------- COMPLETION ----------
if ! shopt -oq posix && [ -f /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
fi
bind "set completion-ignore-case on"
bind "set show-all-if-ambiguous on"
bind "set colored-stats on"
bind "set colored-completion-prefix on"
bind "set mark-symlinked-directories on"

# ---------- KEYS ----------
# Type a prefix, then Up/Down cycles matching history
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
# fzf: Ctrl-R fuzzy history, Ctrl-T fuzzy file picker
[ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && . /usr/share/doc/fzf/examples/key-bindings.bash

# ---------- PROMPT ----------
# 
# user@host  ~/path (branch) [✘ exit-code]
# $
__git_branch() {
  local b
  b=$(git symbolic-ref --short -q HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null) \
    && printf ' (%s)' "$b"
}
__set_prompt() {
  local ec=$?                      # must be first: captures last exit code
  local rs='\[\e[0m\]' status=''
  (( ec != 0 )) && status=" \[\e[1;31m\][✘ $ec]${rs}"
  PS1="\n\[\e[1;32m\]\u\[\e[0;37m\]@\[\e[1;36m\]\h${rs}  \[\e[1;34m\]\w${rs}\[\e[0;33m\]\$(__git_branch)${rs}${status}\n\\$ "
}
PROMPT_COMMAND='__set_prompt; history -a'   # assigned (not appended) so reload is safe

# ---------- ALIASES (your basics; every native command still works) ----------
# Format-only (same command name)
alias ls='ls --color=auto -F'
alias grep='grep --color=auto'
alias ip='ip -c'
alias df='df -hT'
alias free='free -h'
# Navigation / config
alias ll='ls -alh'
alias lt='tree -C -L 2'
alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'
alias reload='source ~/.bashrc'
alias bashrc='nano ~/.dev_bashrc'
# Git
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
alias gd='git diff'
alias gds='git diff --staged'
alias glog='git log --oneline --graph --decorate --all'
alias gst='git stash'
alias gsp='git stash pop'
# Docker
alias dkps='docker ps'
alias dklog='docker logs -f'
alias dkex='docker exec -it'
alias dkcu='docker compose up -d'
alias dkcd='docker compose down'
alias dkcub='docker compose up --build'
alias dkclean='docker container prune -f && docker image prune -f'
# Systemd
alias sc='sudo systemctl'
alias scs='sudo systemctl status'
alias scr='sudo systemctl restart'
alias sce='sudo systemctl enable'
alias scd='sudo systemctl disable'
alias jctl='sudo journalctl -xe'
alias jctlf='sudo journalctl -f'
alias jctlu='sudo journalctl -u'
# Network
alias localip="hostname -I | awk '{print \$1}'"
alias publicip='curl -s ifconfig.me'
alias myip='echo "Local: $(hostname -I | awk "{print \$1}") | Public: $(curl -s ifconfig.me)"'
alias openports='sudo ss -tulnp'
alias pingg='ping -c 4 8.8.8.8'

mkcd() { mkdir -p "$1" && cd "$1" || return; }

gacp() {
  [ -z "$1" ] && { echo 'Usage: gacp "commit message"'; return 1; }
  git add . && git commit -m "$1" && git push
}

dkprune() {
  local r
  read -r -p "Remove ALL unused Docker images, containers, networks, cache? [y/N] " r
  [[ $r == [yY] ]] && docker system prune -af || echo "Cancelled."
}

killport() {
  [ -z "$1" ] && { echo "Usage: killport <port>"; return 1; }
  sudo lsof -ti tcp:"$1" | xargs -r sudo kill
}

ports() {
  local p
  for p in 8080 5432 6379; do
    echo "=== $p ==="
    sudo ss -ltnp "sport = :$p" | tail -n +2 | grep . || echo "free"
  done
}

# ---------- help: boxed cheatsheet ----------
# Alias boxes:  alias | plain-English explanation (native command it runs)
# Native boxes: native command | what it does
# 'help' = everything, 'help <topic>' = one section. Unknown topics fall
# through to the bash builtin (help cd, help type, ...).
_HW=76
_rep()    { local s; printf -v s '%*s' "$2" ''; printf '%s' "${s// /$1}"; }
_sec()    { printf '\n┌─ %s ' "$1"; _rep ─ $((_HW - ${#1} - 3)); printf '┐\n'; }
_row()    { printf '│ %-*s %-*s │\n' "$1" "$2" $((_HW - 3 - $1)) "$3"; }
_a()      { _row 16 "$@"; }
_n()      { _row 34 "$@"; }
_end()    { printf '└'; _rep ─ "$_HW"; printf '┘\n'; }
_banner() {
  local t="TERMINAL CHEATSHEET" l=$(( (_HW - 19) / 2 ))
  printf '\n╔'; _rep ═ "$_HW"; printf '╗\n'
  printf '║%*s%s%*s║\n' "$l" '' "$t" $((_HW - 19 - l)) ''
  printf '╚'; _rep ═ "$_HW"; printf '╝\n'
}

_help_topic() {
  case "${1:-}" in
    nav|navigation)
      _sec "NAVIGATION"
      _a ll            "List files with details, incl. hidden (ls -alh)"
      _a ls            "List files, colored; / marks folders (ls -F)"
      _a lt            "Show folders as a tree, 2 levels deep (tree -L 2)"
      _a ..            "Go up one folder (cd ..)"
      _a ...           "Go up two folders (cd ../..)"
      _a c             "Clear the terminal screen (clear)"
      _a "mkcd <name>" "Make a directory and cd into it (mkdir -p + cd)"
      _end ;;
    config)
      _sec "CONFIG"
      _a reload        "Reload shell config after editing (source ~/.bashrc)"
      _a bashrc        "Edit your aliases file (nano ~/.dev_bashrc)"
      _a help          "Show this whole cheatsheet"
      _a "help <topic>" "Show one section, e.g. help git, help docker"
      _end ;;
    network|net)
      _sec "NETWORK"
      _a localip       "Show the VM's local IP (hostname -I)"
      _a publicip      "Show your public IP as the internet sees it (curl)"
      _a myip          "Show local + public IP in one shot"
      _a openports     "List listening ports and their process (ss -tulnp)"
      _a ports         "Check dev ports 8080, 5432, 6379: in use or free"
      _a "killport <port>" "Kill the process using a port (lsof + kill)"
      _a pingg         "Ping 8.8.8.8 4 times to test internet (ping -c 4)"
      _end
      _sec "NETWORK - NATIVE COMMANDS"
      _n "ip -br -c a"                 "Brief colored list of interfaces + IPs"
      _n "ip r"                        "Routing table and default gateway"
      _n "dig +short example.com"      "Look up a DNS record"
      _n "curl -I https://host"        "Fetch only the HTTP headers of a URL"
      _n "nc -zv host 5432"            "Is the port open through the firewall?"
      _n "traceroute host"             "Show each hop packets take to a host"
      _n "sudo tcpdump -i any port 80" "Capture live traffic on a port"
      _end ;;
    git)
      _sec "GIT - DAILY WORKFLOW"
      _a g             "Shorthand for git"
      _a gs            "Show changed, staged, untracked files (git status)"
      _a "ga <file>"   "Stage one file for the next commit (git add)"
      _a gaa           "Stage all changes in this folder (git add .)"
      _a 'gcm "msg"'   "Commit staged changes with a message (git commit -m)"
      _a 'gacm "msg"'  "Stage all + commit (git add . && git commit -m)"
      _a 'gacp "msg"'  "Stage all + commit + push in one go"
      _a gp            "Upload your commits to the remote (git push)"
      _a gpul          "Download + merge remote changes (git pull)"
      _a "gco <branch>" "Switch to an existing branch (git checkout)"
      _a "gcb <name>"  "Create a new branch and switch to it (checkout -b)"
      _a gpsup         "Push a new branch + link it to origin (--set-upstream)"
      _a gd            "Show unstaged changes line by line (git diff)"
      _a gds           "Show staged changes before commit (git diff --staged)"
      _a glog          "Commit history as a graph (git log --oneline --graph)"
      _a "gst / gsp"   "Stash changes / restore stashed (git stash [pop])"
      _end ;;
    docker)
      _sec "DOCKER"
      _a dkps          "List running containers (docker ps)"
      _a "dklog <c>"   "Follow a container's logs live (docker logs -f)"
      _a "dkex <c> sh" "Open a shell inside a container (docker exec -it)"
      _a dkcu          "Start the compose stack in background (compose up -d)"
      _a dkcd          "Stop and remove the compose stack (compose down)"
      _a dkcub         "Rebuild images + start the stack (compose up --build)"
      _a dkclean       "Delete stopped containers + dangling images (prune)"
      _a dkprune       "Delete ALL unused Docker data, asks first (prune -af)"
      _end ;;
    systemd|system|svc)
      _sec "SYSTEMD"
      _a sc            "Run systemctl as root (sudo systemctl)"
      _a "scs <svc>"   "Is the service running? Status + recent logs"
      _a "scr <svc>"   "Restart a service to apply config (restart)"
      _a "sce <svc>"   "Start a service automatically at boot (enable)"
      _a "scd <svc>"   "Stop starting a service at boot (disable)"
      _a jctl          "Recent system errors with context (journalctl -xe)"
      _a jctlf         "Follow all system logs live (journalctl -f)"
      _a "jctlu <svc>" "Show logs of one service (journalctl -u)"
      _end ;;
    monitor|proc)
      _sec "MONITORING - NATIVE COMMANDS"
      _n "htop"                        "Live CPU and memory per process"
      _n "free -h"                     "Show memory usage, human-readable"
      _n "df -hT"                      "Disk usage per filesystem, with type"
      _n "ps aux --sort=-%mem | head"  "Top 10 memory-hungry processes"
      _n "lsof -i :8080"               "Which process owns a port"
      _n "uptime"                      "How long up + load averages"
      _end ;;
    pkg|apt)
      _sec "PACKAGES - NATIVE COMMANDS (apt)"
      _n "sudo apt update"             "Refresh the package list"
      _n "sudo apt install -y <pkg>"   "Install a package (same in cloud-init)"
      _n "apt search <term>"           "Find packages by keyword"
      _n "apt-cache policy <pkg>"      "Installed vs available version"
      _n "sudo apt remove <pkg>"       "Uninstall a package"
      _end ;;
    files|fs)
      _sec "FILES - NATIVE COMMANDS"
      _n "ls -lah"                     "Permissions, owner, size of files"
      _n "find . -name '*.tf'"         "Find files by name (e.g. Terraform)"
      _n "grep -rn 'text' ."           "Search text inside all files"
      _n "chmod 600 key.pem"           "Lock a private key to owner only"
      _n "tar -xzf f.tgz"              "Unpack a .tar.gz archive"
      _n "du -sh * | sort -rh | head"  "Find what is filling the disk"
      _end ;;
    ssh)
      _sec "SSH - NATIVE COMMANDS"
      _n "ssh -i key.pem user@host"    "Connect to a server with a key file"
      _n "ssh-keygen -t ed25519"       "Create a new SSH key pair"
      _n "ssh-copy-id user@host"       "Install your public key on a server"
      _n "scp file user@host:/path"    "Copy a file to a server"
      _n "ssh -L 5432:db:5432 host"    "Tunnel a local port to a private DB"
      _end ;;
    python|py)
      _sec "PYTHON - NATIVE COMMANDS"
      _n "python3 -m venv .venv"       "Create an isolated environment"
      _n "source .venv/bin/activate"   "Enter the virtual environment"
      _n "pip install -r requirements.txt" "Install pinned dependencies"
      _n "python3 -m http.server 8000" "Serve this folder on port 8000 (test)"
      _n "python3 -m json.tool"        "Pretty-print JSON piped in"
      _end ;;
    terraform|tf)
      _sec "TERRAFORM - NATIVE COMMANDS"
      _n "terraform init"              "Download providers and modules"
      _n "terraform fmt"               "Auto-format .tf files"
      _n "terraform validate"          "Check configuration syntax"
      _n "terraform plan"              "Preview changes; nothing is changed"
      _n "terraform apply"             "Create/update the infrastructure"
      _n "terraform state list"        "List resources Terraform manages"
      _n "terraform destroy"           "Delete everything it manages"
      _end ;;
    env)
      _sec "ENVIRONMENT - NATIVE COMMANDS"
      _n "env | sort"                  "List all environment variables"
      _n "export VAR=value"            "Set a variable for child processes"
      _n 'echo $PATH | tr ":" "\n"'    "Show folders searched for commands"
      _n "printenv VAR"                "Print one variable's value"
      _n "type <cmd>"                  "Is it an alias, function or program?"
      _end ;;
    keys)
      _sec "KEYS"
      _n "Ctrl-R"                      "Fuzzy search command history"
      _n "Ctrl-T"                      "Fuzzy pick a file path"
      _n "Up / Down"                   "Cycle history matching what you typed"
      _n "Tab Tab"                     "Autocomplete commands, paths, flags"
      _n "Ctrl-A / Ctrl-E"             "Jump to line start / end"
      _n "Ctrl-C / Ctrl-L"             "Cancel command / clear screen"
      _end ;;
    *) builtin help "$@" ;;
  esac
}

help() {
  if [ -z "${1:-}" ] || [ "$1" = all ]; then
    { _banner
      local t
      for t in nav config network git docker systemd monitor pkg files ssh python terraform env keys; do
        _help_topic "$t"
      done
    } | if command -v less >/dev/null; then less -RFX; else cat; fi
  else
    _help_topic "$@"
  fi
}
complete -W "all nav config network git docker systemd monitor pkg files ssh python terraform env keys" help

# ---------- WELCOME (once per shell) ----------
if [[ -z ${_WELCOME_SHOWN:-} ]]; then
  _WELCOME_SHOWN=1
  echo "Welcome, $(whoami). $(date '+%A, %d %B %Y')"
  echo "Type 'help' for the cheatsheet."
fi
