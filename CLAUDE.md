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

### Go Development Tools
- **Format code**: `go fmt ./...`
- **Vet code**: `go vet ./...`
- **Run tests**: `go test ./...`
- **Get dependencies**: `go mod tidy`

### Container Development
- **Rebuild container**: F1 → "Dev Containers: Rebuild Container"
- **Configure features**: F1 → "Dev Containers: Configure Container Features..."

## Architecture

### Project Structure
```
├── server.go              # Main HTTP server (port 9000)
├── hello/
│   └── hello.go           # Hello package with User/Address types
├── go.mod                 # Go module definition
└── .devcontainer/
    └── devcontainer.json  # Dev container configuration
```

### Code Organization
- **Main server** (`server.go:20-25`): Simple HTTP server using standard library
- **Hello package** (`hello/hello.go`): Contains User and Address structs with a Hello() function
- **Module**: `github.com/microsoft/vscode-remote-try-go` (Go 1.19+)

### Dev Container Setup
- **Base image**: `mcr.microsoft.com/devcontainers/go:1-1.22-bookworm`
- **Port forwarding**: Port 9000 automatically forwarded with label "Hello Remote World"
- **Extensions**: Code Spell Checker pre-installed
- **Go tools**: gopls and Go extension available via image labels

## Development Workflow

The project is designed for:
1. Container-based development (primary use case)
2. Go language feature demonstrations (refactoring, testing, debugging)
3. Port forwarding and browser integration testing

## Key Files for Modification
- `server.go:16-18`: HTTP handler function
- `hello/hello.go:20-22`: Hello function implementation
- `.devcontainer/devcontainer.json:27-31`: Port configuration and container settings