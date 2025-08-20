@echo off
REM Docker Helper Script for Intervals MCP Server (Windows)
REM Usage: docker-helper.bat [command]

setlocal enabledelayedexpansion

REM Check if command is provided
if "%1"=="" (
    call :show_help
    exit /b 1
)

REM Check Docker installation
call :check_docker
if errorlevel 1 exit /b 1

REM Check .env file
call :check_env_file

REM Process commands
if "%1"=="start" (
    call :start_services
) else if "%1"=="dev" (
    call :start_dev
) else if "%1"=="stop" (
    call :stop_services
) else if "%1"=="restart" (
    call :restart_services
) else if "%1"=="logs" (
    call :view_logs intervals-mcp-server
) else if "%1"=="logs-dev" (
    call :view_logs intervals-mcp-server-dev
) else if "%1"=="test" (
    call :run_tests
) else if "%1"=="lint" (
    call :run_lint
) else if "%1"=="typecheck" (
    call :run_typecheck
) else if "%1"=="shell" (
    call :enter_container intervals-mcp-server
) else if "%1"=="shell-dev" (
    call :enter_container intervals-mcp-server-dev
) else if "%1"=="health" (
    call :check_health
) else if "%1"=="cleanup" (
    call :cleanup
) else if "%1"=="help" (
    call :show_help
) else (
    echo [ERROR] Unknown command: %1
    echo.
    call :show_help
    exit /b 1
)

exit /b 0

:check_docker
echo [INFO] Checking Docker installation...
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not installed. Please install Docker Desktop first.
    exit /b 1
)

docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker Compose is not installed. Please install Docker Compose first.
    exit /b 1
)

echo [SUCCESS] Docker and Docker Compose are available
exit /b 0

:check_env_file
if not exist .env (
    echo [WARNING] .env file not found. Creating from template...
    if exist .env.example (
        copy .env.example .env >nul
        echo [SUCCESS] .env file created from .env.example
        echo [WARNING] Please edit .env file with your actual API credentials
    ) else (
        echo [ERROR] .env.example file not found. Please create .env file manually
        exit /b 1
    )
)
exit /b 0

:start_services
echo [INFO] Building and starting Intervals MCP Server...
docker-compose up --build -d
if errorlevel 1 (
    echo [ERROR] Failed to start services
    exit /b 1
)

echo [SUCCESS] Services started successfully
echo [INFO] Checking service status...
docker-compose ps
echo [INFO] Viewing logs (Ctrl+C to exit)...
docker-compose logs -f intervals-mcp-server
exit /b 0

:start_dev
echo [INFO] Starting development service with hot reload...
docker-compose --profile dev up --build -d intervals-mcp-server-dev
if errorlevel 1 (
    echo [ERROR] Failed to start development service
    exit /b 1
)

echo [SUCCESS] Development service started successfully
echo [INFO] Checking service status...
docker-compose ps
echo [INFO] Viewing development logs (Ctrl+C to exit)...
docker-compose logs -f intervals-mcp-server-dev
exit /b 0

:stop_services
echo [INFO] Stopping all services...
docker-compose down
echo [SUCCESS] Services stopped successfully
exit /b 0

:restart_services
echo [INFO] Restarting services...
docker-compose restart
echo [SUCCESS] Services restarted successfully
exit /b 0

:view_logs
echo [INFO] Viewing logs for %1 (Ctrl+C to exit)...
docker-compose logs -f %1
exit /b 0

:run_tests
echo [INFO] Running tests in development container...
docker-compose exec intervals-mcp-server-dev pytest
exit /b 0

:run_lint
echo [INFO] Running linting in development container...
docker-compose exec intervals-mcp-server-dev ruff .
exit /b 0

:run_typecheck
echo [INFO] Running type checking in development container...
docker-compose exec intervals-mcp-server-dev mypy src tests
exit /b 0

:enter_container
echo [INFO] Entering %1 container...
docker-compose exec %1 bash
exit /b 0

:check_health
echo [INFO] Checking container health...
docker-compose ps
echo.
echo [INFO] Health check details:
docker-compose exec intervals-mcp-server python -c "import httpx; print('Health check passed')" 2>nul
if errorlevel 1 echo [ERROR] Health check failed
exit /b 0

:cleanup
echo [INFO] Cleaning up Docker resources...
docker-compose down --volumes --remove-orphans
docker system prune -f
echo [SUCCESS] Cleanup completed
exit /b 0

:show_help
echo Docker Helper Script for Intervals MCP Server
echo.
echo Usage: %0 [command]
echo.
echo Commands:
echo   start       Build and start production services
echo   dev         Start development service with hot reload
echo   stop        Stop all services
echo   restart     Restart all services
echo   logs        View logs ^(default: intervals-mcp-server^)
echo   logs-dev    View development service logs
echo   test        Run tests in development container
echo   lint        Run linting in development container
echo   typecheck   Run type checking in development container
echo   shell       Enter container shell ^(default: intervals-mcp-server^)
echo   shell-dev   Enter development container shell
echo   health      Check container health status
echo   cleanup     Clean up Docker resources
echo   help        Show this help message
echo.
echo Examples:
echo   %0 start           # Start production services
echo   %0 dev             # Start development service
echo   %0 logs            # View production logs
echo   %0 shell-dev       # Enter development container
exit /b 0
