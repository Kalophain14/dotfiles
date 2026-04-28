# Add this to your .zshrc
help() {
  echo "
  ====== YOUR ALIASES ======

  📁 NAVIGATION
  ll        - list files with details
  ls        - list files with icons
  lt        - list files as tree
  ..        - go up one folder
  ...       - go up two folders
  o         - open current folder in Finder

  🔧 GENERAL
  reload    - reload zshrc
  zshrc     - open zshrc in VS Code
  dotfiles  - open dotfiles in VS Code
  c         - clear terminal

  🌐 NETWORK
  localip   - show your local IP
  publicip  - show your public IP

  🐙 GIT
  gs        - git status
  ga        - git add
  gaa       - git add all
  gcm       - git commit -m
  gp        - git push
  gpul      - git pull
  gco       - git checkout
  gcb       - git checkout -b new branch
  glog      - pretty git log
  gundo     - undo last commit
  gacp      - add, commit and push in one go

  🐳 DOCKER
  dkps      - list containers
  dklog     - follow container logs
  dkcu      - docker compose up
  dkcd      - docker compose down
  dkcub     - docker compose up with build
  dkprune   - remove all unused docker data

  ☕ MAVEN
  mvnc      - maven clean
  mvni      - maven clean install
  mvnr      - spring boot run
  mvnt      - maven test
  mvnci     - clean install skip tests

  🐘 POSTGRESQL
  pgstart   - start postgres
  pgstop    - stop postgres
  pgconn    - connect to postgres

  🔴 REDIS
  redstart  - start redis
  redstop   - stop redis
  redcli    - open redis cli

  👻 GHOSTTY
  ghostty-config  - open ghostty config
  ghostty-reload  - reload ghostty

  📦 STOW
  stowit    - stow a dotfile package
  unstowit  - unstow a dotfile package
  "
}