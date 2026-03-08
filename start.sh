#!/bin/bash
# Railway startup script

echo "🚀 Starting CRISM Mineral Classification API..."

# Set default port if not provided by Railway
export PORT="${PORT:-8000}"

# Navigate to app directory
cd backend/app

# Start the server
echo "📡 Starting server on port $PORT..."
uvicorn api_server:app --host 0.0.0.0 --port $PORT
