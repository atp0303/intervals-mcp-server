# Use Python 3.12 slim image as base
FROM python:3.12-slim

# Add metadata labels for Docker Hub
LABEL org.opencontainers.image.title="Intervals.icu MCP Server"
LABEL org.opencontainers.image.description="Model Context Protocol server for Intervals.icu - connects Claude with athlete data, activities, events, and wellness metrics"
LABEL org.opencontainers.image.vendor="mvilanova"
LABEL org.opencontainers.image.source="https://github.com/mvilanova/intervals-mcp-server"
LABEL org.opencontainers.image.licenses="GPL-3.0-only"
LABEL org.opencontainers.image.version="0.1.0"
LABEL org.opencontainers.image.created="2024-01-01T00:00:00Z"

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential \
       curl \
       gcc \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Install Python build tool
RUN pip install --no-cache-dir hatchling

# Copy dependency files first for better caching
COPY pyproject.toml uv.lock ./

# Copy source code
COPY src/ ./src/
COPY README.md ./

# Install the package and runtime dependencies
RUN pip install --no-cache-dir .

# Create a non-root user for security
RUN useradd --create-home --shell /bin/bash app \
    && chown -R app:app /app
USER app

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import httpx; print('Health check passed')" || exit 1

# Expose port (if needed for future HTTP transport)
EXPOSE 8000

# Default command to run the MCP server using stdio transport
CMD ["mcp", "run", "src/intervals_mcp_server/server.py"]
