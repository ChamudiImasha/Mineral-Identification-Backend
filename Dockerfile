FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements-railway.txt .

# Install Python dependencies with no cache to reduce image size
RUN pip install --no-cache-dir -r requirements-railway.txt

# Copy application code
COPY backend/app ./backend/app

# Set working directory to app location
WORKDIR /app/backend/app

# Expose port (Railway will override with $PORT)
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=60s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/health')" || exit 1

# Start command
CMD python -m uvicorn api_server:app --host 0.0.0.0 --port ${PORT:-8000}
