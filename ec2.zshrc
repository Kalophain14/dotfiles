# =============================================================
# TERMINAL OVERRIDE (must be first — fixes Ghostty's xterm-ghostty
# TERM value, which EC2's terminfo doesn't recognize and causes
# backspace/key issues)
# =============================================================
export TERM=xterm-256color

# =============================================================
# POWERLEVEL10K INSTANT PROMPT (keep at very top)
# =============================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# =============================================================
# OH-MY-ZSH
# =============================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_DISABLE_COMPFIX=true
plugins=(git zsh-autosuggestions zsh-syntax-highlighting z)
source $ZSH/oh-my-zsh.sh

# =============================================================
# HISTORY
# =============================================================
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt HIST_VERIFY
setopt EXTENDED_HISTORY

# =============================================================
# EDITOR
# =============================================================
export EDITOR='nano'
export VISUAL='nano'

# =============================================================
# PATH & TOOLS (Linux-native, no Homebrew)
# =============================================================
export PATH="$HOME/.local/bin:$PATH"

# NVM (installed via curl script on Linux, not Homebrew)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# SDKMAN (works fine on Linux, install separately if needed)
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# =============================================================
# ALIASES - GENERAL
# =============================================================
alias reload='source ~/.zshrc'
alias zshrc='nano ~/.zshrc'
alias ll='ls -alh --color=auto'
alias ls='ls --color=auto'
alias lt='ls -R'
alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'

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
alias gpsup='git push --set-upstream origin $(git_current_branch)'
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

function gacp { git add . && git commit -m "$1" && git push }

