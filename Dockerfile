FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install dependencies first (for better layer caching)
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend directory explicitly
COPY backend/app/ /app/backend/app/

# Verify files were copied
RUN echo "=== Verifying backend/app directory ===" && \
    ls -la /app/backend/app/*.py | head -20

# Set working directory
WORKDIR /app/backend/app

# Expose port (dynamic from Railway)
EXPOSE 8000

# Health check - use urllib instead of requests (built-in)
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health', timeout=5)" || exit 1

# Start server - use absolute path to be explicit
CMD ["python", "/app/backend/app/run.py"]
