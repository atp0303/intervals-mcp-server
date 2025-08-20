# Docker Setup for Intervals MCP Server

This document provides comprehensive instructions for running the Intervals MCP Server using Docker.

## Prerequisites

- Docker Engine 20.10+ or Docker Desktop
- Docker Compose (included with Docker Desktop)
- Intervals.icu API key and athlete ID

## Quick Start

### 1. Environment Setup

Create a `.env` file in the project root with your credentials:

```bash
# Copy the example file (if it exists)
cp .env.example .env

# Or create manually
cat > .env << EOF
API_KEY=your_intervals_api_key_here
ATHLETE_ID=your_athlete_id_here
INTERVALS_API_BASE_URL=https://intervals.icu/api/v1
LOG_LEVEL=INFO
EOF
```

### 2. Build and Run

```bash
# Build and start the production service
docker-compose up --build

# Or run in detached mode
docker-compose up --build -d
```

### 3. Verify Installation

```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs intervals-mcp-server

# Check health status
docker-compose exec intervals-mcp-server docker-healthcheck
```

## Docker Images

### Production Image (`Dockerfile`)

- **Base**: Python 3.12-slim
- **Security**: Non-root user, minimal dependencies
- **Optimization**: Multi-stage build, layer caching
- **Health Check**: Built-in health monitoring

### Development Image (`Dockerfile.dev`)

- **Features**: Hot reload, development tools, editable install
- **Dependencies**: Includes pytest, mypy, ruff for development
- **Mounts**: Source code mounted for live editing

## Usage Scenarios

### Production Deployment

```bash
# Build production image
docker build -t intervals-mcp-server:latest .

# Run with environment variables
docker run -d \
  --name intervals-mcp-server \
  --env-file .env \
  intervals-mcp-server:latest
```

### Development with Hot Reload

```bash
# Start development service
docker-compose --profile dev up intervals-mcp-server-dev

# Make code changes - they'll be reflected immediately
# Edit src/intervals_mcp_server/server.py
```

### Testing in Docker

```bash
# Run tests in container
docker-compose exec intervals-mcp-server-dev pytest

# Run linting
docker-compose exec intervals-mcp-server-dev ruff .

# Run type checking
docker-compose exec intervals-mcp-server-dev mypy src tests
```

## Docker Compose Services

### Main Service (`intervals-mcp-server`)

- **Purpose**: Production-ready MCP server
- **Restart Policy**: `unless-stopped`
- **Volumes**: Read-only source mount for development
- **Health Check**: 30s interval with 10s timeout

### Development Service (`intervals-mcp-server-dev`)

- **Purpose**: Development with hot reload
- **Profile**: Only loaded with `--profile dev`
- **Dependencies**: Development tools and editable install
- **Volumes**: Full source code mount for live editing

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `API_KEY` | Yes | - | Intervals.icu API key |
| `ATHLETE_ID` | Yes | - | Your athlete ID |
| `INTERVALS_API_BASE_URL` | No | `https://intervals.icu/api/v1` | API base URL |
| `LOG_LEVEL` | No | `INFO` | Logging level |

## Volume Mounts

### Production
- `./src:/app/src:ro` - Read-only source code mount

### Development
- `./src:/app/src` - Full source code mount for hot reload
- `./pyproject.toml:/app/pyproject.toml` - Package configuration

## Health Checks

Both images include health checks that verify:
- Python environment is working
- httpx dependency is available
- Container is responsive

```bash
# Manual health check
docker-compose exec intervals-mcp-server python -c "import httpx; print('OK')"

# View health status
docker inspect intervals-mcp-server | grep -A 10 Health
```

## Troubleshooting

### Common Issues

1. **Permission Denied**
   ```bash
   # Fix file permissions
   sudo chown -R $USER:$USER .
   ```

2. **Build Failures**
   ```bash
   # Clean build cache
   docker-compose build --no-cache
   docker system prune -f
   ```

3. **Environment Variables Not Loading**
   ```bash
   # Verify .env file exists and has correct format
   cat .env
   # Check if variables are loaded
   docker-compose exec intervals-mcp-server env | grep API
   ```

### Debug Commands

```bash
# Enter running container
docker-compose exec intervals-mcp-server bash

# View container logs
docker-compose logs -f intervals-mcp-server

# Check container resources
docker stats intervals-mcp-server

# Inspect container configuration
docker inspect intervals-mcp-server
```

## Performance Optimization

### Build Optimization

- **Layer Caching**: Dependencies installed before source code
- **Multi-stage**: Minimal runtime image
- **Dockerignore**: Excludes unnecessary files

### Runtime Optimization

- **Non-root User**: Security without performance impact
- **Health Checks**: Minimal overhead monitoring
- **Volume Mounts**: Efficient file sharing

## Security Considerations

- **Non-root User**: Container runs as `app` user
- **Minimal Base Image**: Python slim reduces attack surface
- **Read-only Mounts**: Production volumes are read-only
- **Environment Variables**: Secrets loaded from `.env` file

## Integration with Claude Desktop

The MCP server is designed to work with Claude Desktop using stdio transport:

```bash
# Install in Claude Desktop
mcp install src/intervals_mcp_server/server.py \
  --name "Intervals.icu" \
  --with-editable . \
  --env-file .env
```

## Monitoring and Logging

### Logs

```bash
# View real-time logs
docker-compose logs -f intervals-mcp-server

# View specific log levels
docker-compose logs intervals-mcp-server | grep ERROR
```

### Metrics

```bash
# Container resource usage
docker stats intervals-mcp-server

# Health check history
docker inspect intervals-mcp-server | grep -A 20 Health
```

## Backup and Recovery

### Configuration Backup

```bash
# Backup environment configuration
cp .env .env.backup.$(date +%Y%m%d)

# Backup Docker Compose configuration
cp docker-compose.yml docker-compose.yml.backup.$(date +%Y%m%d)
```

### Data Recovery

```bash
# Recreate container with existing configuration
docker-compose down
docker-compose up -d

# Restore from backup
cp .env.backup.$(date +%Y%m%d) .env
docker-compose up -d
```

## Advanced Configuration

### Custom Docker Compose Overrides

Create `docker-compose.override.yml` for local customizations:

```yaml
version: '3.8'
services:
  intervals-mcp-server:
    environment:
      - LOG_LEVEL=DEBUG
    volumes:
      - ./logs:/app/logs
```

### Production Deployment

For production, consider:
- Using Docker Swarm or Kubernetes
- Implementing proper logging aggregation
- Setting up monitoring and alerting
- Using secrets management for sensitive data
- Implementing rolling updates and rollbacks
