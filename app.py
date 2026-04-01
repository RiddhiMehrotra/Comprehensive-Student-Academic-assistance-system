from flask import Flask, render_template, request, redirect, url_for, session, flash
import sqlite3
import random
import smtplib
import time
import os
from email.mime.text import MIMEText
from werkzeug.utils import secure_filename
from datetime import datetime
from flask import send_from_directory

app = Flask(__name__, template_folder="frontend")
app.secret_key = "student_assistant_secret_key"

DB_NAME = "student_assistant.db"
STUDY_UPLOAD_FOLDER = r"C:\CSAS_STORAGE\study_materials"
ELECTIVE_UPLOAD_FOLDER = r"C:\CSAS_STORAGE\elective_materials"
ALLOWED_EXTENSIONS = {"pdf", "pptx", "docx"}

os.makedirs(STUDY_UPLOAD_FOLDER, exist_ok=True)
os.makedirs(ELECTIVE_UPLOAD_FOLDER, exist_ok=True)

def allowed_file(filename):
    return "." in filename and filename.rsplit(".", 1)[1].lower() in ALLOWED_EXTENSIONS

def save_uploaded_study_file(file):
    if not file or not file.filename:
        return None

    if not allowed_file(file.filename):
        return None

    filename = secure_filename(file.filename)
    base, ext = os.path.splitext(filename)
    timestamp = str(int(time.time()))
    final_name = f"{base}_{timestamp}{ext}"

    file_path = os.path.join(STUDY_UPLOAD_FOLDER, final_name)
    file.save(file_path)

    return final_name

@app.route("/study-materials/<filename>")
def serve_study_material(filename):
    return send_from_directory(STUDY_UPLOAD_FOLDER, filename)

@app.route("/elective-materials/<filename>")
def serve_elective_material(filename):
    return send_from_directory(ELECTIVE_UPLOAD_FOLDER, filename)



def save_uploaded_elective_file(file):
    if not file or not file.filename:
        return None

    if not allowed_file(file.filename):
        return None

    filename = secure_filename(file.filename)
    base, ext = os.path.splitext(filename)
    timestamp = str(int(time.time()))
    final_name = f"{base}_{timestamp}{ext}"

    file_path = os.path.join(ELECTIVE_UPLOAD_FOLDER, final_name)
    file.save(file_path)

    return final_name
# -----------------------------
# Database helpers
# -----------------------------
def get_db_connection():
    conn = sqlite3.connect(DB_NAME)
    conn.row_factory = sqlite3.Row
    return conn

def get_materials_db():
    conn = sqlite3.connect("materials.db")
    conn.row_factory = sqlite3.Row
    return conn

def ensure_schema_updates():
    conn = get_db_connection()
    cursor = conn.cursor()

    # Ensure uploaded_at exists in materials
    cursor.execute("PRAGMA table_info(materials)")
    material_columns = [row["name"] for row in cursor.fetchall()]
    if "uploaded_at" not in material_columns:
        cursor.execute(
            "ALTER TABLE materials ADD COLUMN uploaded_at TEXT DEFAULT CURRENT_TIMESTAMP"
        )

    # Ensure elective_materials table exists
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS elective_materials (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            elective_id INTEGER NOT NULL,
            material_title TEXT NOT NULL,
            file_type TEXT NOT NULL,
            uploaded_by INTEGER NOT NULL,
            file_link TEXT,
            uploaded_at TEXT DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(elective_id) REFERENCES electives(id),
            FOREIGN KEY(uploaded_by) REFERENCES users(id)
        )
    """)

    conn.commit()
    conn.close()


ensure_schema_updates()


# -----------------------------
# Utility helpers
# -----------------------------
def generate_otp():
    return str(random.randint(100000, 999999))


def send_email_otp(receiver_email, otp):
    sender_email = os.getenv("MAIL_EMAIL", "your_email@gmail.com")
    sender_password = os.getenv("MAIL_APP_PASSWORD", "your_app_password")

    subject = "Password Reset OTP"
    body = f"""
Hello,

Your OTP for resetting the password is: {otp}

This OTP is valid for 5 minutes.

If you did not request this, please ignore this email.

