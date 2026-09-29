# =============================================================
# Add to your Mac shell rc (works in both zsh and bash).
# Expects these files in ~/dotfiles/multipass/:
#   cloud-init.yaml   dev.bashrc
# =============================================================

export DEV_VM=devbox
export DEV_DOTFILES="$HOME/dotfiles/multipass"

# Push dev.bashrc into the VM as ~/.dev_bashrc (sourced by ~/.bashrc)
_dev-push-bashrc() {
  multipass transfer "$DEV_DOTFILES/dev.bashrc" "$DEV_VM:/tmp/dev_bashrc" &&
  multipass exec "$DEV_VM" -- sudo install -o ubuntu -g ubuntu -m 0644 /tmp/dev_bashrc /home/ubuntu/.dev_bashrc
}

# Launch a fresh VM provisioned by cloud-init, then push the bash aliases.
dev-launch() {
  if multipass info "$DEV_VM" &>/dev/null; then
    echo "VM '$DEV_VM' already exists. Use dev-start to boot it, or dev-delete to remove it first."
    return 1
  fi
  echo "Launching $DEV_VM (Ubuntu 24.04, 2 CPUs, 2GB RAM, 20GB disk)..."
  multipass launch 24.04 --name "$DEV_VM" --cpus 2 --memory 2G --disk 20G \
    --timeout 600 --cloud-init "$DEV_DOTFILES/cloud-init.yaml" || return 1
  echo "Waiting for provisioning (apt packages, docker, jdk)..."
  until multipass exec "$DEV_VM" -- test -f /home/ubuntu/.provisioned 2>/dev/null; do
    sleep 3
    echo "...still provisioning"
  done
  _dev-push-bashrc
  echo "Done. Connect with: dev-ssh"
}

# Open a shell inside the VM
dev-ssh()    { multipass shell "$DEV_VM"; }
dev-stop()   { multipass stop "$DEV_VM" && echo "$DEV_VM stopped."; }
dev-start()  { multipass start "$DEV_VM" && echo "$DEV_VM started. Connect with: dev-ssh"; }
dev-status() { multipass info "$DEV_VM"; }

# Permanently remove the VM and reclaim disk space.
dev-delete() {
  local reply
  printf "Permanently delete %s? Type yes: " "$DEV_VM"
  read -r reply
  if [ "$reply" = "yes" ]; then
    multipass delete --purge "$DEV_VM"
    echo "Deleted."
  else
    echo "Cancelled."
    return 1
  fi
}

# Full reset: delete + relaunch clean
dev-reset() {
  dev-delete && dev-launch
}

# Refresh aliases on an EXISTING VM without relaunching
dev-reprovision() {
  _dev-push-bashrc && echo "dev.bashrc refreshed on $DEV_VM. Run 'reload' inside the VM."
}

# --- Upgrades -------------------------------------------------

# Share a Mac folder into the VM (edit on Mac, run in VM)
dev-mount() {
  local src="${1:-$HOME/projects}"
  mkdir -p "$src"
  multipass mount "$src" "$DEV_VM:/home/ubuntu/projects" && echo "Mounted $src -> ~/projects"
}

# Snapshot / restore (needs a stopped VM; Multipass 1.13+)
dev-snapshot() {
  local name="${1:-clean-base}"
  multipass stop "$DEV_VM" && multipass snapshot "$DEV_VM" --name "$name" && echo "Snapshot '$name' saved."
}
dev-restore() {
  local name="${1:-clean-base}"
  multipass stop "$DEV_VM" 2>/dev/null
  multipass restore --destructive "$DEV_VM.$name" && echo "Restored to '$name'. Start with: dev-start"
}
dev-snapshots() { multipass list --snapshots; }
