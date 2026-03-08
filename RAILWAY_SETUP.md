# Railway Deployment - Quick Setup

## Current Setup (Working)

The app will:

1. Build without the model (fast, no Docker export errors)
2. Download model on **first startup** (takes ~30 seconds)
3. Model stored in container (re-downloads if container restarts)

## 🚀 Deploy Now

```bash
git add .
git commit -m "Fix Docker export error - download model at runtime"
git push
```

Railway will:

- ✅ Build quickly (no model download)
- ✅ Start the app
- ✅ Download model on first request (watch logs)
- ✅ App ready after ~30 seconds

## 📊 Expected Logs

```
Building...
✓ Installing dependencies
✓ Build complete
Starting...
📥 Model not found, downloading from Google Drive...
Downloading...
✓ Model downloaded successfully! Size: XXX.XX MB
✅ Model loaded successfully
✅ Planetary gatekeeper loaded
Application startup complete
```

## ⚙️ Optional: Add Persistent Storage

To avoid re-downloading the model on every restart:

### In Railway Dashboard:

1. Go to your service → **Variables** tab
2. Add new variable:
   - **Key**: `RAILWAY_VOLUME_MOUNT_PATH`
   - **Value**: `/app/backend/app/saved_models`

3. Go to **Settings** tab → **Volumes**
4. Click **+ New Volume**
5. **Mount Path**: `/app/backend/app/saved_models`
6. **Size**: 1GB

Now the model persists across deployments! ✨

## 🔍 Troubleshooting

### Build Fails at "exporting docker image"

- Fixed! Model now downloads at runtime, not build time

### App takes long to start

- Normal! First startup downloads 392MB model (~30 seconds)
- Subsequent restarts reuse cached model

### Health check fails

- Health check timeout set to 300 seconds (5 min)
- Allows time for model download on first start

### Model re-downloads every deploy

- Add persistent volume (see above) to cache the model
