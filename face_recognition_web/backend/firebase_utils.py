# firebase_utils.py

from venv import logger
import firebase_admin
from firebase_admin import credentials, firestore
from flask import jsonify
from google.api_core.exceptions import GoogleAPIError
import pytz
from datetime import datetime, timedelta
from dateutil.parser import isoparse
from email.utils import parsedate_to_datetime



# === Firebase Setup ===
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# === Helper: Convert UTC to Somali Local Time String ===
def format_datetime(dt):
    somali_tz = pytz.timezone("Africa/Mogadishu")
    return dt.astimezone(somali_tz).strftime("%Y-%m-%d %H:%M:%S")

def parse_datetime_safe(value):
    if isinstance(value, datetime):
        return value

    if isinstance(value, str):
        try:
            # Try ISO format
            dt = isoparse(value)
            return dt if dt.tzinfo else pytz.UTC.localize(dt)
        except Exception:
            try:
                # Try RFC 2822 format like: 'Wed, 02 Jul 2025 09:00:58 GMT'
                dt = parsedate_to_datetime(value)
                return dt if dt.tzinfo else pytz.UTC.localize(dt)
            except Exception:
                print(f"⚠ Skipping invalid datetime: {value}")
                return None
    return None


# === Sessions Function ===
def create_session(data):
    tz = pytz.timezone("Africa/Mogadishu")
    start = datetime.now(tz)
    end = start + timedelta(minutes=data.get("duration", 10))

    def get_doc_id_by_name(collection_ref, name):
        docs = collection_ref.where("Name", "==", name).limit(1).stream()
        for doc in docs:
            return doc.id
        raise Exception(f"❌ '{name}' not found in collection.")

    try:
        faculty_id = get_doc_id_by_name(db.collection("faculties"), data["faculty"])
        department_id = get_doc_id_by_name(db.collection("faculties").document(faculty_id).collection("departments"), data["department"])
        class_id = get_doc_id_by_name(db.collection("faculties").document(faculty_id).collection("departments").document(department_id).collection("classes"), data["class"])
        course_id = get_doc_id_by_name(db.collection("faculties").document(faculty_id).collection("departments").document(department_id).collection("classes").document(class_id).collection("courses"), data["course"])

        session_ref = db.collection("faculties").document(faculty_id) \
            .collection("departments").document(department_id) \
            .collection("classes").document(class_id) \
            .collection("courses").document(course_id) \
            .collection("sessions")

        session_ref.add({
            "subject": data["course"],
            "start_time": start,
            "end_time": end,
            "course_id": course_id,
            "class_id": class_id
        })

        return {"success": True}

    except Exception as e:
        print("❌ Error:", e)
        return {"success": False, "error": str(e)}

# firebase_utils.py (only the two functions below need replacing)
import pytz
from datetime import datetime

