# Use the same base image that was previously specified in devcontainer.json
FROM mcr.microsoft.com/devcontainers/go:1-1.22-bookworm

# Install additional tools for multi-container development
RUN apt-get update && apt-get install -y \
    postgresql-client \
    redis-tools \
    && rm -rf /var/lib/apt/lists/*

# Fix Go module cache permissions - create and set ownership for vscode user
RUN mkdir -p /go/pkg/mod && \
    mkdir -p /go/pkg/sumdb && \
    mkdir -p /tmp/go-cache && \
    chown -R vscode:vscode /go/pkg && \
    chown -R vscode:vscode /tmp/go-cache

# Set Go environment variables for proper cache handling
ENV GOCACHE=/tmp/go-cache
ENV GOMODCACHE=/go/pkg/mod

# Switch to vscode user for Go operations
USER vscode

# Install additional Go tools for database and cache integration
# Use specific versions compatible with Go 1.22
RUN go install github.com/pressly/goose/v3/cmd/goose@v3.15.1

# Switch back to root for any final operations
USER root

# Install additional tools for Claude Code support and enhanced git experience
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    git \
    fzf \
    && rm -rf /var/lib/apt/lists/*

# Install git-delta for enhanced git diff visualization
RUN DELTA_VERSION="0.16.5" && \
    ARCH=$(dpkg --print-architecture) && \
    wget "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_${ARCH}.deb" && \
    dpkg -i "git-delta_${DELTA_VERSION}_${ARCH}.deb" && \
    rm "git-delta_${DELTA_VERSION}_${ARCH}.deb"

# Ensure proper permissions for Claude Code installation
RUN mkdir -p /home/vscode/.local/bin && \
    chown -R vscode:vscode /home/vscode/.local

# This Dockerfile now includes tools for working with PostgreSQL, Redis, and Claude Code.
# Additional customizations can be added here, such as:
# - Additional system packages via apt-get
# - Custom Go tools or utilities
# - Environment variables or configuration files
# - Build tools or dependencies specific to this project