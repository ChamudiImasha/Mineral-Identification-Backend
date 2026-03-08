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

# Set working directory
WORKDIR /app/backend/app

# Expose port
EXPOSE 8000

# Start server using Python script that reads PORT env var
CMD ["python", "run.py"]