function gbrm {
    protected="main master develop"
    for b in $protected; do
        if [[ "$1" == "$b" ]]; then
            echo "Protected branch '$1' -- use git directly if you really mean it."
            return 1
        fi
    done
    echo -n "Delete '$1' locally and on origin? [y/N] "
    read confirm
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

function dkprune {
    echo -n "This removes ALL unused Docker images, containers, networks, and build cache. Continue? [y/N] "
    read confirm
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
# ALIASES - SECURITY
# =============================================================
alias connections='sudo lsof -i'
alias procs='ps aux | grep -v grep'
alias ports-all='netstat -an | grep LISTEN'

# =============================================================
# ALIASES - SYSTEM MONITORING (Linux-specific)
# =============================================================
alias meminfo='free -h'                          # Memory usage, human-readable
alias diskinfo='df -h'                            # Disk usage per mount
alias dfi='df -hi'                                 # Inode usage (disk can be "full" on inodes too)
alias diskusage='du -sh * | sort -rh'              # Biggest files/folders in current dir
alias cpuinfo='lscpu'                              # CPU details
alias osinfo='cat /etc/os-release'                 # OS/distro version
alias uptime-pretty='uptime -p'                    # "up 2 hours, 15 minutes"
alias topcpu='ps aux --sort=-%cpu | head -15'      # Top 15 CPU-hungry processes
alias topmem='ps aux --sort=-%mem | head -15'      # Top 15 memory-hungry processes
alias watch-cpu='watch -n 1 "ps aux --sort=-%cpu | head -15"'  # Live CPU monitor

# =============================================================
# ALIASES - SYSTEMD / SERVICES
# =============================================================
alias sc='sudo systemctl'                          # sc start nginx, sc status nginx
alias scs='sudo systemctl status'
alias scr='sudo systemctl restart'
alias sce='sudo systemctl enable'
alias scd='sudo systemctl disable'
alias jctl='sudo journalctl -xe'                    # Recent system logs w/ errors
alias jctlf='sudo journalctl -f'                    # Follow logs live
alias jctlu='sudo journalctl -u'                    # journalctl -u <service>

# =============================================================
# ALIASES - PACKAGE MANAGEMENT (Amazon Linux / RHEL-based)
# =============================================================
alias update='sudo yum update -y'
alias install='sudo yum install -y'
alias search='yum search'
alias remove='sudo yum remove -y'
alias listpkgs='yum list installed'

# =============================================================
# ALIASES - NETWORK (merged: local/public IP, connectivity, ports)
# =============================================================
alias localip="hostname -I | awk '{print \$1}'"
alias publicip='curl -s ifconfig.me'
alias myip='echo "Local: $(hostname -I | awk "{print \$1}") | Public: $(curl -s ifconfig.me)"'
alias pingg='ping -c 4 8.8.8.8'                    # Quick connectivity check
alias openports='sudo ss -tulnp'                   # Listening ports + process
alias whoisme='curl -s ipinfo.io'                  # IP, region, ISP info
alias sshconf='cat ~/.ssh/config'                  # Quick check what Host aliases exist

# =============================================================
# ALIASES - FILE OPS
# =============================================================
alias biggest='du -ah . | sort -rh | head -20'     # 20 biggest files/dirs here
alias countfiles='find . -type f | wc -l'          # Count files in current dir
alias emptytrash='rm -rf ~/.local/share/Trash/*'   # Clear trash (if applicable)
alias extract='tar -xvzf'                           # Quick tar extraction

# =============================================================
# ALIASES - MISC / SHELL
# =============================================================
alias envshow='env | sort'                          # See all environment variables
alias pathshow='echo $PATH | tr ":" "\n"'           # PATH, one entry per line
alias hist='history | tail -30'                     # Last 30 commands
alias whereami='pwd && hostname'                    # Quick orientation check

# =============================================================
# ALIASES - DOCKER CLEANUP
# =============================================================
alias dkclean='docker container prune -f && docker image prune -f'

# =============================================================
# FUNCTIONS
# =============================================================
function mkcd { mkdir -p "$1" && cd "$1" }
function killport { lsof -ti tcp:$1 | xargs kill }
function jsonpp { echo "$1" | jq . }

function ports {
  echo "=== 8080 (Spring) ===" && lsof -ti tcp:8080 | xargs ps -p 2>/dev/null || echo "free"
  echo "=== 5432 (Postgres) ===" && lsof -ti tcp:5432 | xargs ps -p 2>/dev/null || echo "free"
  echo "=== 6379 (Redis) ===" && lsof -ti tcp:6379 | xargs ps -p 2>/dev/null || echo "free"
}

function envnew {
  cat > .env << ENVEOF
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/dbname
SPRING_DATASOURCE_USERNAME=postgres
SPRING_DATASOURCE_PASSWORD=password
SPRING_JPA_HIBERNATE_DDL_AUTO=update
SERVER_PORT=8080
ENVEOF
  echo ".env created"
}

# =============================================================
# HELP - Type 'help' to see all your shortcuts
# =============================================================
function help {
  cat << 'CHEATSHEET'

╔══════════════════════════════════════════════════════════════════╗
║                 EC2 TERMINAL CHEATSHEET                          ║
╚══════════════════════════════════════════════════════════════════╝

┌─ NAVIGATION ─────────────────────────────────────────────────────┐
│  ll              List files with details                         │
│  ls              List files (color)                               │
│  ..              Go up one folder                                │
│  c               Clear terminal                                  │
│  mkcd <name>     Make directory and cd into it                   │
└──────────────────────────────────────────────────────────────────┘

┌─ GIT ────────────────────────────────────────────────────────────┐
│  gs              git status      gaa   Stage all                 │
│  gcm "msg"       Commit          gacp  Add+commit+push           │
│  gp / gpul       Push / Pull     gco   Checkout branch            │
│  glog / gtree    Pretty log      gd    Diff                       │
│  gst / gsp       Stash / Pop     gbrm  Delete branch (confirm)    │
└──────────────────────────────────────────────────────────────────┘

┌─ DOCKER ─────────────────────────────────────────────────────────┐
│  dkps            List containers   dkcu    Compose up            │
│  dklog <name>    Follow logs       dkcd    Compose down           │
│  dkex <name>     Shell into        dkprune Remove unused (confirm)│
└──────────────────────────────────────────────────────────────────┘

┌─ NETWORK ─────────────────────────────────────────────────────────┐
│  localip / publicip / myip     Show IPs         pingg  Ping 8.8.8.8│
│  openports    Listening ports  whoisme  IP/region/ISP info         │
│  sshconf      Show ~/.ssh/config Host aliases                      │
└──────────────────────────────────────────────────────────────────┘

┌─ SECURITY / PORTS ────────────────────────────────────────────────┐
│  killport <port>               Kill process on port              │
│  ports                         Check 8080/5432/6379 status       │
│  connections / ports-all       Network diagnostics               │
└──────────────────────────────────────────────────────────────────┘

┌─ MISC ───────────────────────────────────────────────────────────┐
│  reload          Reload zshrc     zshrc   Edit zshrc              │
│  envnew          Create .env      jsonpp  Pretty print JSON       │
└──────────────────────────────────────────────────────────────────┘

┌─ SHELL INFO ──────────────────────────────────────────────────────┐
│  envshow         Show env vars     pathshow   PATH, one per line  │
│  hist            Last 30 commands  whereami   pwd + hostname      │
└──────────────────────────────────────────────────────────────────┘

┌─ SYSTEM MONITORING ──────────────────────────────────────────────┐
│  meminfo         Memory usage       diskinfo   Disk usage         │
│  dfi             Inode usage        diskusage  Biggest in dir     │
│  cpuinfo         CPU details        osinfo     OS/distro info     │
│  uptime-pretty   Uptime             topcpu/topmem Top processes   │
│  watch-cpu       Live CPU monitor                                  │
└──────────────────────────────────────────────────────────────────┘

┌─ SYSTEMD / SERVICES ─────────────────────────────────────────────┐
│  sc <svc>        systemctl          scs <svc>  Status             │
│  scr <svc>       Restart            sce/scd    Enable/disable     │
│  jctl            Recent errors      jctlf      Follow logs live   │
│  jctlu <svc>     Logs for a unit                                   │
└──────────────────────────────────────────────────────────────────┘

┌─ PACKAGES (yum) ─────────────────────────────────────────────────┐
│  update          yum update         install <pkg>  yum install    │
│  search <term>   yum search         remove <pkg>   yum remove     │
│  listpkgs        List installed                                    │
└──────────────────────────────────────────────────────────────────┘

┌─ DOCKER CLEANUP ──────────────────────────────────────────────────┐
│  dkclean         Remove unused containers + images                 │
└──────────────────────────────────────────────────────────────────┘

┌─ FILE OPS ────────────────────────────────────────────────────────┐
│  biggest         20 biggest files   countfiles Count files here   │
│  extract <file>  Extract tar.gz                                    │
└──────────────────────────────────────────────────────────────────┘

CHEATSHEET
}

# =============================================================
# WELCOME MESSAGE
# =============================================================
typeset -g _welcome_shown=0
precmd() {
  if (( ! _welcome_shown )); then
    _welcome_shown=1
    print "Welcome to your EC2 instance, $(whoami)!"
    print "$(date '+%A, %d %B %Y')"
    print "Type 'help' to see all your shortcuts"
  fi
}

# =============================================================
# POWERLEVEL10K (keep near the bottom)
# =============================================================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
