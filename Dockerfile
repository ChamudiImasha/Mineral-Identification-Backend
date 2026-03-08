FROM python:3.10-slim

# Set environment variables for production
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install dependencies (cached layer)
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend directory
COPY backend/app/ /app/backend/app/

# Verify critical files exist
RUN echo "=== Verifying production files ===" && \
    test -f /app/backend/app/run.py && echo "✓ run.py found" && \
    test -f /app/backend/app/api_server.py && echo "✓ api_server.py found" && \
    test -f /app/backend/app/inference_script.py && echo "✓ inference_script.py found" && \
    test -f /app/backend/app/planetary_gatekeeper.py && echo "✓ planetary_gatekeeper.py found" && \
    ls -lh /app/backend/app/*.py | wc -l && echo "Python files ready"

# Set working directory
WORKDIR /app/backend/app

# Create non-root user for security (production best practice)
RUN useradd -m -u 1000 railway && \
    chown -R railway:railway /app
USER railway

# Expose port
EXPOSE 8000

# Health check - robust production config
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health', timeout=5)" || exit 1

# Start server with Gunicorn
CMD ["python", "/app/backend/app/run.py"]
