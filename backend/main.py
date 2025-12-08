from fastapi import FastAPI, UploadFile, File, Form
import uvicorn
import tensorflow as tf
from PIL import Image
import numpy as np
import requests
import os
import io

app = FastAPI()

# Temporary storage folder on Render
TEMP_DIR = "temp_files"
os.makedirs(TEMP_DIR, exist_ok=True)



#  Download file from URL

def download_file(url, save_path):
    r = requests.get(url, allow_redirects=True)
    if r.status_code != 200:
        raise Exception(f"Failed to download from {url}")
    with open(save_path, "wb") as f:
        f.write(r.content)
    return save_path



# Preprocess image

def preprocess_image(image_bytes, model):
    img = Image.open(io.BytesIO(image_bytes)).convert("RGB")

    # Model input shape (None, H, W, 3)
    _, h, w, _ = model.input_shape
    img = img.resize((w, h))

    arr = np.array(img) / 255.0
    arr = np.expand_dims(arr, axis=0)
    return arr



# Helper: Load labels if provided

def load_labels(labels_path):
    if not os.path.exists(labels_path):
        return None

    with open(labels_path, "r") as f:
        labels = [line.strip() for line in f.readlines() if line.strip()]
    
    return labels if len(labels) > 0 else None



# Prediction API

@app.post("/predict")
async def predict(
    image: UploadFile = File(...),
    model_url: str = Form(...),
    labels_url: str = Form(None)   # Optional
):
    try:
     
        # 1. DOWNLOAD MODEL
       
        model_path = os.path.join(TEMP_DIR, "model.h5")
        download_file(model_url, model_path)

        # Load model
        model = tf.keras.models.load_model(model_path)

       
        #  DOwnload labels, its optional
     
        labels = None
        if labels_url:
            labels_path = os.path.join(TEMP_DIR, "labels.txt")
            download_file(labels_url, labels_path)
            labels = load_labels(labels_path)

       
        #  process image
 
        image_bytes = await image.read()
        processed = preprocess_image(image_bytes, model)

       
        

        #predict
        preds = model.predict(processed)
        predicted_class = int(np.argmax(preds))
        confidence = float(np.max(preds))

       
        # 5. map labels
        
        if labels and predicted_class < len(labels):
            label = labels[predicted_class]
        else:
            label = f"class_{predicted_class}"

        return {
            "label": label,
            "confidence": confidence
        }

    except Exception as e:
        return {"error": str(e)}





@app.get("/")
async def home():
    return {"message": "Cloud Model Runner Backend Working"}



# Run server

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)