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
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && source "/opt/homebrew/opt/nvm/nvm.sh" --no-use

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
alias reload='source ~/.zshrc'       # Reload terminal config
alias zshrc='code ~/.zshrc'          # Edit terminal config
alias dotfiles='code ~/dotfiles'     # Open dotfiles folder
alias ll='eza -al --icons'           # List files with details
alias ls='eza --icons'               # List files with icons
alias lt='eza --tree --icons'        # List files as tree
alias cat='bat'                      # Better file viewer
alias ..='cd ..'                     # Go up one folder
alias ...='cd ../..'                 # Go up two folders
alias o='open .'                     # Open folder in Finder
alias localip='ipconfig getifaddr en0' # Show local IP
alias publicip='curl -s ifconfig.me'   # Show public IP
alias c='clear'                      # Clear terminal

# =============================================================
# ALIASES - GIT
# =============================================================
alias g='git'                        # Shorthand for git
alias gs='git status'                # Show changes
alias ga='git add'                   # Stage a file
alias gaa='git add .'                # Stage all files
alias gcm='git commit -m'            # Commit with message
alias gacm='git add . && git commit -m' # Add all and commit
alias gp='git push'                  # Push to remote
alias gpul='git pull'                # Pull from remote
alias gco='git checkout'             # Switch branch
alias gcb='git checkout -b'          # Create new branch
alias gb='git branch'                # List branches
alias gbd='git branch --delete'      # Delete branch
alias glog='git log --graph --pretty=format:"%C(yellow)%h%Creset -%C(cyan)%d%Creset %s %C(green)(%cr)%Creset %C(blue)<%ae>%Creset" --abbrev-commit --all'
alias gd='git diff'                  # Show differences
alias gundo='git reset'               # Undo last commit with hash
alias gundos='git reset --soft HEAD~1' # Undo last commit, keep changes staged
alias gundoh='git reset --hard HEAD~1' # Hard reset, discard all changes
alias gundomh='git reset --mixed HEAD~1' # Undo last commit, unstage changes
alias gst='git stash'                 # Stash changes
alias gsp='git stash pop'             # Restore stashed changes
alias gsc='git clean'                 # Stash clean
alias gpsup='git push --set-upstream origin $(git_current_branch)'
alias ghopen='open "https://github.com/$(git remote get-url origin | sed "s/.*github.com[:/]//" | sed "s/.git$//")"'
alias grb='git rebase -i'      # Interactive rebase
alias grbc='git rebase --continue'   # Continue rebase after resolving conflicts
alias grba='git rebase --abort'      # Abort rebase

# =============================================================
# ALIASES - MAVEN
# =============================================================
alias mvnc='mvn clean'               # Clean build
alias mvni='mvn clean install'       # Clean and install
alias mvnr='mvn spring-boot:run'     # Run Spring Boot app
alias mvnt='mvn test'                # Run tests
alias mvnci='mvn clean install -DskipTests' # Install skip tests

# =============================================================
# ALIASES - DOCKER
# =============================================================
alias dkps='docker ps'               # List running containers
alias dklog='docker logs -f'         # Follow container logs
alias dkex='docker exec -it'         # Enter container shell
alias dkcu='docker compose up -d'    # Start containers
alias dkcd='docker compose down'     # Stop containers
alias dkcub='docker compose up --build' # Rebuild and start
alias dkprune='docker system prune -af' # Remove unused data

# =============================================================
# ALIASES - POSTGRESQL
# =============================================================
alias pgstart='brew services start postgresql@16' # Start Postgres
alias pgstop='brew services stop postgresql@16'   # Stop Postgres
alias pgconn='psql -U postgres'                   # Connect to Postgres

# =============================================================
# ALIASES - REDIS
# =============================================================
alias redstart='brew services start redis' # Start Redis
alias redstop='brew services stop redis'   # Stop Redis
alias redcli='redis-cli'                   # Open Redis CLI

