# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a sample Go development container project demonstrating VS Code Dev Containers and GitHub Codespaces functionality. It contains a simple HTTP server that serves "Hello, " messages.

## Common Commands

### Building and Running
- **Run the server**: `go run server.go` (serves on port 9000)
- **Build**: `go build server.go`
- **Run with debugging**: Press F5 in VS Code (configured for container debugging)
- **Test generation**: Use Go extension commands like "Go: Generate Unit Tests For File"

### Database and Cache Operations
- **Connect to PostgreSQL**: `psql -h db -U postgres -d postgres` (password: postgres)
- **Connect to Redis**: `redis-cli -h redis`
- **Database migrations**: Use `goose` command for schema management
- **Check service status**: Services auto-start with docker-compose

### Go Development Tools
- **Format code**: `go fmt ./...`
- **Vet code**: `go vet ./...`
- **Run tests**: `go test ./...`
- **Get dependencies**: `go mod tidy`

### Container Development
- **Rebuild container**: F1 → "Dev Containers: Rebuild Container"
- **Configure features**: F1 → "Dev Containers: Configure Container Features..."
- **View container logs**: `docker-compose logs <service>` (e.g., db, redis)
- **Restart services**: `docker-compose restart <service>`

## Architecture

### Project Structure
```
├── server.go              # Main HTTP server (port 9000)
├── hello/
│   └── hello.go           # Hello package with User/Address types
├── go.mod                 # Go module definition
└── .devcontainer/
    ├── devcontainer.json  # Dev container configuration
    ├── Dockerfile         # Custom container image
    └── docker-compose.yml # Multi-container environment
```

### Code Organization
- **Main server** (`server.go:20-25`): Simple HTTP server using standard library
- **Hello package** (`hello/hello.go`): Contains User and Address structs with a Hello() function
- **Module**: `github.com/microsoft/vscode-remote-try-go` (Go 1.19+)

### Dev Container Setup
- **Docker Compose**: Multi-container environment with development, database, and cache services
- **Custom Dockerfile**: `.devcontainer/Dockerfile` based on `mcr.microsoft.com/devcontainers/go:1-1.22-bookworm`
- **Services**: 
  - `devcontainer`: Go development environment with database/cache tools
  - `db`: PostgreSQL 15 (port 5432, user/pass: postgres/postgres)
  - `redis`: Redis 7 (port 6379)
- **Port forwarding**: Port 9000 automatically forwarded with label "Hello Remote World"
- **Extensions**: Code Spell Checker pre-installed
- **Go tools**: gopls, goose (migrations), redis client tools
- **Database tools**: postgresql-client, redis-tools pre-installed

## Development Workflow

The project is designed for:
1. Multi-container development with Go, PostgreSQL, and Redis
2. Go language feature demonstrations (refactoring, testing, debugging)
3. Database and cache integration development
4. Port forwarding and browser integration testing
5. Microservices development patterns

## Key Files for Modification
- `server.go:16-18`: HTTP handler function
- `hello/hello.go:20-22`: Hello function implementation
- `.devcontainer/devcontainer.json:6-8`: Docker Compose configuration
- `.devcontainer/Dockerfile`: Container image customization (packages, tools, environment)
- `.devcontainer/docker-compose.yml`: Multi-container service definitions and networking