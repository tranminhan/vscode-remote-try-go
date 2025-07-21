#!/bin/bash

# Claude Code installation script for devcontainer
# This script installs Claude Code CLI for the vscode user

set -e

echo "Installing Claude Code..."

# Download and install Claude Code
curl -fsSL https://claude.ai/install.sh | bash

# Verify installation
if command -v claude &> /dev/null; then
    echo "Claude Code installed successfully!"
    claude --version
else
    echo "Claude Code installation failed or not in PATH"
    echo "Checking if it's installed in ~/.local/bin..."
    if [ -f "$HOME/.local/bin/claude" ]; then
        echo "Claude Code found in ~/.local/bin/claude"
        echo "Adding ~/.local/bin to PATH in ~/.bashrc and ~/.zshrc"
        
        # Add to bashrc
        if [ -f "$HOME/.bashrc" ]; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        fi
        
        # Add to zshrc
        if [ -f "$HOME/.zshrc" ]; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
        fi
        
        echo "Please restart your shell or run: source ~/.bashrc (or ~/.zshrc)"
    fi
fi

echo "Claude Code installation process completed."