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
# zoxide (below) replaces the `z` plugin, fzf is loaded via `fzf --zsh` below;
# syntax-highlighting and history-substring-search must be last (↑/↓ keybindings)
plugins=(git zsh-autosuggestions zsh-syntax-highlighting history-substring-search)
source $ZSH/oh-my-zsh.sh

# Remove oh-my-zsh aliases that clash with our functions below
# (must run BEFORE those functions are defined; gbd: omz has 'git branch -d', we use gbrm)
for _a in gbd gclean gbrm gsclean gundohc dkprune; do unalias $_a 2>/dev/null; done; unset _a

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
setopt HIST_REDUCE_BLANKS
setopt HIST_FIND_NO_DUPS

# =============================================================
# EDITOR
# =============================================================
# --wait: git (rebase -i, commit) must wait for VS Code to close the file
export EDITOR='code --wait'
export VISUAL='code --wait'

# =============================================================
# PATH & TOOLS
# =============================================================
# Homebrew shell environment (must come first — other tool paths below assume it)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Keep PATH entries unique (so re-sourcing never duplicates them)
typeset -U path PATH

export PATH="$HOME/.local/bin:$PATH"

# PostgreSQL
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

# Java (openjdk via Homebrew, kept as dependency for gradle/jdtls/kafka/tomcat)
export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && source "/opt/homebrew/opt/nvm/nvm.sh" --no-use

# FZF (needs fzf >= 0.48; replaces the oh-my-zsh fzf plugin and ~/.fzf.zsh)
command -v fzf >/dev/null && source <(fzf --zsh)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --border'

# =============================================================
# AWS CLI SHORTCUTS (type `awshelp` for the list)
# =============================================================
export AWS_PAGER=""   # Don't open `less` for long AWS CLI output
[ -f ~/dotfiles/zsh/aws-cli-shortcuts.sh ] && source ~/dotfiles/zsh/aws-cli-shortcuts.sh

# =============================================================
# SHELL INIT (zoxide, pyenv, direnv, envman)
# =============================================================
# Zoxide (--cmd cd makes it replace cd; also provides z / zi)
eval "$(zoxide init zsh --cmd cd)"

# Pyenv
eval "$(pyenv init -)"

# Direnv
eval "$(direnv hook zsh)"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# =============================================================
# GENERAL
# =============================================================
alias reload='exec zsh'              # Restart shell (reloads config cleanly)
alias zshrc='code ~/.zshrc'          # Edit terminal config
alias dotfiles='code ~/dotfiles'     # Open dotfiles folder
alias ll='eza -al --icons'           # List files with details
alias ls='eza --icons'               # List files with icons
alias lt='eza --tree --icons'        # List files as a tree
alias cat='bat'                      # Better file viewer (bat)
alias ..='cd ..'                     # Go up one folder
alias ...='cd ../..'                 # Go up two folders
alias o='open .'                     # Open current folder in Finder
alias c='clear'                      # Clear terminal
alias copy='pbcopy'                  # Copy stdin to clipboard (pipe into it)

# =============================================================
# NETWORK
# =============================================================
alias myip='echo "Local: $(ipconfig getifaddr en0) | Public: $(curl -s ifconfig.me)"' # Local + public IP (also: localip, publicip)
alias localip='ipconfig getifaddr en0'              # Show local IP
alias publicip='curl -s ifconfig.me'                # Show public IP
alias connections='sudo lsof -i'                    # All open network connections
alias ports-all='netstat -an | grep LISTEN'         # All listening ports
alias pp='prettyping'                               # Prettier ping
#? gping <host> | Ping with a live graph
#? http | HTTPie - test HTTP endpoints

# <port> | Kill process on port
function killport { lsof -ti tcp:"$1" | xargs kill }

# Check dev ports (8080, 5432, 6379)
function ports {
  local entry p
  for entry in "8080:Spring" "5432:Postgres" "6379:Redis"; do
    p=${entry%%:*}
    echo "=== $p (${entry#*:}) ==="
    lsof -nP -iTCP:$p -sTCP:LISTEN || echo "free"
  done
}

# <domain> | DNS lookup
function dog { dig +short "$1" }

# =============================================================
# GIT
# =============================================================

