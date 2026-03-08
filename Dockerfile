FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy everything
COPY . .

# Debug: List what was actually copied
RUN echo "=== Contents of /app ===" && ls -la /app && \
    echo "=== Contents of /app/backend ===" && ls -la /app/backend || echo "backend not found" && \
    echo "=== Contents of /app/backend/app ===" && ls -la /app/backend/app || echo "backend/app not found"

# Set working directory
WORKDIR /app/backend/app

# Expose port
EXPOSE 8000

# Start server using existing api_server.py main function
CMD ["python", "api_server.py"]
