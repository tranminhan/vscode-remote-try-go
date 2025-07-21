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

# Handle OAuth port conflicts before configuring Claude Code
echo "Checking for OAuth port conflicts..."

# Check if port 54545 is in use (Claude Code's OAuth port)
if command -v netstat &> /dev/null; then
    if netstat -ln 2>/dev/null | grep -q ":54545 "; then
        echo "⚠️ WARNING: Port 54545 is already in use!"
        echo "This may cause OAuth authentication issues with Claude Code."
        
        # Try to identify what's using the port
        port_user=$(netstat -lnp 2>/dev/null | grep ":54545 " | head -1)
        if [ -n "$port_user" ]; then
            echo "Port 54545 is being used by: $port_user"
        fi
        
        echo "Potential solutions:"
        echo "  1. Use API key authentication instead of OAuth (recommended for Codespaces)"
        echo "  2. Kill the process using port 54545 if safe to do so"
        echo "  3. Restart the Codespace if the conflict persists"
    else
        echo "✅ Port 54545 is available for OAuth authentication"
    fi
elif command -v lsof &> /dev/null; then
    if lsof -i :54545 &>/dev/null; then
        echo "⚠️ WARNING: Port 54545 is already in use!"
        echo "Process using port 54545:"
        lsof -i :54545 2>/dev/null || echo "Could not determine process"
    else
        echo "✅ Port 54545 is available for OAuth authentication"
    fi
else
    echo "⚠️ Cannot check port status (netstat/lsof not available)"
fi

# Configure Claude Code authentication and VS Code integration
if command -v claude &> /dev/null; then
    echo "Configuring Claude Code authentication and VS Code integration..."
    
    # Check for authentication credentials
    auth_configured=false
    
    if [ -n "$ANTHROPIC_API_KEY" ]; then
        echo "✅ ANTHROPIC_API_KEY found - Claude Code will use API key authentication"
        echo "   (This bypasses OAuth and avoids port 54545 conflicts)"
        export ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY"
        auth_configured=true
    fi
    
    if [ -n "$CLAUDE_CODE_OAUTH_TOKEN" ]; then
        echo "✅ CLAUDE_CODE_OAUTH_TOKEN found - Claude Code will use OAuth token authentication"
        export CLAUDE_CODE_OAUTH_TOKEN="$CLAUDE_CODE_OAUTH_TOKEN"
        auth_configured=true
    fi
    
    if [ "$auth_configured" = true ]; then
        echo "🔐 Claude Code authentication configured successfully!"
        
        # Test authentication by checking status
        echo "Testing Claude Code authentication..."
        if claude auth status &>/dev/null; then
            echo "✅ Authentication test successful!"
        else
            echo "⚠️ Authentication configured but test failed - Claude Code will attempt to authenticate on first use"
        fi
    else
        echo "⚠️ No Claude Code authentication credentials found."
        echo ""
        echo "🚨 IMPORTANT: Due to OAuth port conflicts in Codespaces, API key authentication is recommended!"
        echo ""
        echo "To set up automatic authentication in GitHub Codespaces:"
        echo "  1. Get your API key (RECOMMENDED):"
        echo "     - Visit: https://console.anthropic.com/"
        echo "     - Create an API key"
        echo "     - Add as secret: ANTHROPIC_API_KEY"
        echo ""
        echo "  2. Alternative - OAuth Token (may have port conflicts):"
        echo "     - Run locally: claude setup-token"
        echo "     - Add as secret: CLAUDE_CODE_OAUTH_TOKEN"
        echo ""
        echo "  3. Configure GitHub Codespaces secrets:"
        echo "     - Go to repository → Settings → Secrets → Codespaces"
        echo "     - Add your chosen secret"
        echo "     - Rebuild the Codespace"
        echo ""
    fi
    
    echo "Claude Code VS Code integration ready!"
    echo "You can access Claude Code via:"
    echo "  - Command: 'claude' in terminal"
    echo "  - VS Code: Click Claude icon in activity bar or press Cmd+ESC (Mac) / Ctrl+ESC (Windows/Linux)"
    echo "  - VS Code extension will automatically handle IDE integration features"
else
    echo "Claude Code CLI not found. VS Code extension may auto-install it when launched."
fi

echo "Claude Code installation and development environment setup completed."