# --- Daily Workflow ---
alias g='git'                                        # Shorthand for git
alias gs='git status'                                # Show changes
alias ga='git add'                                   # <file> | Stage a file
alias gaa='git add .'                                # Stage all files
alias gcm='git commit -m'                            # "msg" | Commit with message
alias gacm='git add . && git commit -m'              # "msg" | Add all and commit
alias gp='git push'                                  # Push to remote
alias gpul='git pull'                                # Pull from remote
alias gco='git checkout'                             # <branch> | Switch branch
alias gcb='git checkout -b'                          # <name> | Create new branch
alias gpsup='git push --set-upstream origin $(git_current_branch)'   # Push and set upstream origin
alias ghopen='open "https://github.com/$(git remote get-url origin | sed "s/.*github.com[:/]//" | sed "s/.git$//")"'   # Open repo on GitHub in browser

# "msg" | Add all + commit + push
function gacp { git add . && git commit -m "$1" && git push }

# --- Branch Management ---
alias gb='git branch'                                # List branches
alias gm='git merge'                                 # <branch> | Merge branch
alias gma='git merge --abort'                        # Abort merge
alias gmc='git merge --continue'                     # Continue merge after conflicts
alias gmn='git merge --no-ff'                        # <branch> | Merge with explicit merge commit
alias gms='git merge --squash'                       # <branch> | Squash all commits into one

# <name> | Delete local + remote branch (confirm)
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

# Delete all merged branches (confirm)
function gclean {
    echo "Merged branches that will be deleted:"
    git branch --merged | grep -vE '^\*|^[[:space:]]*(main|master|develop)$'
    echo ""
    echo -n "Delete these branches? [y/N] "
    read confirm
    if [[ "$confirm" == [yY] ]]; then
        git branch --merged | grep -vE '^\*|^[[:space:]]*(main|master|develop)$' | xargs -r git branch -d
        echo "Cleaned."
    else
        echo "Cancelled."
    fi
}

# --- History & Debugging ---
alias glog='git log --graph --pretty=format:"%C(yellow)%h%Creset -%C(cyan)%d%Creset %s %C(green)(%cr)%Creset %C(blue)<%ae>%Creset" --abbrev-commit --all'   # Pretty graph log
alias gtree='git log --graph --oneline --decorate --all' # Visual commit tree (all branches)
alias gd='git diff'                                  # Show unstaged differences
alias gds='git diff --staged'                        # Show staged differences
alias gsh='git show'                                 # Show commit details
alias glast='git diff HEAD~1 HEAD'                   # What changed in last commit
alias gfiles='git diff --name-only main...HEAD'      # Files changed in this branch vs main
alias gunpushed='git log @{u}..HEAD --oneline'       # Commits not yet pushed

# --- Undoing Things ---
alias gundo='git reset'                              # <hash> | Reset to a specific commit
alias gundos='git reset --soft HEAD~1'               # Undo last commit, keep changes staged
alias gundoh='gundohc'                               # Hard reset (always asks first)
alias gundomh='git reset --mixed HEAD~1'             # Undo last commit, unstage changes
alias gst='git stash'                                # Stash changes
alias gsp='git stash pop'                            # Restore stashed changes
alias gsc='git clean -n'                             # Preview what clean would remove (safe)
alias grev='git revert'                              # Create undo commit (safe for shared)

# Hard reset to HEAD~1 (confirm)
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

# Remove untracked files (confirm)
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

# --- Rebase & Bisect ---
alias grb='git rebase -i'                            # Interactive rebase
alias grbc='git rebase --continue'                   # Continue rebase after conflicts
alias grba='git rebase --abort'                      # Abort rebase
alias ghb='git bisect'                               # Bisect: start / bad / good <sha> / reset

# =============================================================
# DOCKER & DATABASES
# =============================================================
alias dkps='docker ps'               # List running containers
alias dklog='docker logs -f'         # <name> | Follow container logs
alias dkex='docker exec -it'         # <name> | Enter container shell
alias dkcu='docker compose up -d'    # Start containers
alias dkcd='docker compose down'     # Stop containers
alias dkcub='docker compose up --build' # Rebuild and start containers
alias pgstart='brew services start postgresql@16' # Start Postgres
alias pgstop='brew services stop postgresql@16'   # Stop Postgres
alias pgconn='psql -U postgres'      # Connect to Postgres as postgres
alias pgcli='pgcli -U postgres'      # Postgres CLI with autocomplete
alias redstart='brew services start redis' # Start Redis
alias redstop='brew services stop redis'   # Stop Redis
alias redcli='redis-cli'             # Open Redis CLI

# Remove all unused Docker data (confirm)
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
# JAVA & SPRING
# =============================================================
alias mvnc='mvn clean'               # Clean build
alias mvni='mvn clean install'       # Clean and install
alias mvnr='mvn spring-boot:run'     # Run Spring Boot app
alias mvnt='mvn test'                # Run tests
alias mvnci='mvn clean install -DskipTests' # Install, skip tests

