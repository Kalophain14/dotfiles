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

# Unalias any oh-my-zsh aliases that shadow our functions
unalias gbd 2>/dev/null || true  # oh-my-zsh defines gbd='git branch -d', we use gbrm()


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
# Homebrew shell environment (must come first — other tool paths below assume it)
eval "$(/opt/homebrew/bin/brew shellenv)"

export PATH="$HOME/.local/bin:$PATH"

# PostgreSQL
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

# Java (openjdk via Homebrew, kept as dependency for gradle/jdtls/kafka/tomcat)
export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && source "/opt/homebrew/opt/nvm/nvm.sh" --no-use

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --border'

# =============================================================
# AWS CLI SHORTCUTS
# =============================================================
[ -f ~/dotfiles/zsh/aws-cli-shortcuts.sh ] && source ~/dotfiles/zsh/aws-cli-shortcuts.sh

# Zoxide (replaces cd)
eval "$(zoxide init zsh)"

# Thefuck (auto-correct mistyped commands)
eval "$(thefuck --alias)"

# Pyenv
eval "$(pyenv init -)"

# Direnv
function _direnv_hook {
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

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

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
alias copy='pbcopy'                  # Copy stdin to clipboard

# =============================================================
# ALIASES - GIT
# =============================================================

# --- Daily Workflow ---
alias g='git'                                        # Shorthand for git
alias gs='git status'                                # Show changes
alias ga='git add'                                   # Stage a file
alias gaa='git add .'                                # Stage all files
alias gcm='git commit -m'                            # Commit with message
alias gacm='git add . && git commit -m'              # Add all and commit
alias gp='git push'                                  # Push to remote
alias gpul='git pull'                                # Pull from remote
alias gco='git checkout'                             # Switch branch
alias gcb='git checkout -b'                          # Create new branch
alias gpsup='git push --set-upstream origin $(git_current_branch)'

# --- Branch Management ---
alias gb='git branch'                                # List branches
alias gm='git merge'                                 # Merge branch
alias gma='git merge --abort'                        # Abort merge
alias gmc='git merge --continue'                     # Continue merge after conflicts
alias gmn='git merge --no-ff'                       # Merge with explicit merge commit
alias gms='git merge --squash'                     # Squash all commits into one

# --- History & Debugging ---
alias glog='git log --graph --pretty=format:"%C(yellow)%h%Creset -%C(cyan)%d%Creset %s %C(green)(%cr)%Creset %C(blue)<%ae>%Creset" --abbrev-commit --all'
alias gtree='git log --graph --oneline --decorate --all' # Visual commit tree
alias gd='git diff'                                  # Show unstaged differences
alias gds='git diff --staged'                        # Show staged differences
alias gsh='git show'                                 # Show commit details
alias glast='git diff HEAD~1 HEAD'                   # What changed in last commit
alias gfiles='git diff --name-only main...HEAD'      # Files changed in current branch
alias gunpushed='git log @{u}..HEAD --oneline'     # Commits not yet pushed

# --- Undoing Things ---
alias gundo='git reset'                              # Undo to specific hash
alias gundos='git reset --soft HEAD~1'               # Undo last commit, keep staged
alias gundoh='git reset --hard HEAD~1'               # Hard reset, discard all changes
alias gundomh='git reset --mixed HEAD~1'             # Undo last commit, unstage changes
alias gst='git stash'                                # Stash changes
alias gsp='git stash pop'                            # Restore stashed changes
alias gsc='git clean -n'                             # Preview what clean would remove (safe)
alias grev='git revert'                              # Create undo commit (safe for shared)

# --- Rebase ---
alias grb='git rebase -i'                            # Interactive rebase
alias grbc='git rebase --continue'                   # Continue rebase after conflicts
alias grba='git rebase --abort'                      # Abort rebase

# --- Bisect & Other ---
alias ghb='git bisect'                               # Bisect to track down bugs
alias ghopen='open "https://github.com/$(git remote get-url origin | sed "s/.*github.com[:/]//" | sed "s/.git$//")"'
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
# ALIASES - HELIX
# =============================================================
alias hx='helix'                           # Open Helix editor

# =============================================================
# ALIASES - LAZYGIT & LAZYDOCKER
# =============================================================
alias lg='lazygit'                         # Open lazygit TUI
alias ld='lazydocker'                      # Open lazydocker TUI

# =============================================================
# ALIASES - NEW TOOLS
# =============================================================
# Note: http, rg, gping, dust, sd, ctop are used as plain commands below
# (no alias needed, since the command name already matches the tool name)
alias pp='prettyping'                      # Prettier ping
alias top='btop'                           # Better top/htop
alias myip='echo "Local: $(ipconfig getifaddr en0) | Public: $(curl -s ifconfig.me)"' # Show both IPs
alias pgcli='pgcli -U postgres'            # Better Postgres CLI with autocomplete

# =============================================================
# ALIASES - SECURITY
# =============================================================
alias connections='sudo lsof -i'                    # All open network connections
alias procs='ps aux | grep -v grep'                 # Clean process list
alias camon='lsof | grep -i "VDC\|AppleCamera"'    # Check camera usage
alias ports-all='netstat -an | grep LISTEN'         # All listening ports
alias rkhunt='sudo rkhunter --check'                # Run rootkit scan

# Unalias oh-my-zsh git plugin aliases that conflict with our functions
unalias gclean 2>/dev/null || true
unalias gbrm 2>/dev/null || true
unalias gsclean 2>/dev/null || true
unalias gundohc 2>/dev/null || true
unalias dkprune 2>/dev/null || true

# =============================================================
# FUNCTIONS
# =============================================================

# Make dir and cd into it
function mkcd { mkdir -p "$1" && cd "$1" }

# Quick add + commit + push
function gacp { git add . && git commit -m "$1" && git push }

# Kill process on port
function killport { lsof -ti tcp:$1 | xargs kill }

# Check common dev ports
function ports {
  echo "=== 8080 (Spring) ===" && lsof -ti tcp:8080 | xargs ps -p 2>/dev/null || echo "free"
  echo "=== 5432 (Postgres) ===" && lsof -ti tcp:5432 | xargs ps -p 2>/dev/null || echo "free"
  echo "=== 6379 (Redis) ===" && lsof -ti tcp:6379 | xargs ps -p 2>/dev/null || echo "free"
}

# Create new Spring Boot project
function springnew {
  mkcd "$1"
  echo "# $1" > README.md
  printf "target/\n.env\n*.log\n" > .gitignore
  git init
  open "https://start.spring.io"
}

# Create .env for Spring Boot
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

# Spring + Docker together
function springup { docker compose up -d && mvn spring-boot:run }
function springdown { docker compose down }

# Pretty print JSON
function jsonpp { echo "$1" | jq . }

# Stow / unstow a dotfile package
function stowit { cd ~/dotfiles && stow "$1" && cd - }
function unstowit { cd ~/dotfiles && stow -D "$1" && cd - }

# Run all security checks at once
function checksec {
  echo ""
  echo "=== SECURITY CHECK ==="
  echo ""
  echo "=== OPEN NETWORK CONNECTIONS ==="
  sudo lsof -i
  echo ""
  echo "=== CAMERA USAGE ==="
  lsof | grep -i "VDC\|AppleCamera"
  echo ""
  echo "=== LISTENING PORTS ==="
  netstat -an | grep LISTEN
  echo ""
  echo "=== RUNNING PROCESSES ==="
  ps aux | grep -v grep
  echo ""
  echo "=== ROOTKIT SCAN ==="
  sudo rkhunter --check
  echo ""
  echo "Security check complete"
}

# Delete branch with protection (local + remote)
function gbrm {
    protected="main master develop"
    for b in $protected; do
        if [[ "$1" == "$b" ]]; then
            echo "Protected branch '$1' -- use git directly if you really mean it."
            return 1
        fi
    done

    echo "Local branch: $1"
    git branch -vv | grep "$1" || true
    echo ""
    echo -n "Delete '$1' locally and on origin? [y/N] "
        read confirm
    if [[ $confirm == [yY] ]]; then
        git branch -d "$1" && git push origin --delete "$1"
        echo "Deleted."
    else
        echo "Cancelled."
    fi
}

# Docker prune with confirmation (removes ALL unused images, not just dangling)
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

# Git clean with confirmation (removes untracked files permanently)
function gsclean {
    echo -n "Remove all untracked files? This cannot be undone. [y/N] "
        read confirm
    if [[ $confirm == [yY] ]]; then
        git clean -fd
        echo "Cleaned."
    else
        echo "Cancelled."
    fi
}

# Hard reset with confirmation
function gundohc {
    echo -n "Hard reset to HEAD~1? ALL uncommitted changes will be LOST. [y/N] "
        read confirm
    if [[ $confirm == [yY] ]]; then
        git reset --hard HEAD~1
        echo "Reset."
    else
        echo "Cancelled."
    fi
}

# Dog DNS lookup (defined since it's referenced in help)
function dog { dig +short "$1" }

# Delete all merged branches except main/master/develop
function gclean {
    echo "Merged branches that will be deleted:"
    git branch --merged | grep -vE "^\*|main|master|develop"
    echo ""
    echo -n "Delete these branches? [y/N] "
    read confirm
    if [[ "$confirm" == [yY] ]]; then
        git branch --merged | grep -vE "^\*|main|master|develop" | xargs -r git branch -d
        echo "Cleaned."
    else
        echo "Cancelled."
    fi
}

# =============================================================
# ENVIRONMENTS - Activate/Deactivate virtual environments
# =============================================================
function enva {
    local candidates=(".venv" "venv" "env" ".env")
    local dir

    for dir in "${candidates[@]}"; do
        if [ -f "$dir/bin/activate" ]; then
            source "$dir/bin/activate"
            echo "Activated: $(pwd)/$dir"
            return 0
        fi
    done

    echo "No virtual environment found here (looked for: ${candidates[*]})."
    echo "Create one with: python3 -m venv .venv"
    return 1
}

function envd {
    if [ -n "$VIRTUAL_ENV" ]; then
        deactivate
        echo "Deactivated."
    else
        echo "No virtual environment is currently active."
    fi
}

# =============================================================
# HELP - Type 'help' to see all your shortcuts
# =============================================================
function help {
  cat << 'CHEATSHEET'

╔══════════════════════════════════════════════════════════════════╗
║                    TERMINAL CHEATSHEET                           ║
╚══════════════════════════════════════════════════════════════════╝

┌─ NAVIGATION ─────────────────────────────────────────────────────┐
│  ll              List files with details (eza -al)               │
│  ls              List files with icons (eza)                     │
│  lt              List files as tree (eza --tree)                 │
│  ..              Go up one folder                                │
│  ...             Go up two folders                               │
│  o               Open folder in Finder                           │
│  c               Clear terminal                                  │
│  mkcd <name>     Make directory and cd into it                   │
└──────────────────────────────────────────────────────────────────┘

┌─ CONFIG ─────────────────────────────────────────────────────────┐
│  reload          Reload terminal config                          │
│  zshrc           Edit terminal config in VS Code                 │
│  dotfiles        Open dotfiles folder in VS Code                 │
└──────────────────────────────────────────────────────────────────┘

┌─ NETWORK ────────────────────────────────────────────────────────┐
│  localip         Show your local IP                              │
│  publicip        Show your public IP                             │
│  killport <port> Kill process on port                            │
│  ports           Check dev ports status (8080, 5432, 6379)       │
│  myip            Show local + public IP in one shot              │
└──────────────────────────────────────────────────────────────────┘

┌─ GIT ─ DAILY WORKFLOW ───────────────────────────────────────────┐
│  g               git shorthand                                   │
│  gs              git status                                        │
│  ga <file>       Stage a file                                    │
│  gaa             Stage all files                                 │
│  gcm "msg"       Commit with message                             │
│  gacm "msg"      Add all + commit                                │
│  gacp "msg"      Add all + commit + push                         │
│  gp              Push to remote                                  │
│  gpul            Pull from remote                                │
│  gco <branch>    Checkout branch                                 │
│  gcb <name>      Create and checkout new branch                  │
│  gpsup           Push and set upstream origin                    │
└──────────────────────────────────────────────────────────────────┘

┌─ GIT ─ BRANCH MANAGEMENT ────────────────────────────────────────┐
│  gb              List branches                                   │
│  gbrm <name>     Delete branch (protected + confirm)             │
│  gclean          Delete all merged branches (confirm)            │
│  gm <branch>     Merge branch                                    │
│  gma             Abort merge                                     │
│  gmc             Continue merge after resolving conflicts          │
│  gmn <branch>    Merge with explicit merge commit                │
│  gms <branch>    Squash merge into single commit                 │
└──────────────────────────────────────────────────────────────────┘

┌─ GIT ─ HISTORY & DEBUGGING ──────────────────────────────────────┐
│  glog            Pretty graph log                                │
│  gtree           Visual commit tree (all branches)               │
│  gd              Show unstaged diff                              │
│  gds             Show staged diff                                │
│  gsh             Show commit details                             │
│  glast           What changed in last commit                     │
│  gfiles          Files changed in current branch vs main         │
│  gunpushed       Commits not yet pushed                          │
└──────────────────────────────────────────────────────────────────┘

┌─ GIT ─ UNDOING THINGS ───────────────────────────────────────────┐
│  gundo <hash>    Undo to specific commit hash                    │
│  gundos          Undo last commit, keep changes staged           │
│  gundoh          Hard reset, discard ALL changes                 │
│  gundohc         Hard reset with confirmation                    │
│  gundomh         Undo last commit, unstage changes             │
│  grev            Create undo commit (safe for shared branches)   │
│  gst             Stash changes                                   │
│  gsp             Restore stashed changes                         │
│  gsc             Preview what clean would remove (safe)          │
│  gsclean         Remove untracked files (with confirmation)      │
└──────────────────────────────────────────────────────────────────┘

┌─ GIT ─ REBASE ───────────────────────────────────────────────────┐
│  grb             Interactive rebase                              │
│  grbc            Continue rebase after resolving conflicts       │
│  grba            Abort rebase                                    │
└──────────────────────────────────────────────────────────────────┘

┌─ GIT ─ BISECT ───────────────────────────────────────────────────┐
│  ghb start       Start bisect session                            │
│  ghb bad         Mark current commit as bad                      │
│  ghb good <sha>  Mark a known-good commit                        │
│  ghb reset       End bisect session                              │
│  ghopen          Open repo on GitHub in browser                  │
└──────────────────────────────────────────────────────────────────┘

┌─ MAVEN ──────────────────────────────────────────────────────────┐
│  mvnr            Run Spring Boot app                             │
│  mvni            Clean install                                   │
│  mvnc            Clean build                                     │
│  mvnt            Run tests                                       │
│  mvnci           Install, skip tests                             │
└──────────────────────────────────────────────────────────────────┘

┌─ DOCKER ─ CONTAINERS ────────────────────────────────────────────┐
│  dkps            List running containers                           │
│  dklog <name>    Follow container logs                           │
│  dkex <name>     Enter container shell                           │
│  dkprune         Remove all unused Docker data (confirm)           │
└──────────────────────────────────────────────────────────────────┘

┌─ DOCKER ─ COMPOSE ───────────────────────────────────────────────┐
│  dkcu            Start containers (detached)                       │
│  dkcd            Stop containers                                   │
│  dkcub           Rebuild and start                                 │
└──────────────────────────────────────────────────────────────────┘

┌─ POSTGRESQL ─────────────────────────────────────────────────────┐
│  pgstart         Start PostgreSQL                                  │
│  pgstop          Stop PostgreSQL                                   │
│  pgconn          Connect as postgres user                          │
└──────────────────────────────────────────────────────────────────┘

┌─ REDIS ──────────────────────────────────────────────────────────┐
│  redstart        Start Redis                                       │
│  redstop         Stop Redis                                        │
│  redcli          Open Redis CLI                                    │
└──────────────────────────────────────────────────────────────────┘

┌─ GHOSTTY ────────────────────────────────────────────────────────┐
│  ghostty-config  Edit Ghostty config                               │
│  ghostty-reload  Reload Ghostty                                    │
└──────────────────────────────────────────────────────────────────┘

┌─ EDITORS / TUI ──────────────────────────────────────────────────┐
│  hx              Open Helix editor                                 │
│  lg              Open lazygit TUI                                  │
│  ld              Open lazydocker TUI                               │
└──────────────────────────────────────────────────────────────────┘

┌─ SPRING / PROJECT ───────────────────────────────────────────────┐
│  springnew <n>   Scaffold Spring Boot project                      │
│  envnew          Create .env template                                │
│  springup        Docker up + mvn run                                 │
│  springdown      Docker compose down                                 │
└──────────────────────────────────────────────────────────────────┘

┌─ PYTHON ENVIRONMENTS ────────────────────────────────────────────┐
│  enva            Activate virtual environment                      │
│  envd            Deactivate virtual environment                      │
└──────────────────────────────────────────────────────────────────┘

┌─ SECURITY ───────────────────────────────────────────────────────┐
│  connections     All open network connections                        │
│  procs           Clean running process list                        │
│  camon           Check what is using your camera                     │
│  ports-all       All listening ports                                 │
│  rkhunt          Run rootkit scan                                    │
│  checksec        Run ALL security checks at once                   │
└──────────────────────────────────────────────────────────────────┘

┌─ AWS ─ DAY-TO-DAY (awshelp for full list) ───────────────────────┐
│  awswho          Who am I / current identity                        │
│  awsp <profile>  Switch AWS profile for this session                │
│  ec2ls           List instances (id/state/type/name)                │
│  ec2ssh <id>     Shell into instance via SSM                        │
│  ec2ip <id>      Get instance public IP                             │
│  s3l             List all buckets                                   │
│  s3lsr <bucket>  List files in bucket (recursive)                   │
│  s3sync <a> <b>  Sync local dir <-> bucket                          │
│  logstail <grp>  Live-tail a CloudWatch log group                   │
│  logserr <grp>   Filter log group for errors                        │
│  lfninv <fn>     Invoke a Lambda function                           │
│  ddbscan <tbl>   Dump all items in a DynamoDB table                 │
│  ssmget <name>   Decrypt an SSM parameter                           │
│  awscost         Month-to-date cost by service                      │
└──────────────────────────────────────────────────────────────────┘

┌─ UTILITIES ──────────────────────────────────────────────────────┐
│  http            HTTPie - test HTTP endpoints                        │
│  pp              Prettier ping                                       │
│  top             Better top (btop)                                   │
│  pgcli           Better Postgres CLI with autocomplete               │
│  ctop            Container monitoring                                │
│  rg <pattern>    Ripgrep - fast codebase search                      │
│  gping <host>    Ping with live graph                                │
│  dog <domain>    DNS lookup                                          │
│  dust            Disk usage visualizer                               │
│  sd <old> <new>  Smarter sed for refactoring                         │
│  jsonpp <json>   Pretty print JSON                                   │
│  stowit <pkg>    Stow a dotfile package                              │
│  unstowit <pkg>  Unstow a dotfile package                            │
└──────────────────────────────────────────────────────────────────┘

CHEATSHEET
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
      print "Welcome back, $(whoami)!"
      print "$(date '+%A, %d %B %Y')"
      print "Type 'help' to see all your shortcuts"
    fi
  }
}

# =============================================================
# POWERLEVEL10K (keep near the bottom)
# =============================================================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# =============================================================
# SDKMAN
# THIS MUST BE AT THE VERY END OF THE FILE FOR SDKMAN TO WORK!!!
# =============================================================
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"