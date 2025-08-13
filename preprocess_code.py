from mtcnn import MTCNN
from PIL import Image
import numpy as np
import os
import cv2
import math

# === CONFIGURATION ===
input_dir = "data/raw"
output_dir = "data/preprocessed"  # new output for aligned images
blur_log_file = "skipped_blurry_images.txt"
os.makedirs(output_dir, exist_ok=True)

# === INITIALIZE ===
detector = MTCNN()
blur_threshold = 100.0
skipped_images = []
student_image_counts = {}

# === FUNCTION: Check if blurry ===
def is_blurry(image, threshold=100.0):
    gray = cv2.cvtColor(np.array(image), cv2.COLOR_RGB2GRAY)
    variance = cv2.Laplacian(gray, cv2.CV_64F).var()
    return variance < threshold, variance

# === FUNCTION: Align face using eye landmarks ===
def align_face(img, left_eye, right_eye):
    # Convert eye coordinates to float explicitly
    left_eye = (float(left_eye[0]), float(left_eye[1]))
    right_eye = (float(right_eye[0]), float(right_eye[1]))

    dx = right_eye[0] - left_eye[0]
    dy = right_eye[1] - left_eye[1]
    angle = math.degrees(math.atan2(dy, dx))
    eye_center = ((left_eye[0] + right_eye[0]) / 2.0, (left_eye[1] + right_eye[1]) / 2.0)  # use float division
    rotation_matrix = cv2.getRotationMatrix2D(eye_center, angle, scale=1)
    aligned_img = cv2.warpAffine(img, rotation_matrix, (img.shape[1], img.shape[0]), flags=cv2.INTER_CUBIC)
    return aligned_img


# === PROCESS EACH STUDENT FOLDER ===
for student_name in os.listdir(input_dir):
    student_path = os.path.join(input_dir, student_name)
    if os.path.isdir(student_path):
        output_student_path = os.path.join(output_dir, student_name)
        os.makedirs(output_student_path, exist_ok=True)
        image_count = 0

        for filename in os.listdir(student_path):
            if filename.lower().endswith((".jpg", ".jpeg", ".png")):
                file_path = os.path.join(student_path, filename)
                img_cv = cv2.imread(file_path)
                img_rgb = cv2.cvtColor(img_cv, cv2.COLOR_BGR2RGB)

                result = detector.detect_faces(img_rgb)
                if result:
                    x, y, width, height = result[0]['box']
                    keypoints = result[0]['keypoints']

                    # === Align face using eye landmarks ===
                    aligned_img = align_face(img_rgb, keypoints['left_eye'], keypoints['right_eye'])

                    # === Crop aligned face region ===
                    face = aligned_img[y:y + height, x:x + width]
                    face = cv2.resize(face, (112, 112))  # ArcFace expects 112x112

                    # === Blur Check ===
                    blurry, score = is_blurry(Image.fromarray(face), threshold=blur_threshold)
                    if blurry:
                        skipped_images.append(f"{student_name}/{filename} | Blur: {score:.2f}")
                        continue

                    # === Save aligned face (as RGB image) ===
                    save_path = os.path.join(output_student_path, filename)
                    cv2.imwrite(save_path, cv2.cvtColor(face, cv2.COLOR_RGB2BGR))
                    image_count += 1

        student_image_counts[student_name] = image_count

# === LOG SKIPPED IMAGES ===
with open(blur_log_file, "w") as f:
    for line in skipped_images:
        f.write(line + "\n")

# === SHOW SUMMARY ===
print("\n✅ Preprocessing and alignment complete!")
print("\n📊 Image counts by student:")
for student, count in student_image_counts.items():
    print(f"  - {student}: {count} images")

print(f"\n🗑 Skipped blurry images: {len(skipped_images)} (see {blur_log_file})")