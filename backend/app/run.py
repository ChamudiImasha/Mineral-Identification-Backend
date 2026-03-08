#!/usr/bin/env python3
"""
Startup script for Railway deployment
Reads PORT from environment and starts Gunicorn with Uvicorn workers
"""
import os
import sys
from multiprocessing import cpu_count

def get_workers():
    """Calculate number of workers based on available CPUs."""
    # For ML workloads, use fewer workers to avoid memory issues
    # Formula: min(2, cpu_count)
    return min(2, cpu_count())

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
        'timeout': 300,  # 5 minutes for ML inference
        'graceful_timeout': 30,
        'keepalive': 5,
        'max_requests': 100,  # Restart workers after 100 requests to prevent memory leaks
        'max_requests_jitter': 10,
        'preload_app': False,  # Don't preload to avoid model loading issues
        'accesslog': '-',
        'errorlog': '-',
        'loglevel': 'info'
    }
    
    # Import app
    from api_server import app
    
    # Run with Gunicorn
    StandaloneApplication(app, options).run()
