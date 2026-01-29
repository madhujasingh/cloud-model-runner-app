# Cloud Deep Learning Model Runner App  

A cross-platform Flutter application designed to upload, run, and manage trained deep learning models in a cloud based environment.  
This project simplifies the process of testing and deploying AI models without local hardware setup, using FastAPI, TensorFlow, and Firebase.

---

##  Features
- Upload trained deep learning models directly from the app.  
- Run model inferences on the cloud through FastAPI backend.  
- Firebase authentication for secure user login and data access.  
- Real-time response handling and cloud-based predictions.  
- Streamlined workflow for AI model testing from a mobile interface.

---

##  Technologies Used
| Layer | Tools / Frameworks |
|-------|--------------------|
| **Frontend (App)** | Flutter, Dart |
| **Backend** | FastAPI (Python) |
| **Machine Learning** | TensorFlow |
| **Database / Cloud** | Firebase, Cloud Storage |
| **APIs** | REST API for model upload and inference |

---

## System Workflow
1. User uploads a trained `.h5` or `.pkl` model from the Flutter app.  
2. FastAPI backend receives the file and stores it in cloud storage.  
3. TensorFlow loads and runs inference on the model.  
4. Results are sent back to the app and displayed in real-time.  

---
