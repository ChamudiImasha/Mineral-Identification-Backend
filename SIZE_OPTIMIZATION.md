# Railway Deployment Size Optimization

## Problem
Railway's Docker image export was failing because the image size exceeded limits (likely >2GB).

## Root Cause - Dependency Sizes

**Original Requirements:**
- `torch` (GPU support): ~800-900MB
- `torchvision`: ~100-200MB  
- `open-clip-torch`: ~100-200MB
- `opencv-python`: ~100MB
- `scipy`, `matplotlib`, `numpy`, etc.: ~200-300MB
- **Total: ~1.5-2GB+ just for dependencies**
- **With model (392MB): ~2-2.5GB total** ❌ Too large for Railway

## Solution - Optimized Build

### Changes Made:

1. **CPU-Only PyTorch** ([requirements-railway.txt](requirements-railway.txt))
   - `torch==2.0.0+cpu`: ~200-300MB (vs 800MB GPU version)
   - `torchvision==0.15.0+cpu`: ~50-100MB (vs 200MB GPU version)
   - **Savings: ~500-700MB**

2. **Headless OpenCV** 
   - `opencv-python-headless`: ~30-40MB (vs 100MB full version)
   - **Savings: ~60MB**

3. **Docker Builder Instead of Nixpacks**
   - Dockerfile with multi-stage optimizations
   - `--no-cache-dir` for pip installs
   - Aggressive .dockerignore

4. **Model Downloads at Runtime**
   - Not included in Docker image
   - Downloads on first startup (30 seconds)

### Expected Sizes:

| Component | Size |
|-----------|------|
| Base Python 3.10-slim | ~150MB |
| PyTorch CPU | ~300MB |
| Other dependencies | ~400MB |
| **Total Image** | **~850MB** ✅ |
| Model (runtime) | +392MB |

## Deploy Now

```bash
git add .
git commit -m "Optimize Railway deployment - use CPU PyTorch and Dockerfile"
git push
```

## What to Expect

1. **Build Time**: 3-5 minutes (downloading dependencies)
2. **Image Size**: ~850MB (should pass Railway's limits)
3. **First Startup**: +30 seconds (downloading model)
4. **Memory Usage**: ~1-1.5GB RAM
5. **Performance**: CPU inference (~2-5 seconds per image)

## If It Still Fails

If Railway still fails with size issues, you have 3 options:

### Option 1: Try Render.com (Recommended)
Render has higher limits and better handles large Python apps:
- Use existing `render.yaml` configuration
- See [DEPLOYMENT.md](DEPLOYMENT.md)

### Option 2: Split Model to CDN
- Upload model to AWS S3/Cloudflare R2
- Download from CDN instead of Google Drive
- Faster + more reliable

### Option 3: Use Railway with Persistent Volume
- Set up volume BEFORE first deploy
- Model persists, no re-download needed
- See Railway dashboard → Volumes

## Testing Locally

Test the Docker build locally:

```bash
docker build -t mineral-api .
docker run -p 8000:8000 -e PORT=8000 mineral-api
```

Should see:
```
📥 Model not found, downloading from Google Drive...
✓ Model downloaded successfully!
✅ Model loaded successfully
Application startup complete
```