Student Assistance Portal
""".strip()

    msg = MIMEText(body)
    msg["Subject"] = subject
    msg["From"] = sender_email
    msg["To"] = receiver_email

    with smtplib.SMTP("smtp.gmail.com", 587) as server:
        server.starttls()
        server.login(sender_email, sender_password)
        server.send_message(msg)


def calculate_gpa_from_grades(grades):
    grade_points = {
        "O": 10,
        "A+": 9,
        "A": 8,
        "B+": 7,
        "B": 6,
        "C": 5,
        "U": 0
    }

    total_points = 0
    total_credits = 0

    for row in grades:
        credits = row["credits"]
        grade = row["grade"]
        points = grade_points.get(grade, 0)
        total_credits += credits
        total_points += credits * points

    return round(total_points / total_credits, 2) if total_credits > 0 else 0.0


def get_today_day_order():
    return "1"


def allowed_file(filename):
    return "." in filename and filename.rsplit(".", 1)[1].lower() in ALLOWED_EXTENSIONS


def save_uploaded_study_file(file):
    if not file or not file.filename:
        return None

    if not allowed_file(file.filename):
        return None

    filename = secure_filename(file.filename)
    base, ext = os.path.splitext(filename)
    timestamp = str(int(time.time()))
    final_name = f"{base}_{timestamp}{ext}"

    file_path = os.path.join(STUDY_UPLOAD_FOLDER, final_name)
    file.save(file_path)

    return final_name
# -----------------------------
# Auth routes
# -----------------------------
@app.route("/")
def home():
    # If already logged in, send user to the correct dashboard
    if "user_id" in session and "user_role" in session:
        role = session.get("user_role")

        if role == "Student":
            return redirect(url_for("student_dashboard"))
        elif role == "Faculty":
            return redirect(url_for("faculty_dashboard"))
        elif role == "Admin":
            return redirect(url_for("admin_dashboard"))

        # invalid role in session
        session.clear()

    return redirect(url_for("login"))


@app.route("/login", methods=["GET", "POST"])
def login():
    # If already logged in and opening /login directly, send to dashboard
    if request.method == "GET":
        if "user_id" in session and "user_role" in session:
            role = session.get("user_role")

            if role == "Student":
                return redirect(url_for("student_dashboard"))
            elif role == "Faculty":
                return redirect(url_for("faculty_dashboard"))
            elif role == "Admin":
                return redirect(url_for("admin_dashboard"))

            session.clear()

        return render_template("login.html", error=None)

    error = None

    email = request.form.get("email", "").strip()
    password = request.form.get("password", "").strip()
    role = request.form.get("role", "").strip()

    conn = get_db_connection()
    user = conn.execute(
        "SELECT * FROM users WHERE email = ? AND password = ? AND role = ?",
        (email, password, role)
    ).fetchone()
    conn.close()

    if user:
        session.clear()
        session["user_id"] = user["id"]
        session["user_name"] = user["full_name"]
        session["user_email"] = user["email"]
        session["user_role"] = user["role"]

        if user["role"] == "Student":
            return redirect(url_for("student_dashboard"))
        elif user["role"] == "Faculty":
            return redirect(url_for("faculty_dashboard"))
        elif user["role"] == "Admin":
            return redirect(url_for("admin_dashboard"))

        session.clear()
        error = "Invalid role mapping in database."
    else:
        error = "Invalid official email, password, or role."

    return render_template("login.html", error=error)

@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))

@app.route("/forgot-password", methods=["GET"])
def forgot_password():
    return render_template("forgot_password.html")


@app.route("/send-otp", methods=["POST"])
def send_otp():
    email = request.form.get("email", "").strip()

    conn = get_db_connection()
    user = conn.execute(
        "SELECT * FROM users WHERE email = ?",
        (email,)
    ).fetchone()
    conn.close()

    if not user:
        return render_template(
            "forgot_password.html",
            error="This email is not registered in the portal."
        )

    otp = generate_otp()

    session["reset_email"] = email
    session["reset_otp"] = otp
    session["otp_created_at"] = int(time.time())

    try:
        send_email_otp(email, otp)
        return render_template(
            "reset_password.html",
            success="OTP sent successfully to your registered email."
        )
    except Exception as e:
        return render_template(
            "forgot_password.html",
            error=f"Failed to send OTP. {str(e)}"
        )


@app.route("/verify-otp", methods=["POST"])
def verify_otp():
    entered_otp = request.form.get("otp", "").strip()
    new_password = request.form.get("new_password", "").strip()
    confirm_password = request.form.get("confirm_password", "").strip()

    if "reset_email" not in session or "reset_otp" not in session or "otp_created_at" not in session:
        return redirect(url_for("forgot_password"))

    current_time = int(time.time())
    otp_age = current_time - session["otp_created_at"]

    if otp_age > 300:
        session.pop("reset_email", None)
        session.pop("reset_otp", None)
        session.pop("otp_created_at", None)
        return render_template(
            "forgot_password.html",
            error="OTP has expired. Please request a new one."
        )

    if entered_otp != session["reset_otp"]:
        return render_template("reset_password.html", error="Invalid OTP.")

    if new_password != confirm_password:
        return render_template("reset_password.html", error="Passwords do not match.")

    if len(new_password) < 6:
        return render_template("reset_password.html", error="Password must be at least 6 characters long.")

    email = session["reset_email"]

    conn = get_db_connection()
    conn.execute(
        "UPDATE users SET password = ? WHERE email = ?",
        (new_password, email)
    )
    conn.commit()
    conn.close()

    session.pop("reset_email", None)
    session.pop("reset_otp", None)
    session.pop("otp_created_at", None)

    return render_template("login.html", error=None)


# -----------------------------
# Student routes
# -----------------------------
@app.route("/student/dashboard")
def student_dashboard():
    if "user_id" not in session or session.get("user_role") != "Student":
        return redirect(url_for("login"))

    conn = get_db_connection()

    user = conn.execute(
        "SELECT * FROM users WHERE id = ?",
        (session["user_id"],)
    ).fetchone()

    student_profile = conn.execute(
        "SELECT * FROM student_profiles WHERE student_id = ?",
        (session["user_id"],)
    ).fetchone()

    current_semester = student_profile["semester"]

    grades = conn.execute(
        """
        SELECT subject, course_code, credits, grade, semester
        FROM student_grades
        WHERE student_id = ?
        ORDER BY semester, subject
        """,
        (session["user_id"],)
    ).fetchall()

    current_gpa = calculate_gpa_from_grades(grades)

    today_day_order = str(get_today_day_order() or 1)
    selected_dayorder = request.args.get("dayorder", today_day_order)

    if selected_dayorder == "all":
        timetable = conn.execute(
    """
    SELECT *
    FROM student_timetable
    WHERE student_id = ?
      AND subject != 'No Slots'
      AND course_code != 'N/A'
    ORDER BY
        day_order,
        CASE
            WHEN start_time LIKE '%AM' THEN
                CASE
                    WHEN substr(start_time, 1, 2) = '12' THEN '00' || substr(start_time, 3, 6)
                    ELSE substr(start_time, 1, 5)
                END
            WHEN start_time LIKE '%PM' THEN
                CASE
                    WHEN substr(start_time, 1, 2) = '12' THEN substr(start_time, 1, 5)
                    ELSE printf('%02d', CAST(substr(start_time, 1, 2) AS INTEGER) + 12) || substr(start_time, 3, 3)
                END
        END
    """,
    (session["user_id"],)
).fetchall()
    else:
        timetable = conn.execute(
    """
    SELECT *
    FROM student_timetable
    WHERE student_id = ?
      AND day_order = ?
      AND subject != 'No Slots'
      AND course_code != 'N/A'
    ORDER BY
        CASE
            WHEN start_time LIKE '%AM' THEN
                CASE
                    WHEN substr(start_time, 1, 2) = '12' THEN '00' || substr(start_time, 3, 6)
                    ELSE substr(start_time, 1, 5)
                END
            WHEN start_time LIKE '%PM' THEN
                CASE
                    WHEN substr(start_time, 1, 2) = '12' THEN substr(start_time, 1, 5)
                    ELSE printf('%02d', CAST(substr(start_time, 1, 2) AS INTEGER) + 12) || substr(start_time, 3, 3)
                END
        END
    """,
    (session["user_id"], int(selected_dayorder))
).fetchall()

    # Completed courses = previous semesters only, with grade
    completed_courses = conn.execute(
        """
        SELECT semester, subject, course_code, credits, grade
        FROM student_grades
        WHERE student_id = ?
          AND semester < ?
        ORDER BY semester DESC, subject
        """,
        (session["user_id"], current_semester)
    ).fetchall()

    # Current semester courses = current sem only, no grade
    current_sem_courses = conn.execute(
        """
        SELECT DISTINCT subject, course_code
        FROM student_timetable
        WHERE student_id = ?
          AND subject != 'No Slots'
          AND course_code != 'N/A'
        ORDER BY subject
        """,
        (session["user_id"],)
    ).fetchall()

    # If you want only actual current-sem subjects from grades table when present:
    current_sem_grade_subjects = conn.execute(
        """
        SELECT subject, course_code
        FROM student_grades
        WHERE student_id = ?
          AND semester = ?
        ORDER BY subject
        """,
        (session["user_id"], current_semester)
    ).fetchall()

    if current_sem_grade_subjects:
        current_sem_courses = current_sem_grade_subjects

    conn.close()

    return render_template(
        "dashboard.html",
        user=user,
        user_initial=user["full_name"][0].upper(),
        student_profile=student_profile,
        current_gpa=current_gpa,
        timetable=timetable,
        today_day_order=today_day_order,
        selected_dayorder=selected_dayorder,
        completed_courses=completed_courses,
        current_sem_courses=current_sem_courses
    )

@app.route("/materials", methods=["GET"])
def materials_page():
    if "user_id" not in session or session.get("user_role") != "Student":
        return redirect(url_for("login"))

    main_conn = get_db_connection()      # users + profiles
    mat_conn = get_materials_db()        # materials DB

    user = main_conn.execute(
        "SELECT * FROM users WHERE id = ?",
        (session["user_id"],)
    ).fetchone()

    student_profile = main_conn.execute(
        "SELECT * FROM student_profiles WHERE student_id = ?",
        (session["user_id"],)
    ).fetchone()

    selected_semester = request.args.get("semester", "").strip()
    selected_subject = request.args.get("subject", "").strip()

    # ---- Fixed semesters (1–6 ALWAYS visible) ----
    semesters = [1, 2, 3, 4, 5, 6]

    # ---- Subjects based on semester ----
    if selected_semester and selected_semester != "all":
        subjects = mat_conn.execute("""
            SELECT DISTINCT subject
            FROM materials
            WHERE semester = ?
            ORDER BY subject
        """, (selected_semester,)).fetchall()
    else:
        subjects = mat_conn.execute("""
            SELECT DISTINCT subject
            FROM materials
            ORDER BY subject
        """).fetchall()

    subjects = [row["subject"] for row in subjects]

    # ---- Filter materials ----
    query = """
        SELECT *
        FROM materials
        WHERE 1=1
    """
    params = []

    if selected_semester and selected_semester != "all":
        query += " AND semester = ?"
        params.append(selected_semester)

    if selected_subject and selected_subject != "all":
        query += " AND subject = ?"
        params.append(selected_subject)

    query += " ORDER BY semester, subject, uploaded_at DESC"

    materials = mat_conn.execute(query, params).fetchall()

    main_conn.close()
    mat_conn.close()

    return render_template(
        "materials.html",
        user=user,
        student_profile=student_profile,
        materials=materials,
        semesters=semesters,
        subjects=subjects,
        selected_semester=selected_semester,
        selected_subject=selected_subject,
        user_initial=user["full_name"][0].upper() if user else "R"
    )


@app.route("/electives")
def electives_page():
    if "user_id" not in session or session.get("user_role") != "Student":
        return redirect(url_for("login"))

    main_conn = get_db_connection()

    user = main_conn.execute(
        "SELECT * FROM users WHERE id = ?",
        (session["user_id"],)
    ).fetchone()

    student_profile = main_conn.execute(
        "SELECT * FROM student_profiles WHERE student_id = ?",
        (session["user_id"],)
    ).fetchone()

    selected_semester = request.args.get("semester", "").strip()
    selected_type = request.args.get("type", "").strip()
    search = request.args.get("search", "").strip()

    electives_query = "SELECT * FROM electives WHERE 1=1"
    electives_params = []

    if selected_semester:
        electives_query += " AND semester = ?"
        electives_params.append(selected_semester)

    if selected_type:
        electives_query += " AND type LIKE ?"
        electives_params.append(f"%{selected_type}%")

    if search:
        electives_query += " AND (subject LIKE ? OR course_code LIKE ? OR faculty_incharge LIKE ?)"
        electives_params.extend([f"%{search}%", f"%{search}%", f"%{search}%"])

    electives_query += " ORDER BY semester, subject"

    electives = main_conn.execute(electives_query, electives_params).fetchall()

    elective_materials = main_conn.execute(
        """
        SELECT
            em.id,
            em.elective_id,
            em.material_title,
            em.file_type,
            em.file_link,
            em.uploaded_at,
            e.subject,
            e.course_code,
            e.semester,
            e.type,
            u.full_name AS uploaded_by_name,
            u.role AS uploaded_by_role
        FROM elective_materials em
        JOIN electives e ON em.elective_id = e.id
        JOIN users u ON em.uploaded_by = u.id
        ORDER BY e.semester, e.subject, em.uploaded_at DESC
        """
    ).fetchall()

    materials_by_elective = {}
    for material in elective_materials:
        elective_id = material["elective_id"]
        if elective_id not in materials_by_elective:
            materials_by_elective[elective_id] = []
        materials_by_elective[elective_id].append(material)

    main_conn.close()

    return render_template(
        "electives.html",
        electives=electives,
        materials_by_elective=materials_by_elective,
        user=user,
        student_profile=student_profile,
        user_initial=user["full_name"][0].upper(),
        selected_semester=selected_semester,
        selected_type=selected_type,
        search=search
    )
@app.route("/gpa-calculator")
def gpa_calculator_page():
    if "user_id" not in session or session.get("user_role") != "Student":
        return redirect(url_for("login"))

    conn = get_db_connection()

    user = conn.execute(
        "SELECT * FROM users WHERE id = ?",
        (session["user_id"],)
    ).fetchone()

    student_profile = conn.execute(
        "SELECT * FROM student_profiles WHERE student_id = ?",
        (session["user_id"],)
    ).fetchone()

    conn.close()

    return render_template(
        "gpa_calculator.html",
        user=user,
        student_profile=student_profile,
        user_initial=user["full_name"][0].upper()
    )

@app.route("/academic-progress")
def academic_progress_page():
    if "user_id" not in session or session.get("user_role") != "Student":
        return redirect(url_for("login"))

    conn = get_db_connection()

    user = conn.execute(
        "SELECT * FROM users WHERE id = ?",
        (session["user_id"],)
    ).fetchone()

    student_profile = conn.execute(
        "SELECT * FROM student_profiles WHERE student_id = ?",
        (session["user_id"],)
    ).fetchone()

    grades = conn.execute(
        """
        SELECT semester, subject, course_code, credits, grade
        FROM student_grades
        WHERE student_id = ?
        ORDER BY semester, subject
        """,
        (session["user_id"],)
    ).fetchall()

    conn.close()

    grade_points = {
        "O": 10,
        "A+": 9,
        "A": 8,
        "B+": 7,
        "B": 6,
        "C": 5,
        "U": 0
    }

    semester_data = {}
    grade_distribution = {
        "O": 0,
        "A+": 0,
        "A": 0,
        "B+": 0,
        "B": 0,
        "C": 0,
        "U": 0
    }

    for row in grades:
        sem = row["semester"]
        credits = row["credits"]
        grade = row["grade"]
        points = grade_points.get(grade, 0)

        if sem not in semester_data:
            semester_data[sem] = {
                "total_points": 0,
                "total_credits": 0
            }

        semester_data[sem]["total_points"] += points * credits
        semester_data[sem]["total_credits"] += credits

        if grade in grade_distribution:
            grade_distribution[grade] += 1

    semester_labels = []
    semester_gpas = []

    for sem in sorted(semester_data.keys()):
        total_points = semester_data[sem]["total_points"]
        total_credits = semester_data[sem]["total_credits"]

        gpa = round(total_points / total_credits, 2) if total_credits > 0 else 0

        semester_labels.append(f"Semester {sem}")
        semester_gpas.append(gpa)

    total_subjects = len(grades)
    cgpa = student_profile["cgpa"] if student_profile else 0
    credits_earned = student_profile["credits_earned"] if student_profile else 0
    current_semester = student_profile["semester"] if student_profile else 0

    return render_template(
        "academic_progress.html",
        user=user,
        student_profile=student_profile,
        user_initial=user["full_name"][0].upper(),
        semester_labels=semester_labels,
        semester_gpas=semester_gpas,
        grade_distribution=grade_distribution,
        total_subjects=total_subjects,
        cgpa=cgpa,
        credits_earned=credits_earned,
        current_semester=current_semester
    )


@app.route("/profile")
def profile_page():
    if "user_id" not in session or session.get("user_role") != "Student":
        return redirect(url_for("login"))

    conn = get_db_connection()

    user = conn.execute(
        "SELECT * FROM users WHERE id = ?",
        (session["user_id"],)
    ).fetchone()

    student_profile = conn.execute(
        "SELECT * FROM student_profiles WHERE student_id = ?",
        (session["user_id"],)
    ).fetchone()

    conn.close()

    return render_template(
        "profile.html",
        user=user,
        student_profile=student_profile,
        user_initial=user["full_name"][0].upper()
    )

# -----------------------------
# Faculty routes
# -----------------------------
@app.route("/faculty/dashboard")
def faculty_dashboard():
    if "user_id" not in session or session.get("user_role") != "Faculty":
        return redirect(url_for("login"))

    faculty_id = int(session["user_id"])
    today_day_order = get_today_day_order()

    conn = get_db_connection()

    user = conn.execute(
        "SELECT * FROM users WHERE id = ? AND role = 'Faculty'",
        (faculty_id,)
    ).fetchone()

    if not user:
        conn.close()
        session.clear()
        flash("Faculty account not found.", "error")
        return redirect(url_for("login"))

    faculty_profile = conn.execute(
        "SELECT * FROM faculty_profiles WHERE faculty_id = ?",
        (faculty_id,)
    ).fetchone()

    all_timetable = conn.execute(
        """
        SELECT *
        FROM faculty_timetable
        WHERE faculty_id = ?
        ORDER BY day_order, start_time
        """,
        (faculty_id,)
    ).fetchall()

    if today_day_order is None:
        timetable = []
    else:
        timetable = conn.execute(
            """
            SELECT *
            FROM faculty_timetable
            WHERE faculty_id = ? AND day_order = ?
            ORDER BY start_time
            """,
            (faculty_id, today_day_order)
        ).fetchall()

    subjects = conn.execute(
        """
        SELECT DISTINCT subject, course_code
        FROM faculty_timetable
        WHERE faculty_id = ?
        ORDER BY subject
        """,
        (faculty_id,)
    ).fetchall()

    full_timetable = conn.execute(
        """
        SELECT *
        FROM faculty_timetable
        WHERE faculty_id = ?
        ORDER BY day_order, start_time
        """,
        (faculty_id,)
    ).fetchall()

    conn.close()

    total_classes = len(all_timetable)
    today_classes = len(timetable)
    total_subjects = len(subjects)

    return render_template(
        "faculty_dashboard.html",
        user=user,
        faculty_profile=faculty_profile,
        user_initial=user["full_name"][0].upper(),
        timetable=timetable,
        today_day_order=today_day_order,
        total_classes=total_classes,
        total_subjects=total_subjects,
        today_classes=today_classes,
        subjects=subjects,
        full_timetable=full_timetable
    )

def get_today_day_order():
    today = datetime.now().weekday()
    # Monday=0, Tuesday=1, Wednesday=2, Thursday=3, Friday=4, Saturday=5, Sunday=6

    day_order_map = {
        0: 1,  # Monday
        1: 2,  # Tuesday
        2: 3,  # Wednesday
        3: 4,  # Thursday
        4: 5   # Friday
    }

    return day_order_map.get(today, None)

def get_faculty_timetable(faculty_id, day_order):
    conn = get_db_connection()
    rows = conn.execute(
        """
        SELECT *
        FROM faculty_timetable
        WHERE faculty_id = ? AND day_order = ?
        ORDER BY start_time
        """,
        (faculty_id, int(day_order))
    ).fetchall()
    conn.close()
    return rows

@app.route("/faculty/materials", methods=["GET", "POST"])
def faculty_materials():
    if "user_id" not in session or session.get("user_role") != "Faculty":
        return redirect(url_for("login"))

    main_conn = get_db_connection()
    mat_conn = get_materials_db()
    
    user = main_conn.execute(
        "SELECT * FROM users WHERE id = ?",
        (session["user_id"],)
        ).fetchone()

    available_semesters = [1, 2, 3, 4, 5, 6]

    semester_subjects = {
        "1": [
            {"subject": "Constitution of India", "course_code": "21LEM101T"},
            {"subject": "Communicative English", "course_code": "21LEH101T"},
            {"subject": "Calculus and Linear Algebra", "course_code": "21MAB101T"},
            {"subject": "Semiconductor Physics and Computational Methods", "course_code": "21PYB102J"},
            {"subject": "Electrical and Electronics Engineering", "course_code": "21EES101T"},
            {"subject": "Programming for Problem Solving", "course_code": "21CSS101J"},
            {"subject": "Environmental Science", "course_code": "21CYM101T"},
            {"subject": "Engineering Graphics and Design", "course_code": "21MES102L"},
            {"subject": "Professional Skills and Practices", "course_code": "21PDM101L"}
        ],
        "2": [
            {"subject": "German", "course_code": "21LEH104T"},
            {"subject": "Advanced Calculus and Complex Analysis", "course_code": "21MAB102T"},
            {"subject": "Chemistry", "course_code": "21CYB101J"},
            {"subject": "Introduction to Computational Biology", "course_code": "21BTB102T"},
            {"subject": "Philosophy of Engineering", "course_code": "21GNH101J"},
            {"subject": "Object Oriented Design and Programming", "course_code": "21CSC101T"},
            {"subject": "General Aptitude", "course_code": "21PDM102L"},
            {"subject": "Basic Civil and Mechanical Workshop", "course_code": "21MES101L"},
            {"subject": "Physical and Mental Health Using Yoga", "course_code": "21GNM101L"}
        ],
        "3": [
            {"subject": "Transforms and Boundary Value Problems", "course_code": "21MAB201T"},
            {"subject": "Data Structures and Algorithms", "course_code": "21CSC201J"},
            {"subject": "Operating Systems", "course_code": "21CSC202J"},
            {"subject": "Computer Organization and Architecture", "course_code": "21CSS201T"},
            {"subject": "Advanced Programming Practice", "course_code": "21CSC203P"},
            {"subject": "Design Thinking and Methodology", "course_code": "21DCS201P"},
            {"subject": "Professional Ethics", "course_code": "21LEM201T"}
        ],
        "4": [
            {"subject": "Probability and Queueing Theory", "course_code": "21MAB204T"},
            {"subject": "Design and Analysis of Algorithms", "course_code": "21CSC204J"},
            {"subject": "Database Management Systems", "course_code": "21CSC205P"},
            {"subject": "Artificial Intelligence", "course_code": "21CSC206T"},
            {"subject": "Digital Image Processing", "course_code": "21CSE251T"},
            {"subject": "Social Engineering", "course_code": "21PDH209T"},
            {"subject": "Universal Human Values - II: Understanding Harmony and Ethical Human Conduct", "course_code": "21LEM202T"}
        ],
        "5": [
            {"subject": "Discrete Mathematics", "course_code": "21MAB302T"},
            {"subject": "Formal Language and Automata", "course_code": "21CSC301T"},
            {"subject": "Computer Networks", "course_code": "21CSC302J"},
            {"subject": "Machine Learning", "course_code": "21CSC305P"},
            {"subject": "SERBOT: Project-Based Learning in Robotics", "course_code": "21CSE305P"},
            {"subject": "Clean and Green Energy", "course_code": "21EEO307T"},
            {"subject": "Indian Art Form", "course_code": "21LEM301T"},
            {"subject": "Community Connect", "course_code": "21GNP301L"}
        ],
        "6": [
            {"subject": "Environmental Impact Assessment", "course_code": "21ICEO306T"},
            {"subject": "Software Engineering and Project Management", "course_code": "21CSC303J"},
            {"subject": "Compiler Design", "course_code": "21CSC304J"},
            {"subject": "Augmented, Virtual and Mixed Reality", "course_code": "21CSE353T"},
            {"subject": "Enterprise Cloud Engineering for Insurance Technology", "course_code": "21CSE734P"},
            {"subject": "Project", "course_code": "21CSP302L"},
            {"subject": "Data Science", "course_code": "21CSS303T"},
            {"subject": "Indian Traditional Knowledge", "course_code": "21LEM302T"}
        ]
    }

    selected_semester = request.args.get("semester", "").strip()
    selected_subject = request.args.get("subject", "").strip()

    subjects = semester_subjects.get(selected_semester, [])

    selected_course_code = ""
    if selected_semester and selected_subject:
        for item in subjects:
            if item["subject"] == selected_subject:
                selected_course_code = item["course_code"]
                break

    if request.method == "POST":
        semester = request.form.get("semester", "").strip()
        subject = request.form.get("subject", "").strip()
        course_code = request.form.get("course_code", "").strip()
        material_title = request.form.get("material_title", "").strip()
        file_type = request.form.get("file_type", "").strip() or "PDF"
        file = request.files.get("file")

        if not semester or not subject or not course_code or not material_title:
            flash("Please fill all required fields.", "error")
            main_conn.close()
            mat_conn.close()
            return redirect(url_for("faculty_materials", semester=selected_semester, subject=selected_subject))

        if not file or not file.filename:
            flash("Please upload a PDF file.", "error")
            main_conn.close()
            mat_conn.close()
            return redirect(url_for("faculty_materials", semester=selected_semester, subject=selected_subject))
        
        existing = mat_conn.execute(
            """
            SELECT id FROM materials
            WHERE subject = ? AND material_title = ? AND uploaded_by = ?
            """,
            (subject, material_title, session["user_id"])
            ).fetchone()
        if existing:
            flash("Material already exists. Delete it first.", "error")
            return redirect(url_for("faculty_materials"))
        saved_file_name = save_uploaded_study_file(file)

        if not saved_file_name:
            flash("Only PDF files are allowed.", "error")
            main_conn.close()
            mat_conn.close()
            return redirect(url_for("faculty_materials", semester=selected_semester, subject=selected_subject))

        mat_conn.execute(
            """
            INSERT INTO materials
            (semester, subject, course_code, material_title, file_type, uploaded_by, file_link)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            (
                int(semester),
                subject,
                course_code,
                material_title,
                file_type,
                session["user_id"],
                saved_file_name
            )
        )
        
        mat_conn.commit()
        main_conn.close()
        mat_conn.close()

        flash("Material uploaded successfully.", "success")
        return redirect(url_for("faculty_materials", semester=semester, subject=subject))

    materials = mat_conn.execute(
        """
        SELECT *
        FROM materials
        WHERE uploaded_by = ?
        ORDER BY id DESC
        """,
        (session["user_id"],)
    ).fetchall()


    main_conn.close()
    mat_conn.close()

    return render_template(
        "faculty_material.html",
        user=user,
        user_initial=user["full_name"][0].upper(),
        materials=materials,
        available_semesters=available_semesters,
        subjects=subjects,
        selected_semester=selected_semester,
        selected_subject=selected_subject,
        selected_course_code=selected_course_code
    )

