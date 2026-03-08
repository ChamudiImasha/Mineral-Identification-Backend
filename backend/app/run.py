#!/usr/bin/env python3
"""
Production startup script for Railway Hobby Plan deployment
Reads PORT from environment and starts Gunicorn with Uvicorn workers
Optimized for Railway Hobby plan resources
"""
import os
import sys
from multiprocessing import cpu_count

def get_workers():
    """Calculate number of workers based on available CPUs."""
    # Railway Hobby plan has better resources
    # Use (2 * cpu_count) + 1 for optimal throughput
    # But cap at 4 to leave memory for model inference
    workers = (2 * cpu_count()) + 1
    return min(workers, 4)

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    workers = int(os.environ.get("WEB_CONCURRENCY", get_workers()))
    
    print(f"Starting server on port {port} with {workers} worker(s)...")
    
    # Use Gunicorn with Uvicorn workers for production
    # Gunicorn provides better timeout and worker management
    from gunicorn.app.base import BaseApplication
    
    class StandaloneApplication(BaseApplication):
        def __init__(self, app, options=None):
            self.options = options or {}
            self.application = app
            super().__init__()

        def load_config(self):
            for key, value in self.options.items():
                self.cfg.set(key.lower(), value)

        def load(self):
            return self.application

    options = {
        'bind': f'0.0.0.0:{port}',
        'workers': workers,
        'worker_class': 'uvicorn.workers.UvicornWorker',
        'timeout': 180,  # 3 minutes - sufficient for inference with hobby plan resources
        'graceful_timeout': 30,
        'keepalive': 5,
        'max_requests': 500,  # More requests before restart (hobby plan handles this)
        'max_requests_jitter': 50,
        'worker_connections': 1000,
        'preload_app': False,  # Don't preload to avoid model loading issues
        'accesslog': '-',
        'errorlog': '-',
        'loglevel': 'info',
        'capture_output': True,
        'enable_stdio_inheritance': True
    }
    
    # Import app
    from api_server import app
    
    # Run with Gunicorn
    StandaloneApplication(app, options).run()
