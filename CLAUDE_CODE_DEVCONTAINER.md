# Claude Code + DevContainer: Truly Isolated Development Environments

This document explains how this project demonstrates a powerful pattern for creating truly isolated development environments that integrate Claude Code seamlessly within containerized workflows.

## Overview

This setup combines VS Code Dev Containers, Docker Compose, and Claude Code to create reproducible, isolated development environments. Each project runs in its own containerized environment with dedicated services, ensuring complete isolation between different development contexts.

## Architecture Overview

### Container Isolation Model

```
┌─────────────────────────────────────────────────────────────┐
│                    Host System                              │
├─────────────────────────────────────────────────────────────┤
│  Project A DevContainer          Project B DevContainer    │
│  ┌─────────────────────────┐     ┌─────────────────────────┐ │
│  │ Go + Claude Code        │     │ Python + Claude Code    │ │
│  │ PostgreSQL 15           │     │ MySQL 8                 │ │
│  │ Redis 7                 │     │ MongoDB 6               │ │
│  │ Node.js 20              │     │ Node.js 18              │ │
│  │                         │     │                         │ │
│  │ /workspaces/project-a   │     │ /workspaces/project-b   │ │
│  └─────────────────────────┘     └─────────────────────────┘ │
│         Network: project-a               Network: project-b  │
└─────────────────────────────────────────────────────────────┘
```

### Key Isolation Benefits

1. **Complete Environment Isolation**: Each project has its own runtime, dependencies, and services
2. **Network Isolation**: Docker Compose creates isolated networks per project
3. **Filesystem Isolation**: Containerized filesystems prevent conflicts
4. **Tool Version Isolation**: Different projects can use different tool versions
5. **Claude Code Context Isolation**: Each container has its own Claude Code configuration

## DevContainer Configuration

### Core Components

#### 1. devcontainer.json
```json
{
  "name": "Go",
  "dockerComposeFile": "docker-compose.yml",
  "service": "devcontainer",
  "workspaceFolder": "/workspaces/${localWorkspaceFolderBasename}",
  "features": {
    "ghcr.io/devcontainers/features/node:1": {"version": "20"},
    "ghcr.io/devcontainers/features/common-utils:2": {
      "installZsh": true,
      "installOhMyZsh": true
    }
  },
  "postCreateCommand": ".devcontainer/install-claude.sh"
}
```

**Key Features:**
- **Docker Compose Integration**: Uses multi-service architecture
- **Node.js 20**: Required runtime for Claude Code
- **Shell Enhancement**: ZSH with Oh My ZSH for better UX
- **Automatic Setup**: Claude Code installed post-creation

#### 2. Docker Compose Services

```yaml
services:
  devcontainer:
    build:
      context: .
      dockerfile: Dockerfile
    volumes:
      - ../..:/workspaces:cached
    command: sleep infinity
    network_mode: service:db

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_PASSWORD: postgres
    volumes:
      - postgres-data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    volumes:
      - redis-data:/data
```

**Isolation Mechanisms:**
- **Service Networks**: Each compose stack creates isolated networks
- **Named Volumes**: Data persistence without host filesystem conflicts
- **Resource Limits**: Can be configured per service
- **Health Checks**: Service-level monitoring and restart policies

#### 3. Custom Dockerfile

```dockerfile
FROM mcr.microsoft.com/devcontainers/go:1-1.22-bookworm

# Install database and cache tools
RUN apt-get update && apt-get install -y \
    postgresql-client \
    redis-tools \
    curl wget unzip git

# Fix Go module cache permissions
RUN mkdir -p /go/pkg/mod /tmp/go-cache && \
    chown -R vscode:vscode /go/pkg /tmp/go-cache

# Environment variables for Go
ENV GOCACHE=/tmp/go-cache
ENV GOMODCACHE=/go/pkg/mod

# Install Go tools as vscode user
USER vscode
RUN go install github.com/pressly/goose/v3/cmd/goose@v3.15.1
USER root
```

**Security & Isolation Features:**
- **Non-root User**: Development runs as `vscode` user
- **Proper Permissions**: Go cache directories owned by development user
- **Minimal Surface**: Only necessary tools installed
- **Version Pinning**: Specific tool versions for reproducibility

## Claude Code Integration

### Automatic Installation

The setup includes a robust Claude Code installation script:

