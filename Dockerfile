FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Explicitly copy backend directory
COPY backend/ /app/backend/

# Debug: Verify files copied
RUN echo "=== Verifying backend directory ===" && \
    ls -la /app/backend/app/*.py | head -10

# Set working directory
WORKDIR /app/backend/app

# Expose port
EXPOSE 8000

# Start server
CMD ["python", "api_server.py"]