# <name> | Scaffold Spring Boot project
function springnew {
  mkcd "$1"
  echo "# $1" > README.md
  printf "target/\n.env\n*.log\n" > .gitignore
  git init
  open "https://start.spring.io"
}

# Create .env template for Spring Boot
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

function springup { docker compose up -d && mvn spring-boot:run }  # Docker compose up + mvn spring-boot:run
function springdown { docker compose down }                        # Docker compose down

# =============================================================
# PYTHON
# =============================================================
# Activate virtual environment
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

# Deactivate virtual environment
function envd {
    if [ -n "$VIRTUAL_ENV" ]; then
        deactivate
        echo "Deactivated."
    else
        echo "No virtual environment is currently active."
    fi
}

# =============================================================
# TERRAFORM
# =============================================================
alias tf='terraform'                                 # Shorthand for terraform
alias tfi='terraform init'                           # Initialise working dir
alias tfiu='terraform init -upgrade'                 # Init and upgrade providers
alias tfv='terraform validate'                       # Validate config
alias tff='terraform fmt -recursive'                 # Format all .tf files
alias tfp='terraform plan'                           # Preview changes
alias tfa='terraform apply'                          # Apply changes (asks to confirm)
alias tfo='terraform output'                         # Show outputs
alias tfs='terraform state list'                     # List resources in state
alias tfw='terraform workspace'                      # Manage workspaces
alias tfr='terraform providers'                      # Show required providers

# Terraform destroy (extra confirmation)
function tfd {
    echo -n "Run 'terraform destroy' in $(pwd)? [y/N] "
    read confirm
    if [[ $confirm == [yY] ]]; then
        terraform destroy "$@"
    else
        echo "Cancelled."
    fi
}

# Terraform plan, save, confirm, apply that plan
function tfpa {
    terraform plan -out=tfplan && \
    echo -n "Apply this saved plan? [y/N] " && read confirm && \
    [[ $confirm == [yY] ]] && terraform apply tfplan; rm -f tfplan
}

# =============================================================
# SECURITY
# =============================================================
alias procs='ps aux | grep -v grep'                 # Clean process list
alias camon='lsof | grep -i "VDC\|AppleCamera"'    # Check what is using the camera
alias rkhunt='sudo rkhunter --check'                # Run rootkit scan

# Run ALL security checks at once
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

# =============================================================
# TERMINAL & TOOLS
# =============================================================
alias ghostty-config='code ~/.config/ghostty/config' # Edit Ghostty config
alias ghostty-reload='pkill -USR1 ghostty'            # Reload Ghostty
alias hx='helix'                           # Open Helix editor
alias lg='lazygit'                         # Open lazygit TUI
alias ld='lazydocker'                      # Open lazydocker TUI
alias top='btop'                           # Better top/htop (btop)
# Note: rg, sd, dust, ctop are used as plain commands (no alias needed)
#? rg <pattern> | Ripgrep - fast codebase search
#? sd <old> <new> | Smarter sed for refactoring
#? dust | Disk usage visualizer
#? ctop | Container monitoring

# <dir> | Make directory and cd into it
function mkcd { mkdir -p "$1" && cd "$1" }

# <json> | Pretty print JSON
function jsonpp { echo "$1" | jq . }

function stowit { cd ~/dotfiles && stow "$1" && cd - }       # <pkg> | Stow a dotfile package
function unstowit { cd ~/dotfiles && stow -D "$1" && cd - }  # <pkg> | Unstow a dotfile package

# Auto-correct last mistyped command (thefuck, lazy-loaded)
fuck() {
  unfunction fuck
  eval "$(thefuck --alias)"
  eval "fuck"
}

# =============================================================
# HELP - Type 'help' for the commands you might forget
# =============================================================
# Built from this file's own section banners and "# description" comments, so
# anything you add shows up automatically. Conventions:
#   alias x='...'   # description             (alias)
#   alias x='...'   # <args> | description    (alias, with a usage hint)
#   function x {    # description / <args> | description  (or a comment line above it)
#   #? tool <args> | description              (document a plain command, no alias)
# Basic/obvious commands listed in _HELP_HIDE are hidden; `help -a` shows them too.
_ZSHRC_FILE="${(%):-%x}"
_HELP_HIDE=" ll ls cat .. ... c reload zshrc dotfiles localip publicip g gs ga gaa gcm gacm gp gpul gco gcb gb gm gma gd gds gsh gst gsp gundoh dkps dkcu dkcd pgstart pgstop redstart redstop mvnc mvni mvnr mvnt tf tfi tfp tfa tfv "

