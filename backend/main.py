from fastapi import FastAPI, UploadFile, File, Form
import uvicorn
import tensorflow as tf
from PIL import Image
import numpy as np
import requests
import io
import os

app = FastAPI()

MODEL_CACHE = "cached_models"
os.makedirs(MODEL_CACHE, exist_ok=True)


def download_model(url: str):
    file_name = url.split("/")[-1].split("?")[0]
    local_path = f"{MODEL_CACHE}/{file_name}"

    if not os.path.exists(local_path):
        r = requests.get(url)
        with open(local_path, "wb") as f:
            f.write(r.content)

    return local_path


def preprocess(image_bytes, model):
    img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    _, h, w, _ = model.input_shape
    img = img.resize((w, h))

    arr = np.array(img) / 255.0
    arr = np.expand_dims(arr, 0)
    return arr


@app.post("/predict")
async def predict(image: UploadFile = File(...), model_url: str = Form(...)):
    model_path = download_model(model_url)
    model = tf.keras.models.load_model(model_path)

    img_bytes = await image.read()
    processed = preprocess(img_bytes, model)

    pred = model.predict(processed)
    cls = int(np.argmax(pred))
    conf = float(np.max(pred))

    return {"predicted_class": cls, "confidence": conf}


@app.get("/")
def home():
    return {"msg": "Backend running!"}


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000)