#!/bin/sh
set -e

# Get port from environment, default to 8000
PORT="${PORT:-8000}"

echo "Starting uvicorn on port $PORT..."
exec uvicorn api_server:app --host 0.0.0.0 --port "$PORT"