@app.route("/faculty/materials/delete/<int:material_id>", methods=["POST"])
def delete_material(material_id):
    if "user_id" not in session or session.get("user_role") != "Faculty":
        return redirect(url_for("login"))

    conn = get_materials_db()

    material = conn.execute(
        "SELECT * FROM materials WHERE id = ?",
        (material_id,)
    ).fetchone()

    if not material:
        conn.close()
        flash("Material not found.", "error")
        return redirect(url_for("faculty_materials"))

    filename = material["file_link"]

    conn.execute("DELETE FROM materials WHERE id = ?", (material_id,))
    conn.commit()
    conn.close()

    if filename:
        file_path = os.path.join(STUDY_UPLOAD_FOLDER, filename)
        if os.path.exists(file_path):
            os.remove(file_path)

    flash("Material deleted successfully.", "success")
    return redirect(url_for("faculty_materials"))

@app.route("/preview-material/<int:material_id>")
def preview_material(material_id):
    conn = get_materials_db()

    material = conn.execute(
        "SELECT * FROM materials WHERE id = ?",
        (material_id,)
    ).fetchone()

    conn.close()

    if not material:
        return "File not found", 404

    filename = material["file_link"]   # IMPORTANT: must store this in DB

    return send_from_directory(STUDY_UPLOAD_FOLDER, filename)

