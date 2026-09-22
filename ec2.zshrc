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
# TERMINAL / COLOR FIX (this is what fixes `clear` + color output)
# =============================================================
export TERM=xterm-256color

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
alias localip="hostname -I | awk '{print \$1}'"
alias publicip='curl -s ifconfig.me'
alias c='clear'
alias myip='echo "Local: $(hostname -I | awk "{print \$1}") | Public: $(curl -s ifconfig.me)"'

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

┌─ NETWORK / SECURITY ─────────────────────────────────────────────┐
│  localip / publicip / myip     Show IPs                          │
│  killport <port>               Kill process on port              │
│  ports                         Check 8080/5432/6379 status       │
│  connections / ports-all       Network diagnostics               │
└──────────────────────────────────────────────────────────────────┘

┌─ MISC ───────────────────────────────────────────────────────────┐
│  reload          Reload zshrc     zshrc   Edit zshrc              │
│  envnew          Create .env      jsonpp  Pretty print JSON       │
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