# =============================================================
# ALIASES - GHOSTTY
# =============================================================
alias ghostty-config='code ~/.config/ghostty/config' # Edit Ghostty config
alias ghostty-reload='pkill -USR1 ghostty'            # Reload Ghostty

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
  cat > .env << ENVEOF
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/dbname
SPRING_DATASOURCE_USERNAME=postgres
SPRING_DATASOURCE_PASSWORD=password
SPRING_JPA_HIBERNATE_DDL_AUTO=update
SERVER_PORT=8080
ENVEOF
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
# HELP - Type 'help' to see all your shortcuts
# =============================================================
help() {
  echo "
  ╔══════════════════════════════════════╗
  ║       YOUR TERMINAL CHEATSHEET       ║
  ╚══════════════════════════════════════╝

  📁 NAVIGATION
  ll              list files with details
  ls              list files with icons
  lt              list files as tree
  ..              go up one folder
  ...             go up two folders
  o               open folder in Finder
  c               clear terminal
  mkcd 'name'     make dir and cd into it

  ⚙️  CONFIG
  reload          reload terminal config
  zshrc           edit terminal config
  dotfiles        open dotfiles in VS Code

  🌐 NETWORK
  localip         show your local IP
  publicip        show your public IP
  killport 8080   kill process on port
  ports           check dev ports status

  🐙 GIT — STATUS & STAGING
  gs              git status
  ga 'file'       stage a file
  gaa             stage all files
  gd              show diff
  glog            pretty graph log

  🐙 GIT — COMMITS
  gcm 'msg'       commit with message
  gacm 'msg'      add all + commit
  gacp 'msg'      add all + commit + push
  gundo           undo last commit (with hash)
  gundos          undo commit, keep changes staged
  gundoh          hard reset, discard all changes
  gundomh         undo commit, unstage changes

  🐙 GIT — PUSH & PULL
  gp              push to remote
  gpul            pull from remote
  gpsup           push and set upstream origin

  🐙 GIT — BRANCHES
  gco             checkout branch
  gcb 'name'      create new branch
  gb              list branches
  gbd 'name'      delete branch

  🐙 GIT — STASH
  gst             stash changes
  gsp             restore stashed changes
  gsc             clean stash

  🐙 GIT — REBASE
  grb             interactive rebase
  grbc            continue rebase after conflicts
  grba            abort rebase
  ghopen          open repo on GitHub

  ☕ MAVEN
  mvnr            run Spring Boot app
  mvni            clean install
  mvnc            clean build
  mvnt            run tests
  mvnci           install, skip tests

  🐳 DOCKER — CONTAINERS
  dkps            list running containers
  dklog 'name'    follow container logs
  dkex 'name'     enter container shell
  dkprune         remove all unused data

  🐳 DOCKER — COMPOSE
  dkcu            start containers (detached)
  dkcd            stop containers
  dkcub           rebuild and start

  🐘 POSTGRESQL
  pgstart         start postgres
  pgstop          stop postgres
  pgconn          connect as postgres user

  🔴 REDIS
  redstart        start redis
  redstop         stop redis
  redcli          open redis CLI

  👻 GHOSTTY
  ghostty-config  edit ghostty config
  ghostty-reload  reload ghostty

  🌱 SPRING / PROJECT
  springnew 'n'   scaffold Spring Boot project
  envnew          create .env template
  springup        docker up + mvn run
  springdown      docker compose down

  🛠️  UTILITIES
  jsonpp 'json'   pretty print JSON
  stowit 'pkg'    stow a dotfile package
  unstowit 'pkg'  unstow a dotfile package
  "
}

# =============================================================
# KEYBINDINGS
# =============================================================
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[1;5C' forward-word   # Ctrl+Right
bindkey '^[[1;5D' backward-word  # Ctrl+Left


# =============================================================
# WELCOME MESSAGE
# =============================================================
(( ${+commands[zsh-defer]} )) || {
  typeset -g _welcome_shown=0
  precmd() {
    if (( ! _welcome_shown )); then
      _welcome_shown=1
      print "👋 Welcome back, $(whoami)!"
      print "📅 $(date '+%A, %d %B %Y')"
      print "💡 Type 'help' to see all your shortcuts"
    fi
  }
}

# =============================================================
# POWERLEVEL10K (keep at very bottom)
# =============================================================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