@app.route("/faculty/elective-materials", methods=["GET", "POST"])
def faculty_elective_material():
    if "user_id" not in session or session.get("user_role") != "Faculty":
        return redirect(url_for("login"))

    main_conn = get_db_connection()

    user = main_conn.execute(
        "SELECT * FROM users WHERE id = ?",
        (session["user_id"],)
    ).fetchone()

    if not user:
        main_conn.close()
        session.clear()
        flash("Faculty account not found.", "error")
        return redirect(url_for("login"))

    if request.method == "POST":
        elective_id = request.form.get("elective_id", "").strip()
        material_title = request.form.get("material_title", "").strip()
        file_type = request.form.get("file_type", "").strip()
        file = request.files.get("file")

        if not elective_id or not material_title or not file_type:
            flash("Please fill all required fields.", "error")
            main_conn.close()
            return redirect(url_for("faculty_elective_material"))

        if not file or not file.filename:
            flash("Please upload a file.", "error")
            main_conn.close()
            return redirect(url_for("faculty_elective_material"))

        elective = main_conn.execute(
            "SELECT * FROM electives WHERE id = ?",
            (elective_id,)
        ).fetchone()

        if not elective:
            flash("Selected elective not found.", "error")
            main_conn.close()
            return redirect(url_for("faculty_elective_material"))

        saved_file_name = save_uploaded_elective_file(file)

        if not saved_file_name:
            flash("Only PDF, PPTX, and DOCX files are allowed.", "error")
            main_conn.close()
            return redirect(url_for("faculty_elective_material"))

        main_conn.execute(
            """
            INSERT INTO elective_materials
            (elective_id, material_title, file_type, uploaded_by, file_link)
            VALUES (?, ?, ?, ?, ?)
            """,
            (
                elective_id,
                material_title,
                file_type,
                session["user_id"],
                saved_file_name
            )
        )
        main_conn.commit()

        flash("Elective material uploaded successfully.", "success")
        main_conn.close()
        return redirect(url_for("faculty_elective_material"))

    electives = main_conn.execute(
        "SELECT * FROM electives ORDER BY semester ASC, subject ASC"
    ).fetchall()

    uploaded_materials = main_conn.execute(
        """
        SELECT em.*, e.subject, e.course_code, e.type, e.semester
        FROM elective_materials em
        JOIN electives e ON em.elective_id = e.id
        WHERE em.uploaded_by = ?
        ORDER BY em.id DESC
        """,
        (session["user_id"],)
    ).fetchall()

    main_conn.close()

    return render_template(
        "faculty_elective_material.html",
        user=user,
        user_initial=user["full_name"][0].upper(),
        electives=electives,
        uploaded_materials=uploaded_materials
    )


