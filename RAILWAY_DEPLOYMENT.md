# Railway Deployment Guide

This guide explains how to deploy the Mineral Identification Backend to Railway.

## Prerequisites

- A Railway account (sign up at https://railway.app)
- Your model file uploaded to Google Drive with public sharing enabled
- Git repository with your code

## Model Configuration

The model is automatically downloaded during deployment from Google Drive:

- **File ID**: `1C3mtxAMuUW4JUA8uDy-hHr1_dAaS-crz`
- **Download Script**: `backend/app/download_model.py`
- **Destination**: `backend/app/saved_models/best_unet_model.pth`

### Updating the Model

If you need to update the model file:

1. Upload your new model to Google Drive
2. Set sharing to "Anyone with the link can view"
3. Get the file ID from the shareable link:
   - Link format: `https://drive.google.com/file/d/FILE_ID/view?usp=sharing`
   - Extract the `FILE_ID` part
4. Update `GOOGLE_DRIVE_FILE_ID` in `backend/app/download_model.py`

## Deployment Steps

### Option 1: Deploy from GitHub (Recommended)

1. Push your code to GitHub
2. Go to [Railway Dashboard](https://railway.app/dashboard)
3. Click "New Project"
4. Select "Deploy from GitHub repo"
5. Choose your repository
6. Railway will automatically:
   - Detect it's a Python project
   - Run the build script (`build.sh`)
   - Download the model from Google Drive
   - Start the API server

### Option 2: Deploy with Railway CLI

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Initialize project
railway init

# Deploy
railway up
```

## Configuration Files

- **`railway.toml`**: Main Railway configuration
- **`Procfile`**: Alternative configuration (fallback)
- **`backend/app/build.sh`**: Build script that downloads the model
- **`backend/app/requirements.txt`**: Python dependencies

## Build Process

During deployment, Railway will:

1. **Install Dependencies**

   ```bash
   pip install -r backend/app/requirements.txt
   ```

2. **Download Model**

   ```bash
   python backend/app/download_model.py
   ```

   - Installs `gdown` if not present
   - Downloads model from Google Drive
   - Verifies the download was successful

3. **Start Server**
   ```bash
   uvicorn api_server:app --host 0.0.0.0 --port $PORT
   ```

## Environment Variables

Railway automatically provides:

- **`PORT`**: The port your app should listen on (automatically assigned)

Optional variables you can add in Railway dashboard:

- **`PYTHON_VERSION`**: Specify Python version (default: 3.10)

## Monitoring Deployment

### View Logs

1. Go to your project in Railway dashboard
2. Click on the deployment
3. View the "Build Logs" and "Deploy Logs"

### Build Logs Should Show:

```
🔧 Installing Python dependencies...
📥 Downloading pre-trained model from Google Drive...
✓ Model downloaded successfully!
  Size: XXX.XX MB
✅ Build completed successfully!
```

## Troubleshooting

### Model Download Fails

If the model download fails:

1. **Check Google Drive Permissions**
   - File must be set to "Anyone with the link can view"
   - Go to: https://drive.google.com/file/d/1C3mtxAMuUW4JUA8uDy-hHr1_dAaS-crz/view
   - Click Share → Change to "Anyone with the link"

2. **Verify File ID**
   - Check `GOOGLE_DRIVE_FILE_ID` in `backend/app/download_model.py`
   - Make sure it matches your Google Drive file

3. **Check Build Logs**
   - Look for error messages in Railway's build logs
   - The download script provides detailed error messages

### Build Fails

Check that:

- All dependencies are in `requirements.txt`
- Python version is compatible (3.10 recommended)
- Build command has correct path to `build.sh`

### App Doesn't Start

Verify:

- `api_server.py` exists in `backend/app/`
- The app listens on `$PORT` environment variable
- All required files are present after build

## Testing Locally Before Deployment

```bash
# Navigate to app directory
cd backend/app

# Run build script
chmod +x build.sh
./build.sh

# Start server
uvicorn api_server:app --host 0.0.0.0 --port 8000
```

## API Endpoints

Once deployed, your API will be available at:

- Base URL: `https://your-app.railway.app`
- Health check: `GET /health`
- Other endpoints: See `api_server.py` for full API documentation

## Updating the Deployment

When you push changes to your connected GitHub repository:

- Railway automatically detects the changes
- Triggers a new build
- Downloads the model (if not already present)
- Deploys the updated version

## Cost Considerations

- **Hobby Plan**: $5/month for 500 hours of execution time
- **Model Download**: Only happens during build, not on every request
- **Model Storage**: Persisted between deployments

## Resources

- [Railway Documentation](https://docs.railway.app/)
- [Railway Python Guide](https://docs.railway.app/guides/python)
- [Railway Environment Variables](https://docs.railway.app/develop/variables)
