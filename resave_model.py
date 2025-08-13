import joblib
import sys
import types

# Fix for 'numpy._core' not found
sys.modules['numpy._core'] = types.ModuleType("numpy._core")

# Load the old model
classifier = joblib.load("svm_face_recognition_model_v3.joblib")

# Save as a new modern version
joblib.dump(classifier, "svm_face_recognition_model_v4.joblib")

print("✅ Model re-saved successfully as svm_face_recognition_model_v4.joblib")
