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

# Your public IP can change (different wifi, mobile data, VPN, etc.), and
# the "ssh-only" security group only allows SSH from whichever IP was
# authorized last. If they no longer match, SSH silently times out instead
# of failing fast — so we auto-authorize the CURRENT IP here every time,
# before attempting to connect. This makes IP changes a non-issue going
# forward. (Old stale IP rules are left in place rather than auto-revoked,
# to avoid accidentally locking out a second device/location you use.)
MY_IP=$(curl -s --max-time 5 ifconfig.me)
if [[ -n "$MY_IP" ]]; then
  echo "Ensuring $MY_IP is allowed through the ssh-only security group..."
  aws ec2 authorize-security-group-ingress --group-name ssh-only \
    --protocol tcp --port 22 --cidr "${MY_IP}/32" &>/dev/null || true
else
  echo "Warning: couldn't detect current public IP — skipping security group check."
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
# No "set -e" here on purpose: this script must NOT abort partway through
# on a single failed/missing package, or the crucial zshrc copy step back
# on the local machine (which only runs after this whole ssh call returns)
# never happens. Each step below handles its own failure instead.

sudo yum install -y zsh git jq lsof nc cronie || sudo dnf install -y zsh git jq lsof nc cronie
sudo systemctl enable --now crond 2>/dev/null || true

# Oh My Zsh's installer overwrites ~/.zshrc with its own template —
# that's expected here, since we replace it with our custom one AFTER.
# Only run it if not already installed: the installer refuses (and would
# otherwise print a scary-looking but harmless error) if it's already there.
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "Oh My Zsh already installed — skipping installer."
fi

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

[ -d "$ZSH_CUSTOM/themes/powerlevel10k" ] || \
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"

[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] || \
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] || \
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

sudo yum install -y util-linux-user || sudo dnf install -y util-linux-user || true

# chsh can report "Shell not changed" while still exiting 0, so check the
# actual result afterward rather than trusting chsh's own exit code.
sudo chsh -s "$(which zsh)" ec2-user >/dev/null 2>&1
CURRENT_SHELL=$(getent passwd ec2-user | cut -d: -f7)
if [ "${CURRENT_SHELL##*/}" != "zsh" ]; then
  sudo usermod -s "$(which zsh)" ec2-user
fi

# Auto-stop safety net: if the instance is ever left running overnight,
# it stops itself at midnight (server local time, usually UTC) instead of
# burning free-tier hours or racking up cost unnoticed. This uses a plain
# OS shutdown, not the AWS API — no IAM permissions needed. For an
# EBS-backed instance this results in a STOP, not a terminate, so nothing
# is lost. Skipped gracefully if crontab still isn't available.
if command -v crontab >/dev/null 2>&1; then
  (crontab -l 2>/dev/null | grep -v 'shutdown -h now'; echo "0 0 * * * sudo shutdown -h now") | crontab -
else
  echo "crontab not available — skipping auto-stop setup."
fi

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
