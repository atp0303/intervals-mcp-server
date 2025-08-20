#!/bin/bash

# Docker Helper Script for Intervals MCP Server
# Usage: ./docker-helper.sh [command]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if .env file exists
check_env_file() {
    if [ ! -f .env ]; then
        print_warning ".env file not found. Creating from template..."
        if [ -f .env.example ]; then
            cp .env.example .env
            print_success ".env file created from .env.example"
            print_warning "Please edit .env file with your actual API credentials"
        else
            print_error ".env.example file not found. Please create .env file manually"
            exit 1
        fi
    fi
}

# Function to check Docker installation
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    print_success "Docker and Docker Compose are available"
}

# Function to build and start services
start_services() {
    print_status "Building and starting Intervals MCP Server..."
    docker-compose up --build -d
    print_success "Services started successfully"
    
    print_status "Checking service status..."
    docker-compose ps
    
    print_status "Viewing logs (Ctrl+C to exit)..."
    docker-compose logs -f intervals-mcp-server
}

# Function to start development service
start_dev() {
    print_status "Starting development service with hot reload..."
    docker-compose --profile dev up --build -d intervals-mcp-server-dev
    print_success "Development service started successfully"
    
    print_status "Checking service status..."
    docker-compose ps
    
    print_status "Viewing development logs (Ctrl+C to exit)..."
    docker-compose logs -f intervals-mcp-server-dev
}

# Function to stop services
stop_services() {
    print_status "Stopping all services..."
    docker-compose down
    print_success "Services stopped successfully"
}

# Function to restart services
restart_services() {
    print_status "Restarting services..."
    docker-compose restart
    print_success "Services restarted successfully"
}

# Function to view logs
view_logs() {
    local service=${1:-intervals-mcp-server}
    print_status "Viewing logs for $service (Ctrl+C to exit)..."
    docker-compose logs -f $service
}

# Function to run tests
run_tests() {
    print_status "Running tests in development container..."
    docker-compose exec intervals-mcp-server-dev pytest
}

# Function to run linting
run_lint() {
    print_status "Running linting in development container..."
    docker-compose exec intervals-mcp-server-dev ruff .
}

# Function to run type checking
run_typecheck() {
    print_status "Running type checking in development container..."
    docker-compose exec intervals-mcp-server-dev mypy src tests
}

# Function to enter container
enter_container() {
    local service=${1:-intervals-mcp-server}
    print_status "Entering $service container..."
    docker-compose exec $service bash
}

# Function to check health
check_health() {
    print_status "Checking container health..."
    docker-compose ps
    echo
    print_status "Health check details:"
    docker-compose exec intervals-mcp-server python -c "import httpx; print('Health check passed')" 2>/dev/null || print_error "Health check failed"
}

# Function to clean up
cleanup() {
    print_status "Cleaning up Docker resources..."
    docker-compose down --volumes --remove-orphans
    docker system prune -f
    print_success "Cleanup completed"
}

# Function to show help
show_help() {
    echo "Docker Helper Script for Intervals MCP Server"
    echo
    echo "Usage: $0 [command]"
    echo
    echo "Commands:"
    echo "  start       Build and start production services"
    echo "  dev         Start development service with hot reload"
    echo "  stop        Stop all services"
    echo "  restart     Restart all services"
    echo "  logs        View logs (default: intervals-mcp-server)"
    echo "  logs-dev    View development service logs"
    echo "  test        Run tests in development container"
    echo "  lint        Run linting in development container"
    echo "  typecheck   Run type checking in development container"
    echo "  shell       Enter container shell (default: intervals-mcp-server)"
    echo "  shell-dev   Enter development container shell"
    echo "  health      Check container health status"
    echo "  cleanup     Clean up Docker resources"
    echo "  help        Show this help message"
    echo
    echo "Examples:"
    echo "  $0 start           # Start production services"
    echo "  $0 dev             # Start development service"
    echo "  $0 logs            # View production logs"
    echo "  $0 shell-dev       # Enter development container"
}

# Main script logic
main() {
    # Check prerequisites
    check_docker
    check_env_file
    
    case "${1:-help}" in
        start)
            start_services
            ;;
        dev)
            start_dev
            ;;
        stop)
            stop_services
            ;;
        restart)
            restart_services
            ;;
        logs)
            view_logs intervals-mcp-server
            ;;
        logs-dev)
            view_logs intervals-mcp-server-dev
            ;;
        test)
            run_tests
            ;;
        lint)
            run_lint
            ;;
        typecheck)
            run_typecheck
            ;;
        shell)
            enter_container intervals-mcp-server
            ;;
        shell-dev)
            enter_container intervals-mcp-server-dev
            ;;
        health)
            check_health
            ;;
        cleanup)
            cleanup
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            echo
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