```bash
#!/bin/bash
set -e

echo "Installing Claude Code..."
curl -fsSL https://claude.ai/install.sh | bash

# Verify installation and configure PATH
if command -v claude &> /dev/null; then
    echo "Claude Code installed successfully!"
    claude --version
else
    # Handle installation in ~/.local/bin
    if [ -f "$HOME/.local/bin/claude" ]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
    fi
fi
```

### Integration Benefits

1. **Automatic Setup**: Claude Code installed on container creation
2. **PATH Configuration**: Automatically configured for all shell sessions
3. **User Context**: Runs in the same user context as development tools
4. **Isolated Configuration**: Each container has independent Claude Code settings

### Usage Within Container

Once inside the devcontainer:

```bash
# Claude Code is immediately available
claude --help

# Work with your Go project using Claude Code
claude "Help me optimize this Redis integration"

# Claude Code has access to the full project context
claude "Review my server.go for potential improvements"
```

## True Isolation Explained

### Project-Level Isolation

Each project using this devcontainer pattern gets:

1. **Dedicated Runtime Environment**
   - Independent Go version and tools
   - Isolated module cache and build artifacts
   - Project-specific environment variables

2. **Isolated Service Stack**
   - Dedicated PostgreSQL instance with project data
   - Independent Redis instance for caching
   - Network isolation between projects

3. **Independent Claude Code Context**
   - Separate Claude Code installation per project
   - Project-specific conversation history
   - Isolated API key and configuration management

### Host System Protection

The containerized approach protects the host system:

- **No Global Tool Conflicts**: Each project has its own tool versions
- **Clean Host System**: No development dependencies on host
- **Easy Cleanup**: Remove containers to completely clean up
- **Resource Management**: Container-level resource limits

## Advanced Usage Patterns

### Multiple Project Setup

To work with multiple projects simultaneously:

1. **Clone Multiple Projects**:
   ```bash
   git clone project-a
   git clone project-b
   ```

2. **Open Each in Separate VS Code Windows**:
   - Each project opens in its own devcontainer
   - Complete isolation between environments
   - Independent Claude Code instances

3. **Resource Management**:
   ```bash
   # View all running containers
   docker ps
   
   # Stop unused project containers
   docker-compose down
   ```

### Team Standardization

Share the devcontainer configuration across teams:

1. **Version Control**: Include `.devcontainer/` in git
2. **Team Onboarding**: New team members get identical environments
3. **CI/CD Integration**: Use same containers for testing/deployment
4. **Documentation**: Environment setup is self-documenting

### Customization Patterns

Extend the base configuration for specific needs:

```dockerfile
# In custom Dockerfile
FROM base-devcontainer

# Add project-specific tools
RUN apt-get update && apt-get install -y \
    project-specific-tool

# Install additional Go tools
USER vscode
RUN go install custom/tool@latest
USER root
```

## Security Considerations

### Container Security

- **Non-Root Execution**: Development runs as unprivileged user
- **Network Isolation**: Each project has isolated network stack
- **Resource Limits**: Can configure CPU/memory limits
- **Image Security**: Base images from Microsoft's official registry

### Claude Code Security

- **User Context**: Claude Code runs in same security context as development
- **API Key Isolation**: Each container maintains separate credentials
- **Project Boundaries**: Claude Code context limited to container filesystem
- **Audit Trail**: Container logs provide audit trail for Claude Code usage

## Troubleshooting

### Common Issues

1. **Claude Code Not Found**:
   ```bash
   # Check if installed
   ls ~/.local/bin/claude
   
   # Manually add to PATH
   export PATH="$HOME/.local/bin:$PATH"
   ```

2. **Go Module Cache Permissions**:
   ```bash
   # Fix ownership
   sudo chown -R vscode:vscode /go/pkg
   ```

3. **Service Connection Issues**:
   ```bash
   # Check service status
   docker-compose ps
   
   # Check service logs
   docker-compose logs db
   ```

### Performance Optimization

1. **Volume Caching**: Use `:cached` mount options for better performance
2. **Resource Allocation**: Increase Docker Desktop resources if needed
3. **Cleanup**: Regularly remove unused containers and volumes

## Conclusion

This devcontainer setup demonstrates a powerful pattern for truly isolated development environments that integrate Claude Code seamlessly. By combining Docker Compose, VS Code Dev Containers, and automated Claude Code installation, teams can achieve:

- **Complete Environment Isolation** between projects
- **Reproducible Development Environments** across team members
- **Integrated AI Assistance** with Claude Code in every project
- **Scalable Team Workflows** with standardized tooling

The approach scales from individual developers to large teams, providing a foundation for modern, AI-assisted development workflows while maintaining security and isolation best practices.