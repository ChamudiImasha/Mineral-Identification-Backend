# Deploying to Render

This guide explains how to deploy the Mineral Identification Backend API to Render.

## Prerequisites

1. A [Render](https://render.com) account (free tier available)
2. Your Google Drive model file must have **"Anyone with the link"** viewing permissions
3. Git repository pushed to GitHub, GitLab, or Bitbucket

## Automatic Setup (Recommended)

The repository includes a `render.yaml` configuration file that automates the deployment setup.

### Steps:

1. **Verify Google Drive Permissions**
   - Go to your [Google Drive model file](https://drive.google.com/file/d/1C3mtxAMuUW4JUA8uDy-hHr1_dAaS-crz/view)
   - Click "Share" → "Anyone with the link" → "Viewer" → "Done"

2. **Deploy to Render**
   - Log in to your [Render Dashboard](https://dashboard.render.com/)
   - Click "New +" → "Blueprint"
   - Connect your GitHub/GitLab repository
   - Render will automatically detect and use the `render.yaml` configuration

3. **Wait for Build**
   - The build process will:
     - Install all Python dependencies from `requirements.txt`
     - Download your pre-trained model from Google Drive
     - Start the API server
   - This may take 5-10 minutes on the first deployment

4. **Access Your API**
   - Once deployed, you'll get a URL like: `https://your-app-name.onrender.com`
   - API Docs: `https://your-app-name.onrender.com/docs`
   - Health Check: `https://your-app-name.onrender.com/health`

## Manual Setup (Alternative)

If you prefer manual configuration or encounter issues:

1. **Create New Web Service**
   - Dashboard → "New +" → "Web Service"
   - Connect your repository
   - Select the `backend/app` directory as the root (if needed)

2. **Configure Build Settings**
   - **Environment:** Python 3
   - **Build Command:** `chmod +x build.sh && ./build.sh`
   - **Start Command:** `uvicorn api_server:app --host 0.0.0.0 --port $PORT`
   - **Plan:** Free or Starter

3. **Environment Variables** (Optional)
   - `PYTHON_VERSION`: `3.10.0`
   - Add any custom environment variables your app needs

## Project Structure

```
backend/app/
├── download_model.py     # Script to download model from Google Drive
├── build.sh              # Build script for Render deployment
├── requirements.txt      # Python dependencies (includes gdown)
├── api_server.py         # FastAPI application
└── saved_models/         # Model files (downloaded during deployment)
    └── best_unet_model.pth
```

## How the Model Download Works

1. During deployment, Render runs `build.sh`
2. `build.sh` installs dependencies and executes `download_model.py`
3. `download_model.py` uses `gdown` to download the model from Google Drive
4. The model is saved to `saved_models/best_unet_model.pth`
5. The API server loads the model on startup

## Troubleshooting

### Model Download Fails

**Error:** "Access denied" or "Cannot retrieve the public link"

**Solution:**

1. Ensure your Google Drive file has "Anyone with the link" permissions
2. Verify the file ID in `download_model.py` matches your Google Drive link:
   ```python
   GOOGLE_DRIVE_FILE_ID = "1C3mtxAMuUW4JUA8uDy-hHr1_dAaS-crz"
   ```
3. Try downloading the file manually to test the link:
   ```bash
   pip install gdown
   gdown https://drive.google.com/uc?id=1C3mtxAMuUW4JUA8uDy-hHr1_dAaS-crz
   ```

### Build Timeout

**Error:** Build exceeds time limit

**Solution:**

- Free tier has build time limits (~15 minutes)
- Consider upgrading to a paid plan for larger models
- Alternatively, use a public URL hosting service for the model

### Memory Issues

**Error:** Out of memory during model loading

**Solution:**

- Free tier has 512MB RAM limit
- Upgrade to Starter plan (1GB+ RAM) if your model is large
- Optimize model size (quantization, pruning) if possible

### Port Binding Error

**Error:** "Address already in use"

**Solution:**

- Ensure the start command uses `--port $PORT` (Render auto-assigns port)
- Don't hardcode port 8000 in production

## Updating the Model

To update the model file:

1. Upload the new model to Google Drive
2. Update the file ID in `download_model.py`
3. Push changes to your repository
4. Render will automatically redeploy and download the new model

Alternatively, on Render Dashboard:

- Go to your service → "Manual Deploy" → "Clear build cache & deploy"

## Local Testing

Test the deployment setup locally before pushing:

```bash
cd backend/app

# Install dependencies
pip install -r requirements.txt

# Download model
python download_model.py

# Start server
uvicorn api_server:app --reload --port 8000
```

Visit: `http://localhost:8000/docs`

## API Endpoints

- **POST** `/predict` - Upload image for mineral classification
- **GET** `/health` - Check API health and model status
- **GET** `/docs` - Interactive API documentation (Swagger UI)
- **GET** `/redoc` - Alternative API documentation (ReDoc)

## Support

For deployment issues:

- [Render Documentation](https://render.com/docs)
- [Render Community Forum](https://community.render.com/)

For application issues:

- Check the Render logs: Dashboard → Your Service → Logs
- Verify model download succeeded in build logs
