# =============================================================
# POWERLEVEL10K INSTANT PROMPT (keep at very top)
# =============================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =============================================================
# OH-MY-ZSH
# =============================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_DISABLE_COMPFIX=true
plugins=(git zsh-autosuggestions zsh-syntax-highlighting z fzf)
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
export EDITOR='code'
export VISUAL='code'

# =============================================================
# PATH & TOOLS
# =============================================================
export PATH="$HOME/.local/bin:$PATH"

# Java / Spring Boot
export JAVA_HOME="/opt/homebrew/opt/openjdk@21"
export PATH="$JAVA_HOME/bin:$PATH"

# PostgreSQL
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && source "/opt/homebrew/opt/nvm/nvm.sh"

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --border'

# Zoxide (replaces cd)
eval "$(zoxide init zsh)"

# Direnv
_direnv_hook() {
  trap -- '' SIGINT
  eval "$("/opt/homebrew/bin/direnv" export zsh)"
  trap - SIGINT
}
typeset -ag precmd_functions
if (( ! ${precmd_functions[(I)_direnv_hook]} )); then
  precmd_functions=(_direnv_hook $precmd_functions)
fi
typeset -ag chpwd_functions
if (( ! ${chpwd_functions[(I)_direnv_hook]} )); then
  chpwd_functions=(_direnv_hook $chpwd_functions)
fi

# =============================================================
# ALIASES - GENERAL
# =============================================================
alias reload='source ~/.zshrc'
alias zshrc='code ~/.zshrc'
alias dotfiles='code ~/dotfiles'
alias ll='eza -al --icons'
alias ls='eza --icons'
alias lt='eza --tree --icons'
alias cat='bat'
alias ..='cd ..'
alias ...='cd ../..'
alias o='open .'
alias localip='ipconfig getifaddr en0'
alias publicip='curl -s ifconfig.me'
alias c='clear'

# =============================================================
# ALIASES - GIT
# =============================================================
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gcm='git commit -m'
alias gp='git push'
alias gpul='git pull'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gbd='git branch --delete'
alias glog='git log --oneline --decorate --graph'
alias gd='git diff'
alias gundo='git reset --soft HEAD~1'
alias gst='git stash'
alias gstp='git stash pop'
alias gpsup='git push --set-upstream origin $(git_current_branch)'
alias ghopen='open "https://github.com/$(git remote get-url origin | sed "s/.*github.com[:/]//" | sed "s/.git$//")"'

# =============================================================
# ALIASES - MAVEN
# =============================================================
alias mvnc='mvn clean'
alias mvni='mvn clean install'
alias mvnr='mvn spring-boot:run'
alias mvnt='mvn test'
alias mvnci='mvn clean install -DskipTests'

# =============================================================
# ALIASES - DOCKER
# =============================================================
alias dkps='docker ps'
alias dklog='docker logs -f'
alias dkex='docker exec -it'
alias dkcu='docker compose up -d'
alias dkcd='docker compose down'
alias dkcub='docker compose up --build'
alias dkprune='docker system prune -af'

# =============================================================
# ALIASES - POSTGRESQL
# =============================================================
alias pgstart='brew services start postgresql@16'
alias pgstop='brew services stop postgresql@16'
alias pgconn='psql -U postgres'

# =============================================================
# ALIASES - REDIS
# =============================================================
alias redstart='brew services start redis'
alias redstop='brew services stop redis'
alias redcli='redis-cli'

# =============================================================
# ALIASES - GHOSTTY
# =============================================================
alias ghostty-config='code ~/.config/ghostty/config'
alias ghostty-reload='kill -USR1 $(pgrep ghostty)'

# =============================================================
# FUNCTIONS
# =============================================================

# Make dir and cd into it
mkcd() { mkdir -p "$1" && cd "$1" }

# Quick add + commit + push
gacp() { git add . && git commit -m "$1" && git push }

# Kill process on port
killport() { lsof -ti tcp:$1 | xargs kill }

# Check common dev ports
ports() {
  echo "=== 8080 (Spring) ===" && lsof -ti tcp:8080 | xargs ps -p 2>/dev/null || echo "free"
  echo "=== 5432 (Postgres) ===" && lsof -ti tcp:5432 | xargs ps -p 2>/dev/null || echo "free"
  echo "=== 6379 (Redis) ===" && lsof -ti tcp:6379 | xargs ps -p 2>/dev/null || echo "free"
}

# Create new Spring Boot project
springnew() {
  mkcd "$1"
  echo "# $1" > README.md
  printf "target/\n.env\n*.log\n" > .gitignore
  git init
  open "https://start.spring.io"
}

# Create .env for Spring Boot
envnew() {
  cat > .env << EOF
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/dbname
SPRING_DATASOURCE_USERNAME=postgres
SPRING_DATASOURCE_PASSWORD=password
SPRING_JPA_HIBERNATE_DDL_AUTO=update
SERVER_PORT=8080
EOF
  echo ".env created"
}

# Spring + Docker together
springup() { docker compose up -d && mvn spring-boot:run }
springdown() { docker compose down }

# Pretty print JSON
jsonpp() { echo "$1" | jq . }

# Stow a dotfile package
stowit() { cd ~/dotfiles && stow "$1" && cd - }
unstowit() { cd ~/dotfiles && stow -D "$1" && cd - }

# =============================================================
# KEYBINDINGS
# =============================================================
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[1;5C' forward-word   # Ctrl+Right
bindkey '^[[1;5D' backward-word  # Ctrl+Left

# =============================================================
# POWERLEVEL10K (keep at very bottom)
# =============================================================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
