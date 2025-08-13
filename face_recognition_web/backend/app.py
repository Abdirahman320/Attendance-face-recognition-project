
import cv2
from flask import Response, request
from flask import Flask, jsonify
from flask_cors import CORS
import numpy as np


from firebase_utils import (
    create_session,
    get_all_sessions,
    get_today_attendance,
    get_students,
    get_dashboard_summary,
    get_attendance_for_session,
 
 )


app = Flask(__name__)
CORS(app)

# === Create a session ===
@app.route("/api/create-session", methods=["POST"])
def create_session_api():
    data = request.get_json()
    return jsonify(create_session(data))


# === Get today's attendance ===
@app.route("/api/attendance/today", methods=["GET"])
def attendance_today():
    return jsonify(get_today_attendance())


# === Get all students ===
@app.route("/api/students", methods=["GET"])
def students():
    return jsonify(get_students())


# ✅ === Get all sessions ===
@app.route("/api/sessions", methods=["GET"])
def sessions():
    return jsonify(get_all_sessions())

#
@app.route("/api/dashboard", methods=["GET"])
def dashboard_summary():
  
    return jsonify(get_dashboard_summary())

# attendance report 
@app.route("/api/attendance/session/<session_id>", methods=["GET"])
def get_session_attendance(session_id):
 
    return jsonify(get_attendance_for_session(session_id))





if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)

    