def get_all_sessions():
    """
    Return a flat list of sessions with normalized ISO timestamps and a 2-state status:
      - 'Finished'  : end_time exists and now > end_time
      - 'Ongoing'   : otherwise (used in UI as 'Continue')
    """
    try:
        somali_tz = pytz.timezone("Africa/Mogadishu")
        now = datetime.now(somali_tz)

        result = []
        faculties = db.collection("faculties").stream()

        for faculty in faculties:
            departments = db.collection("faculties").document(faculty.id) \
                            .collection("departments").stream()
            for department in departments:
                classes = db.collection("faculties").document(faculty.id) \
                            .collection("departments").document(department.id) \
                            .collection("classes").stream()
                for class_doc in classes:
                    courses = db.collection("faculties").document(faculty.id) \
                                .collection("departments").document(department.id) \
                                .collection("classes").document(class_doc.id) \
                                .collection("courses").stream()
                    for course_doc in courses:
                        sessions = db.collection("faculties").document(faculty.id) \
                                     .collection("departments").document(department.id) \
                                     .collection("classes").document(class_doc.id) \
                                     .collection("courses").document(course_doc.id) \
                                     .collection("sessions").stream()
                        for session in sessions:
                            data = session.to_dict() or {}

                            # Parse times
                            start_dt = parse_datetime_safe(data.get("start_time"))
                            end_dt   = parse_datetime_safe(data.get("end_time"))
                            if not start_dt:
                                # must have at least start_time
                                continue

                            # Localize for status calculation
                            start_local = start_dt.astimezone(somali_tz)
                            end_local   = end_dt.astimezone(somali_tz) if end_dt else None

                            # --- 2-state status ---
                            if end_local and now > end_local:
                                status = "Finished"
                            else:
                                status = "Ongoing"   # UI will display "Continue"

                            # Duration (minutes) if ended, else fallback
                            if end_dt:
                                duration_minutes = int((end_dt - start_dt).total_seconds() // 60)
                            else:
                                duration_minutes = int(data.get("duration", 0))

                            subject = data.get("subject") or data.get("course") or str(course_doc.id)

                            result.append({
                                "id": session.id,
                                "subject": subject,
                                "start_time": start_dt.astimezone(pytz.UTC).isoformat(),
                                "end_time": end_dt.astimezone(pytz.UTC).isoformat() if end_dt else None,
                                "date": start_local.date().isoformat(),
                                "status": status,  # Finished | Ongoing
                                "duration_minutes": duration_minutes,
                                "faculty": faculty.id,
                                "department": department.id,
                                "class": class_doc.id,
                                "course": course_doc.id,
                            })

        return result

    except Exception as e:
        logger.error(f"⚠ Error fetching sessions: {e}")
        return []


def get_dashboard_summary():
    """
    Keep your existing 'today' logic; recompute active (ongoing) using the same
    2-state rule as above so the top card matches the Recent Sessions table.
    """
    try:
        somali_tz = pytz.timezone("Africa/Mogadishu")
        now = datetime.now(somali_tz)
        today = now.date()

        sessions_today = 0
        active_sessions = 0

        sessions = get_all_sessions()
        for s in sessions:
            # date is local date string like 'YYYY-MM-DD'
            sess_date = s.get("date")
            if sess_date:
                try:
                    if datetime.fromisoformat(sess_date).date() == today:
                        sessions_today += 1
                except Exception:
                    pass

            if s.get("status") == "Ongoing":
                active_sessions += 1

        return {
            "sessions_today": sessions_today,
            "active_sessions": active_sessions
        }

    except Exception as e:
        print(f"⚠ Error in get_dashboard_summary: {e}")
        return {"sessions_today": 0, "active_sessions": 0}


# === Attendance Summary ===
def get_today_attendance():
    try:
        from datetime import datetime
        import pytz

        somali_tz = pytz.timezone("Africa/Mogadishu")
        today = datetime.now(somali_tz).date()

        all_student_ids = []
        present_ids = set()

        # 🔁 Traverse nested collections
        faculties = db.collection("faculties").stream()
        for faculty in faculties:
            departments = db.collection("faculties").document(faculty.id).collection("departments").stream()
            for department in departments:
                classes = db.collection("faculties").document(faculty.id) \
                            .collection("departments").document(department.id) \
                            .collection("classes").stream()
                for class_doc in classes:
                    students = db.collection("faculties").document(faculty.id) \
                                .collection("departments").document(department.id) \
                                .collection("classes").document(class_doc.id) \
                                .collection("students").stream()
                    for student_doc in students:
                        student_data = student_doc.to_dict()
                        student_id = student_data.get("student_id", student_doc.id)
                        all_student_ids.append(student_id)

        # ✅ Check today's attendance records
        attendance_docs = db.collection("attendance").stream()
        for doc in attendance_docs:
            record = doc.to_dict()
            entry_time = record.get("entry_time")

            if entry_time and entry_time.astimezone(somali_tz).date() == today:
                present_ids.add(record.get("student_id"))

        absent_ids = set(all_student_ids) - present_ids

        return {
            "total": len(all_student_ids),
            "present": len(present_ids),
            "absent": len(absent_ids),
            "present_ids": list(present_ids),
            "absent_ids": list(absent_ids)
        }

    except Exception as e:
        print(f"⚠ Error fetching attendance: {e}")
        return {
            "total": 0,
            "present": 0,
            "absent": 0,
            "present_ids": [],
            "absent_ids": []
        }



def get_students():
    try:
        result = []
        faculties = db.collection("faculties").stream()

        for faculty in faculties:
            faculty_data = faculty.to_dict()
            faculty_name = faculty_data.get("Name", "Unknown Faculty")

            departments = db.collection("faculties").document(faculty.id).collection("departments").stream()

            for department in departments:
                dept_data = department.to_dict()
                dept_name = dept_data.get("Name", "Unknown Department")

                classes = db.collection("faculties").document(faculty.id) \
                            .collection("departments").document(department.id) \
                            .collection("classes").stream()

                for class_doc in classes:
                    class_data = class_doc.to_dict()
                    class_name = class_data.get("Name", "Unknown Class")

                    students = db.collection("faculties").document(faculty.id) \
                                .collection("departments").document(department.id) \
                                .collection("classes").document(class_doc.id) \
                                .collection("students").stream()

                    for student_doc in students:
                        student_data = student_doc.to_dict()
                        result.append({
                            "student_id": student_data.get("student_id", student_doc.id),
                            "name": student_data.get("full_name", ""),
                            "status": student_data.get("status", "Unknown"),
                            "faculty": faculty_name,
                            "department": dept_name,
                            "class": class_name
                        })

        return result

    except Exception as e:
        print(f"⚠ Error fetching nested students: {e}")
        return []



def get_attendance_for_session(session_id):
    try:
        somali_tz = pytz.timezone("Africa/Mogadishu")

        # Step 1: Find session location
        session_found = None
        faculties = db.collection("faculties").stream()
        for faculty in faculties:
            departments = db.collection("faculties").document(faculty.id).collection("departments").stream()
            for department in departments:
                classes = db.collection("faculties").document(faculty.id).collection("departments").document(department.id).collection("classes").stream()
                for class_doc in classes:
                    courses = db.collection("faculties").document(faculty.id).collection("departments").document(department.id).collection("classes").document(class_doc.id).collection("courses").stream()
                    for course in courses:
                        sessions = db.collection("faculties").document(faculty.id) \
                            .collection("departments").document(department.id) \
                            .collection("classes").document(class_doc.id) \
                            .collection("courses").document(course.id) \
                            .collection("sessions").stream()

                        for session_doc in sessions:
                            if session_doc.id == session_id:
                                session_found = {
                                    "faculty": faculty.id,
                                    "department": department.id,
                                    "class_id": class_doc.id,
                                    "course_id": course.id
                                }
                                break
                    if session_found: break
                if session_found: break
            if session_found: break

        if not session_found:
            return {"error": "Session not found"}, 404

        # Step 2: Read attendance data
        attendance_ref = db.collection("faculties").document(session_found["faculty"]) \
            .collection("departments").document(session_found["department"]) \
            .collection("classes").document(session_found["class_id"]) \
            .collection("courses").document(session_found["course_id"]) \
            .collection("sessions").document(session_id) \
            .collection("attendance")

        attendance_docs = attendance_ref.stream()
        students = []

        for doc in attendance_docs:
            data = doc.to_dict()
            student_name = data.get("student_name", "")
            status = data.get("status", "-")
            entry_time = data.get("entry_time")
            exit_time = data.get("exit_time")

            # 🟢 Fetch real student_id by matching full_name
            student_id = "-"
            student_query = db.collection("faculties").document(session_found["faculty"]) \
                .collection("departments").document(session_found["department"]) \
                .collection("classes").document(session_found["class_id"]) \
                .collection("students").where("full_name", "==", student_name).limit(1).stream()

            for stu in student_query:
                stu_data = stu.to_dict()
                student_id = stu_data.get("student_id", "-")
                break

            # Format entry and exit time
            entry_time_str = format_datetime(entry_time) if entry_time and isinstance(entry_time, datetime) else "-"
            exit_time_str = format_datetime(exit_time) if exit_time and isinstance(exit_time, datetime) else "-"

            students.append({
                "student_id": student_id,
                "name": student_name,
                "status": status,
                "entry_time": entry_time_str,
                "exit_time": exit_time_str,
                "duration": data.get("duration", 0)
                    
            })

        return {
            "session_id": session_id,
            "course_id": session_found["course_id"],
            "class_id": session_found["class_id"],
            "students": students
        }
    

    except Exception as e:
        print(f"⚠ Error fetching session attendance: {e}")
        return {"error": str(e)}, 500
