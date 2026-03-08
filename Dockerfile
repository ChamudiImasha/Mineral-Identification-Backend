FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy entire project first
COPY . .

# Install Python dependencies from backend/app directory
RUN pip install --no-cache-dir -r backend/app/requirements_api.txt

# Set working directory to app location
WORKDIR /app/backend/app

# Expose port (Railway will override with $PORT)
EXPOSE 8000

# Start command (JSON format to handle signals properly)
CMD ["sh", "-c", "python -m uvicorn api_server:app --host 0.0.0.0 --port ${PORT:-8000}"]
