# Use the same base image that was previously specified in devcontainer.json
FROM mcr.microsoft.com/devcontainers/go:1-1.22-bookworm

# Install additional tools for multi-container development
RUN apt-get update && apt-get install -y \
    postgresql-client \
    redis-tools \
    && rm -rf /var/lib/apt/lists/*

# Install additional Go tools for database and cache integration
# Use specific versions compatible with Go 1.22
RUN go install github.com/pressly/goose/v3/cmd/goose@v3.15.1

# This Dockerfile now includes tools for working with PostgreSQL and Redis.
# Additional customizations can be added here, such as:
# - Additional system packages via apt-get
# - Custom Go tools or utilities
# - Environment variables or configuration files
# - Build tools or dependencies specific to this project