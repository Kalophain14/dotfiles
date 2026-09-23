# dotfiles

Personal shell environment and automated EC2 dev-instance provisioning.

## What this does

- **`ec2.zshrc`** — a Linux-specific zsh config (stripped of Mac-only tooling
  like Homebrew/pyenv) with a colored prompt, git/docker/systemd/package
  aliases, and a `help` command that prints a full cheatsheet.
- **`ec2-provision.sh`** — runs from my Mac. Waits for SSH on a fresh EC2
  instance, installs zsh + Oh My Zsh + Powerlevel10k + plugins, copies
  `ec2.zshrc` in, switches the default shell to zsh, sets up an auto-stop
  cron job as a cost safety net, and verifies the switch actually took.
  It's idempotent — safe to re-run against an already-provisioned instance
  without reinstalling anything.
- **`~/.zshrc`** functions (`ec2-launch`, `ec2-reprovision`, `ec2-ssh`,
  `ec2-create-ami`, `ec2-snapshot`) — launch a fresh instance (reusing a
  tagged Elastic IP so the address never changes across terminate/relaunch),
  auto-provision it, or snapshot/AMI it for faster future boots.

## Why

I kept losing time re-configuring a fresh EC2 instance every time I
terminated one to save cost between study sessions. This automates that
completely: `ec2-launch` gets me from "no instance exists" to "fully
configured shell, SSH-able as `ssh ec2`" with one command.

## Stack

- Zsh + Oh My Zsh + Powerlevel10k
- AWS CLI (EC2, Elastic IP, Security Groups, SSM)
- Amazon Linux 2023

## Usage

```bash
ec2-launch        # launch + fully provision a fresh instance
ec2-ssh           # connect (uses ~/.ssh/config, always up to date)
ec2-reprovision   # re-sync config/aliases without relaunching
ec2-snapshot      # back up the root volume
ec2-create-ami    # bake current setup into an AMI for instant future boots
ec2-stop / ec2-start / ec2-status / ec2-terminate
```