# -----------------------------
# Admin routes
# -----------------------------
# -----------------------------
# Admin routes
# -----------------------------
@app.route("/admin/dashboard")
def admin_dashboard():
    if "user_id" not in session or session.get("user_role") != "Admin":
        return redirect(url_for("login"))

    main_conn = get_db_connection()
    mat_conn = get_materials_db()

    user = main_conn.execute(
        "SELECT * FROM users WHERE id = ?",
        (session["user_id"],)
    ).fetchone()

    admin = main_conn.execute(
        "SELECT * FROM admin_profiles WHERE admin_id = ?",
        (session["user_id"],)
    ).fetchone()

    total_students = main_conn.execute(
        "SELECT COUNT(*) AS count FROM users WHERE role = 'Student'"
    ).fetchone()["count"]

    total_faculty = main_conn.execute(
        "SELECT COUNT(*) AS count FROM users WHERE role = 'Faculty'"
    ).fetchone()["count"]

    total_materials = mat_conn.execute(
        "SELECT COUNT(*) AS count FROM materials"
    ).fetchone()["count"]

    total_electives = main_conn.execute(
        "SELECT COUNT(*) AS count FROM electives"
    ).fetchone()["count"]

    recent_uploads_raw = mat_conn.execute(
        """
        SELECT material_title, file_type, uploaded_by
        FROM materials
        ORDER BY id DESC
        LIMIT 5
        """
    ).fetchall()

    recent_uploads = []
    for item in recent_uploads_raw:
        uploader = main_conn.execute(
            "SELECT full_name FROM users WHERE id = ?",
            (item["uploaded_by"],)
        ).fetchone()

        recent_uploads.append({
            "material_title": item["material_title"],
            "file_type": item["file_type"],
            "full_name": uploader["full_name"] if uploader else "Unknown User"
        })

    main_conn.close()
    mat_conn.close()

    return render_template(
        "admin_dashboard.html",
        user=user,
        admin=admin,
        user_initial=user["full_name"][0].upper(),
        total_students=total_students,
        total_faculty=total_faculty,
        total_materials=total_materials,
        total_electives=total_electives,
        recent_uploads=recent_uploads
    )


