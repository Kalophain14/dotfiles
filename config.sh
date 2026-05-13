#! /bin/bash
# Symlink all dotfile packages into ~ using GNU Stow.
# Usage: ./config.sh

PACKAGES=(zsh ghostty p10k helix)

for pkg in "${PACKAGES[@]}"; do
    echo "Stowing $pkg..."
    stow "$pkg"
done

echo "Done! All packages stowed."