function help {
  local all=0
  [[ "$1" == "-a" ]] && { all=1; shift; }
  awk -v q="$1" -v all="$all" -v hide="$_HELP_HIDE" '
  function rep(s, n,   r) { r = ""; while (n-- > 0) r = r s; return r }
  function add(name, d,   p, key) {
      if (name ~ /^_/ || name == "help" || sec == 0) return
      key = name; sub(/ .*/, "", key)
      if (!all && index(hide, " " key " ")) return
      p = index(d, " | ")
      if (p) { name = name " " substr(d, 1, p - 1); d = substr(d, p + 3) }
      if (length(d) > 58) d = substr(d, 1, 55) "..."
      n = ++cnt[sec]; nm[sec, n] = name; ds[sec, n] = d
      if (length(name) > nw) nw = length(name)
      if (length(d) > dw)    dw = length(d)
  }
  { prevc = pc; pc = ($0 ~ /^# [^=-]/) ? substr($0, 3) : "" }
  /^# =+$/ { inban = !inban; got = 0; next }
  inban && /^# / {
      if (!got) {
          t = substr($0, 3); sub(/^ALIASES - /, "", t)
          p = index(t, " - "); if (p) t = substr(t, 1, p - 1)
          base = t; sec = ++ns; title[sec] = t; got = 1
      }
      next
  }
  /^# --- .* ---$/ { t = $0; sub(/^# --- /, "", t); sub(/ ---$/, "", t); sec = ++ns; title[sec] = base " - " t; next }
  /^#\? / { d = substr($0, 4); p = index(d, " | "); if (p) add(substr(d, 1, p - 1), substr(d, p + 3)); next }
  /^alias[[:space:]]+[A-Za-z0-9_.-]+=/ && /[[:space:]]#[[:space:]]/ {
      line = $0; sub(/^alias[[:space:]]+/, "", line); name = line; sub(/=.*/, "", name)
      d = $0; sub(/.*[[:space:]]#[[:space:]]/, "", d); add(name, d); next
  }
  /^function[[:space:]]+[A-Za-z0-9_-]+/ || /^[A-Za-z0-9_-]+\(\)[[:space:]]*\{/ {
      line = $0; sub(/^function[[:space:]]+/, "", line); name = line; sub(/[^A-Za-z0-9_-].*/, "", name)
      if ($0 ~ /\{.*[[:space:]]#[[:space:]]/) { d = $0; sub(/.*[[:space:]]#[[:space:]]/, "", d) } else d = prevc
      if (d != "") add(name, d)
      next
  }
  END {
      nw += 2
      W = 2 + nw + dw + 2
      head = "TERMINAL CHEATSHEET"
      lp = int((W - length(head)) / 2)
      print ""
      print "╔" rep("═", W) "╗"
      print "║" rep(" ", lp) head rep(" ", W - lp - length(head)) "║"
      print "╚" rep("═", W) "╝"
      for (s = 1; s <= ns; s++) {
          if (!cnt[s]) continue
          if (q != "" && tolower(title[s]) !~ tolower(q)) continue
          shown++
          print ""
          print "┌─ " title[s] " " rep("─", W - length(title[s]) - 3) "┐"
          for (i = 1; i <= cnt[s]; i++) {
              row = sprintf("%-" nw "s%s", nm[s, i], ds[s, i])
              print "│  " row rep(" ", W - 2 - length(row)) "│"
          }
          print "└" rep("─", W) "┘"
      }
      if (q != "" && !shown) print "\n  No section matching \"" q "\". Run help with no argument to see all."
      print ""
      print "  help <section> filters  |  help -a shows basic commands too  |  awshelp for AWS"
      print ""
  }' "$_ZSHRC_FILE"
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
      print "Type 'help' to see the commands you might forget"
    fi
  }
}

# =============================================================
# POWERLEVEL10K (keep near the bottom)
# =============================================================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# =============================================================
# LOCAL OVERRIDES (untracked, machine-specific: EC2_ID, tokens, ...)
# Keep this file OUT of the dotfiles repo. Must stay before SDKMAN.
# =============================================================
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# =============================================================
# SDKMAN
# THIS MUST BE AT THE VERY END OF THE FILE FOR SDKMAN TO WORK!!!
# =============================================================
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
