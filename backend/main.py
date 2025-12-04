# backend/main.py
from fastapi import FastAPI, UploadFile, File, Form, HTTPException
import uvicorn
import tensorflow as tf
from PIL import Image
import numpy as np
import os
import io

app = FastAPI()

# Directory to store uploaded models
MODEL_DIR = "models"
os.makedirs(MODEL_DIR, exist_ok=True)


# -------------------------
# List available models
# -------------------------
@app.get("/models")
async def list_models():
    files = [f for f in os.listdir(MODEL_DIR) if f.endswith(".h5")]
    # return list of objects with name (client expects name)
    return {"models": [{"name": fn} for fn in files]}


# -------------------------
# Upload model
# -------------------------
@app.post("/upload_model")
async def upload_model(file: UploadFile = File(...)):
    # Accept only .h5
    if not file.filename.lower().endswith(".h5"):
        raise HTTPException(status_code=400, detail="Only .h5 model files allowed")

    save_path = os.path.join(MODEL_DIR, file.filename)

    # Save (overwrite if exists)
    try:
        with open(save_path, "wb") as f:
            f.write(await file.read())
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to save model: {e}")

    return {"status": "uploaded", "model_name": file.filename}


# -------------------------
# Helper: preprocess image
# -------------------------
def preprocess_for_model(image_bytes: bytes, model) -> np.ndarray:
    img = Image.open(io.BytesIO(image_bytes)).convert("RGB")

    # Try to auto-detect model input shape
    try:
        _, h, w, _ = model.input_shape
        if h is None or w is None:
            h, w = 224, 224
    except Exception:
        h, w = 224, 224

    img = img.resize((int(w), int(h)))
    arr = np.array(img).astype(np.float32) / 255.0
    if arr.ndim == 3:
        arr = np.expand_dims(arr, axis=0)
    return arr


# -------------------------
# Predict using a selected model
# -------------------------
@app.post("/predict")
async def predict(
    model_name: str = Form(...),
    image: UploadFile = File(...)
):
    model_path = os.path.join(MODEL_DIR, model_name)
    if not os.path.exists(model_path):
        raise HTTPException(status_code=404, detail="Model not found on server")

    # Load model
    try:
        model = tf.keras.models.load_model(model_path)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error loading model: {e}")

    # Read image
    try:
        image_bytes = await image.read()
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Failed to read image: {e}")

    # Preprocess
    try:
        processed = preprocess_for_model(image_bytes, model)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Image preprocessing failed: {e}")

    # Predict
    try:
        preds = model.predict(processed)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Inference failed: {e}")

    preds_arr = np.array(preds).squeeze()
    if preds_arr.ndim == 0:
        predicted_class = 0
        confidence = float(preds_arr)
    else:
        predicted_class = int(np.argmax(preds_arr))
        confidence = float(np.max(preds_arr))

    # Simple known mapping for cat/dog models (optional)
    label = f"class_{predicted_class}"
    if "catdog" in model_name.lower() or "cat" in model_name.lower() and "dog" in model_name.lower():
        label = "Cat" if predicted_class == 0 else "Dog"

    return {"label": label, "confidence": confidence}


@app.get("/")
async def root():
    return {"message": "Cloud Model Runner backend (multi-model) active."}


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)