# Docker Hub Deployment Guide

This guide explains how to deploy the Intervals MCP Server to Docker Hub for public distribution.

## Prerequisites

1. **Docker Hub Account**: Create an account at [hub.docker.com](https://hub.docker.com)
2. **GitHub Repository**: Your code must be in a GitHub repository
3. **GitHub Secrets**: Set up required secrets for automated builds

## Setup Steps

### 1. Create Docker Hub Repository

1. Log in to Docker Hub
2. Click "Create Repository"
3. Repository name: `intervals-mcp-server`
4. Description: "Model Context Protocol server for Intervals.icu"
5. Visibility: Choose public or private
6. Click "Create"

### 2. Configure GitHub Secrets

In your GitHub repository, go to **Settings > Secrets and variables > Actions** and add:

- `DOCKER_USERNAME`: Your Docker Hub username
- `DOCKER_PASSWORD`: Your Docker Hub access token (not your login password)

**To get a Docker Hub access token:**
1. Go to Docker Hub → Account Settings → Security
2. Click "New Access Token"
3. Give it a name (e.g., "GitHub Actions")
4. Copy the token and save it as `DOCKER_PASSWORD`

### 3. Automated Builds

The GitHub Actions workflow (`.github/workflows/docker-build.yml`) will automatically:

- Build images on every push to `main`
- Build images on every tag (e.g., `v1.0.0`)
- Push to Docker Hub with appropriate tags
- Support multiple architectures (linux/amd64, linux/arm64)

## Image Tags

The workflow creates these tags automatically:

- `latest` - Latest commit on main branch
- `dev` - Development image with development dependencies
- `v1.0.0` - Semantic version tags
- `v1.0` - Major.minor version tags
- `main-abc123` - Branch-commit hash tags

## Manual Build and Push

If you prefer manual builds:

```bash
# Build production image
docker build -t mvilanova/intervals-mcp-server:latest .

# Build development image
docker build -f Dockerfile.dev -t mvilanova/intervals-mcp-server:dev .

# Login to Docker Hub
docker login

# Push images
docker push mvilanova/intervals-mcp-server:latest
docker push mvilanova/intervals-mcp-server:dev
```

## Using the Published Images

Once published, users can pull and run your images:

```bash
# Pull the latest image
docker pull mvilanova/intervals-mcp-server:latest

# Run with environment variables
docker run -d \
  --name intervals-mcp-server \
  --env-file .env \
  mvilanova/intervals-mcp-server:latest

# Or use in docker-compose
docker-compose up -d
```

## Docker Compose with Published Images

Users can modify `docker-compose.yml` to use published images:

```yaml
version: '3.8'

services:
  intervals-mcp-server:
    image: mvilanova/intervals-mcp-server:latest
    container_name: intervals-mcp-server
    restart: unless-stopped
    environment:
      - API_KEY=${API_KEY}
      - ATHLETE_ID=${ATHLETE_ID}
    env_file:
      - .env
    stdin_open: true
    tty: true

  intervals-mcp-server-dev:
    image: mvilanova/intervals-mcp-server:dev
    container_name: intervals-mcp-server-dev
    restart: unless-stopped
    environment:
      - API_KEY=${API_KEY}
      - ATHLETE_ID=${ATHLETE_ID}
    env_file:
      - .env
    stdin_open: true
    tty: true
    profiles:
      - dev
```

## Best Practices

### 1. **Security**
- Never commit secrets to the repository
- Use Docker Hub access tokens, not passwords
- Regularly rotate access tokens

### 2. **Image Optimization**
- Keep base images updated
- Use multi-stage builds when possible
- Minimize layer count

### 3. **Documentation**
- Keep README.md updated
- Document all environment variables
- Provide usage examples

### 4. **Versioning**
- Use semantic versioning for releases
- Tag releases with `v1.0.0` format
- Keep `latest` tag updated

## Troubleshooting

### Build Failures
```bash
# Check build logs
docker build --progress=plain -t test-image .

# Verify Dockerfile syntax
docker build --dry-run .
```

### Push Failures
```bash
# Verify Docker Hub login
docker login

# Check image tags
docker images mvilanova/intervals-mcp-server

# Test push with a small image first
docker pull hello-world
docker tag hello-world mvilanova/intervals-mcp-server:test
docker push mvilanova/intervals-mcp-server:test
```

### GitHub Actions Issues
- Check workflow logs in Actions tab
- Verify secrets are correctly set
- Ensure repository permissions allow Actions

## Monitoring

### Docker Hub Metrics
- View pull counts in Docker Hub dashboard
- Monitor repository activity
- Check for security vulnerabilities

### GitHub Actions
- Monitor build success rates
- Check build times and resource usage
- Review failed builds for patterns

## Next Steps

After successful deployment:

1. **Update Documentation**: Add Docker Hub pull instructions to README
2. **Community**: Share in relevant forums and communities
3. **Feedback**: Collect user feedback and iterate
4. **Maintenance**: Keep images updated with security patches

## Support

For issues with Docker Hub deployment:
- Check Docker Hub documentation
- Review GitHub Actions logs
- Open issues in the GitHub repository
- Contact Docker Hub support if needed
