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

# Configure git-delta for enhanced git diff
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.light false
git config --global merge.conflictstyle diff3
git config --global diff.colorMoved default

# Create history directory and configure shell history persistence
mkdir -p ~/.history
if [ -n "$ZSH_VERSION" ]; then
    echo 'export HISTFILE=~/.history/.zsh_history' >> ~/.zshrc
    echo 'export HISTSIZE=10000' >> ~/.zshrc
    echo 'export SAVEHIST=10000' >> ~/.zshrc
fi

if [ -n "$BASH_VERSION" ]; then
    echo 'export HISTFILE=~/.history/.bash_history' >> ~/.bashrc
    echo 'export HISTSIZE=10000' >> ~/.bashrc
    echo 'export HISTFILESIZE=10000' >> ~/.bashrc
fi

# Configure Claude Code for VS Code integration
if command -v claude &> /dev/null; then
    echo "Configuring Claude Code for VS Code integration..."
    
    # Show available configuration options (for debugging)
    echo "Available Claude Code configuration options:"
    claude config --help || true
    
    # The VS Code extension handles most configuration automatically
    # No manual configuration needed for diff_tool
    
    echo "Claude Code VS Code integration ready!"
    echo "You can access Claude Code via:"
    echo "  - Command: 'claude' in terminal"
    echo "  - VS Code: Click Claude icon in activity bar or press Cmd+ESC (Mac) / Ctrl+ESC (Windows/Linux)"
    echo "  - VS Code extension will automatically handle IDE integration features"
else
    echo "Claude Code CLI not found. VS Code extension may auto-install it when launched."
fi

echo "Claude Code installation and development environment setup completed."