#!/bin/zsh
# =============================================================
# ec2-provision.sh
# Runs from your Mac. Waits for SSH, copies ec2.zshrc over,
# and installs zsh + oh-my-zsh + p10k on the remote instance.
#
# Usage: ec2-provision.sh <public-ip>
# =============================================================
set -e

IP="$1"
KEY="$HOME/.ssh/my-ec2-key.pem"
LOCAL_ZSHRC="$HOME/dotfiles/ec2.zshrc"

if [[ -z "$IP" ]]; then
  echo "Usage: ec2-provision.sh <public-ip>"
  exit 1
fi

echo "Waiting for SSH to be ready on $IP..."
until ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=5 \
  -i "$KEY" ec2-user@"$IP" "echo ok" &>/dev/null; do
  sleep 5
  echo "...still waiting"
done

echo "SSH is up. Copying zshrc..."
scp -i "$KEY" "$LOCAL_ZSHRC" ec2-user@"$IP":~/.zshrc

echo "Installing zsh + oh-my-zsh + plugins on remote host..."
ssh -i "$KEY" ec2-user@"$IP" bash -s << 'REMOTE_SCRIPT'
set -e

sudo yum install -y zsh git jq lsof nc || sudo dnf install -y zsh git jq lsof nc

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

[ -d "$ZSH_CUSTOM/themes/powerlevel10k" ] || \
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"

[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] || \
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] || \
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

sudo chsh -s "$(which zsh)" ec2-user

echo "Remote provisioning complete."
REMOTE_SCRIPT

echo ""
echo "Done. Reconnect with ec2-ssh to see your shell."
