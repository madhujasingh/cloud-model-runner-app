from fastapi import FastAPI, File, Form, UploadFile
from fastapi.middleware.cors import CORSMiddleware
import tensorflow as tf
import numpy as np
from PIL import Image
import requests
import io
import os

app = FastAPI()

# Allow Flutter to connect (CORS)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # allow your Flutter app
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def home():
    return {"message": "FastAPI backend is running 🚀"}


@app.post("/predict")
async def predict(
    model_url: str = Form(...),
    image: UploadFile = File(...)
):
    # 1️ Downloading the model from Firebase strg
    try:
        model_data = requests.get(model_url).content
        model_path = "temp_model.h5"

        with open(model_path, "wb") as f:
            f.write(model_data)
    except Exception as e:
        return {"error": f"Model download failed: {str(e)}"}

    # Loading the model using tensrflow
    try:
        model = tf.keras.models.load_model(model_path)
    except Exception as e:
        return {"error": f"Model loading failed: {str(e)}"}

    # Reading and preprocessinggg the image
    try:
        img_bytes = await image.read()
        img = Image.open(io.BytesIO(img_bytes)).convert("RGB")
        img = img.resize((224, 224))   # adjust depending on your model
        img_array = np.array(img) / 255.0
        img_array = np.expand_dims(img_array, axis=0)
    except Exception as e:
        return {"error": f"Image processing failed: {str(e)}"}

    # running inference
    try:
        preds = model.predict(img_array)
        predicted_class = int(np.argmax(preds))
        confidence = float(np.max(preds))
    except Exception as e:
        return {"error": f"Prediction failed: {str(e)}"}

    # Cleaningup temporary model file
    try:
        os.remove(model_path)
    except:
        pass

    # eturning the prediction result
    return {
        "predicted_class": predicted_class,
        "confidence": round(confidence * 100, 2),
        "message": "Prediction successful"
    }