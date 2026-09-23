#!/bin/zsh
# =============================================================
# ec2-provision.sh
# Runs from your Mac. Waits for SSH, installs zsh + oh-my-zsh +
# p10k on the remote instance (skipping if already done), copies
# your custom zshrc in last, then verifies the shell actually
# switched to zsh.
#
# Usage: ec2-provision.sh <public-ip>
# =============================================================
set -e

IP="$1"
KEY="$HOME/.ssh/my-ec2-key.pem"
LOCAL_ZSHRC="$HOME/dotfiles/ec2.zshrc"

if [[ -z "$IP" || "$IP" == "None" ]]; then
  echo "Usage: ec2-provision.sh <public-ip>"
  exit 1
fi

# Since we reuse the same Elastic IP across different instances, each new
# instance has a different SSH host key. Clear any stale entry for this IP
# so SSH doesn't reject the connection as a "changed host key" — without
# this, ec2-launch would hang indefinitely on "still waiting" instead of
# ever actually failing or succeeding.
ssh-keygen -R "$IP" &>/dev/null || true

echo "Waiting for SSH to be ready on $IP..."
until ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=5 \
  -i "$KEY" ec2-user@"$IP" "echo ok" &>/dev/null; do
  sleep 5
  echo "...still waiting"
done

echo "Checking if this instance is already provisioned..."
ALREADY_DONE=$(ssh -i "$KEY" ec2-user@"$IP" '[ -f ~/.provisioned ] && echo yes || echo no')

if [[ "$ALREADY_DONE" == "yes" ]]; then
  echo "Already provisioned (found ~/.provisioned) — skipping install, just refreshing zshrc..."
else
  echo "Installing zsh + oh-my-zsh + plugins on remote host..."
  ssh -i "$KEY" ec2-user@"$IP" bash -s << 'REMOTE_SCRIPT'
set -e

sudo yum install -y zsh git jq lsof nc || sudo dnf install -y zsh git jq lsof nc

# Oh My Zsh's installer overwrites ~/.zshrc with its own template —
# that's expected here, since we replace it with our custom one AFTER
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

[ -d "$ZSH_CUSTOM/themes/powerlevel10k" ] || \
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"

[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] || \
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] || \
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

sudo yum install -y util-linux-user || sudo dnf install -y util-linux-user || true
sudo chsh -s "$(which zsh)" ec2-user || sudo usermod -s "$(which zsh)" ec2-user

touch ~/.provisioned
echo "Remote provisioning complete."
REMOTE_SCRIPT
fi

echo "Copying your custom zshrc over..."
scp -i "$KEY" "$LOCAL_ZSHRC" ec2-user@"$IP":~/.zshrc

echo "Verifying the shell actually switched to zsh..."
REMOTE_SHELL=$(ssh -i "$KEY" ec2-user@"$IP" 'getent passwd ec2-user | cut -d: -f7')

if [[ "$REMOTE_SHELL" == *zsh ]]; then
  echo "Verified: ec2-user's shell is $REMOTE_SHELL"
else
  echo "WARNING: ec2-user's shell is still '$REMOTE_SHELL', not zsh."
  echo "Run this manually on the instance to fix it:"
  echo "  sudo usermod -s \$(which zsh) ec2-user"
fi

echo ""
echo "Done. Reconnect with ec2-ssh to see your shell."