@app.route("/admin/materials", methods=["GET", "POST"])
def admin_materials():
    if "user_id" not in session or session.get("user_role") != "Admin":
        return redirect(url_for("login"))

    main_conn = get_db_connection()
    mat_conn = get_materials_db()

    user = main_conn.execute(
        "SELECT * FROM users WHERE id = ?",
        (session["user_id"],)
    ).fetchone()

    if request.method == "POST":
        semester = request.form.get("semester", "").strip()
        subject = request.form.get("subject", "").strip()
        course_code = request.form.get("course_code", "").strip()
        material_title = request.form.get("material_title", "").strip()
        file_type = request.form.get("file_type", "").strip()
        file = request.files.get("file")

        if not semester or not subject or not course_code or not material_title or not file_type:
            flash("Please fill all required fields.", "error")
            main_conn.close()
            mat_conn.close()
            return redirect(url_for("admin_materials"))

        if not file or not file.filename:
            flash("Please upload a file.", "error")
            main_conn.close()
            mat_conn.close()
            return redirect(url_for("admin_materials"))

        saved_path = save_uploaded_study_file(file)

        if not saved_path:
            flash("Only PDF, PPTX, DOCX files are allowed.", "error")
            main_conn.close()
            mat_conn.close()
            return redirect(url_for("admin_materials"))

        mat_conn.execute(
            """
            INSERT INTO materials
            (semester, subject, course_code, material_title, file_type, uploaded_by, file_link)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            (semester, subject, course_code, material_title, file_type, session["user_id"], saved_path)
        )
        mat_conn.commit()

        main_conn.close()
        mat_conn.close()

        flash("Material uploaded successfully.", "success")
        return redirect(url_for("admin_materials"))

    materials_raw = mat_conn.execute(
        """
        SELECT *
        FROM materials
        ORDER BY id DESC
        """
    ).fetchall()

    materials = []
    for item in materials_raw:
        uploader = main_conn.execute(
            "SELECT full_name FROM users WHERE id = ?",
            (item["uploaded_by"],)
        ).fetchone()

        materials.append({
            "semester": item["semester"],
            "subject": item["subject"],
            "course_code": item["course_code"],
            "material_title": item["material_title"],
            "file_type": item["file_type"],
            "file_link": item["file_link"],
            "full_name": uploader["full_name"] if uploader else "Unknown User"
        })

    main_conn.close()
    mat_conn.close()

    return render_template(
        "admin_materials.html",
        user=user,
        user_initial=user["full_name"][0].upper(),
        materials=materials
    )


@app.route("/admin/add-elective", methods=["POST"])
def admin_add_elective():
    if "user_id" not in session or session.get("user_role") != "Admin":
        return redirect(url_for("login"))

    conn = get_db_connection()

    semester = request.form.get("semester", "").strip()
    subject = request.form.get("subject", "").strip()
    course_code = request.form.get("course_code", "").strip()
    elective_type = request.form.get("type", "").strip()
    credits = request.form.get("credits", "").strip()
    faculty_incharge = request.form.get("faculty_incharge", "").strip()
    description = request.form.get("description", "").strip()

    if not semester or not subject or not course_code or not elective_type or not credits or not faculty_incharge or not description:
        flash("Please fill all elective fields.", "error")
        conn.close()
        return redirect(url_for("admin_elective_materials"))

    conn.execute(
        """
        INSERT INTO electives
        (semester, subject, course_code, type, faculty_incharge, credits, description)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """,
        (semester, subject, course_code, elective_type, faculty_incharge, credits, description)
    )
    conn.commit()
    conn.close()

    flash("Elective added successfully.", "success")
    return redirect(url_for("admin_elective_materials"))


@app.route("/admin/elective-materials", methods=["GET", "POST"])
def admin_elective_materials():
    if "user_id" not in session or session.get("user_role") != "Admin":
        return redirect(url_for("login"))

    main_conn = get_db_connection()

    user = main_conn.execute(
        "SELECT * FROM users WHERE id = ?",
        (session["user_id"],)
    ).fetchone()

    if request.method == "POST":
        elective_id = request.form.get("elective_id", "").strip()
        material_title = request.form.get("material_title", "").strip()
        file_type = request.form.get("file_type", "").strip()
        file = request.files.get("file")

        if not elective_id or not material_title or not file_type:
            flash("Please fill all required fields.", "error")
            main_conn.close()
            return redirect(url_for("admin_elective_materials"))

        if not file or not file.filename:
            flash("Please upload a file.", "error")
            main_conn.close()
            return redirect(url_for("admin_elective_materials"))

        saved_file_name = save_uploaded_elective_file(file)

        if not saved_file_name:
            flash("Only PDF, PPTX, DOCX files are allowed.", "error")
            main_conn.close()
            return redirect(url_for("admin_elective_materials"))

        main_conn.execute(
            """
            INSERT INTO elective_materials
            (elective_id, material_title, file_type, uploaded_by, file_link)
            VALUES (?, ?, ?, ?, ?)
            """,
            (elective_id, material_title, file_type, session["user_id"], saved_file_name)
        )
        main_conn.commit()

        flash("Elective material uploaded successfully.", "success")
        main_conn.close()
        return redirect(url_for("admin_elective_materials"))

    semester = request.args.get("semester", "").strip()
    elective_type = request.args.get("type", "").strip()
    search = request.args.get("search", "").strip()

    query = "SELECT * FROM electives WHERE 1=1"
    params = []

    if semester:
        query += " AND semester = ?"
        params.append(semester)

    if elective_type:
        query += " AND type LIKE ?"
        params.append(f"%{elective_type}%")

    if search:
        query += " AND subject LIKE ?"
        params.append(f"%{search}%")

    query += " ORDER BY semester, subject"

    electives = main_conn.execute(query, params).fetchall()

    uploaded_materials = main_conn.execute(
        """
        SELECT em.*, e.subject, e.course_code, e.type, u.full_name
        FROM elective_materials em
        JOIN electives e ON em.elective_id = e.id
        JOIN users u ON em.uploaded_by = u.id
        ORDER BY em.id DESC
        """
    ).fetchall()

    main_conn.close()

    return render_template(
        "admin_elective_materials.html",
        user=user,
        user_initial=user["full_name"][0].upper(),
        electives=electives,
        uploaded_materials=uploaded_materials
    )


if __name__ == "__main__":
    app.run(debug=True)