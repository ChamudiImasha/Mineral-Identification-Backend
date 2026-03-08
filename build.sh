#!/bin/bash
# Railway build script

set -e  # Exit on error

echo "🔧 Installing dependencies..."
cd backend/app
pip install -r requirements_api.txt

echo "📥 Downloading model from Google Drive..."
python download_model.py

echo "✅ Build completed successfully!"
