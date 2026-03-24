from flask import Flask, render_template, request, redirect, url_for, session
import sqlite3
import random
import smtplib
import time
import os
from email.mime.text import MIMEText

app = Flask(__name__, template_folder="frontend")
app.secret_key = "student_assistant_secret_key"

DB_NAME = "student_assistant.db"


def get_db_connection():
    conn = sqlite3.connect(DB_NAME)
    conn.row_factory = sqlite3.Row
    return conn


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


@app.route("/")
def home():
    return redirect(url_for("login"))


@app.route("/login", methods=["GET", "POST"])
def login():
    error = None

    if request.method == "POST":
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
            session["user_id"] = user["id"]
            session["user_name"] = user["full_name"]
            session["user_email"] = user["email"]
            session["user_role"] = user["role"]

            if role == "Student":
                return redirect(url_for("student_dashboard"))
            elif role == "Faculty":
                return redirect(url_for("faculty_dashboard"))
            elif role == "Admin":
                return redirect(url_for("admin_dashboard"))
        else:
            error = "Invalid official email, password, or role."

    return render_template("login.html", error=error)


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
        return render_template(
            "reset_password.html",
            error="Invalid OTP."
        )

    if new_password != confirm_password:
        return render_template(
            "reset_password.html",
            error="Passwords do not match."
        )

    if len(new_password) < 6:
        return render_template(
            "reset_password.html",
            error="Password must be at least 6 characters long."
        )

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

    return render_template(
        "login.html",
        error=None
    )


@app.route("/student/dashboard", methods=["GET"])
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

    enrolled_subjects = conn.execute(
        """
        SELECT subject, course_code, credits, grade
        FROM student_grades
        WHERE student_id = ?
        """,
        (session["user_id"],)
    ).fetchall()

    grades = conn.execute(
        """
        SELECT credits, grade
        FROM student_grades
        WHERE student_id = ?
        """,
        (session["user_id"],)
    ).fetchall()

    today_day_order = get_today_day_order()
    selected_dayorder = request.args.get("dayorder", "").strip()

    if not selected_dayorder:
        selected_dayorder = today_day_order

    if selected_dayorder == "all":
        timetable = conn.execute(
            """
            SELECT * FROM student_timetable
            WHERE student_id = ?
            ORDER BY day_order, start_time
            """,
            (session["user_id"],)
        ).fetchall()
    else:
        timetable = conn.execute(
            """
            SELECT * FROM student_timetable
            WHERE student_id = ? AND day_order = ?
            ORDER BY start_time
            """,
            (session["user_id"], int(selected_dayorder))
        ).fetchall()

    materials = []
    if student_profile:
        materials = conn.execute(
            """
            SELECT * FROM materials
            WHERE semester = ?
            """,
            (student_profile["semester"],)
        ).fetchall()

    current_gpa = calculate_gpa_from_grades(grades)
    user_initial = user["full_name"][0].upper() if user and user["full_name"] else "S"

    conn.close()

    return render_template(
        "dashboard.html",
        user=user,
        user_initial=user_initial,
        student_profile=student_profile,
        enrolled_subjects=enrolled_subjects,
        timetable=timetable,
        materials=materials,
        current_gpa=current_gpa,
        today_day_order=today_day_order,
        selected_dayorder=selected_dayorder
    )


@app.route("/student/profile")
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
        student_profile=student_profile
    )


@app.route("/student/materials")
def materials_page():
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

    materials = []
    if student_profile:
        materials = conn.execute(
            "SELECT * FROM materials WHERE semester = ?",
            (student_profile["semester"],)
        ).fetchall()

    user_initial = user["full_name"][0].upper() if user and user["full_name"] else "S"

    conn.close()

    return render_template("materials.html", user=user, user_initial=user_initial, student_profile=student_profile, materials=materials)


@app.route("/student/electives")
def electives_page():
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

    electives = []
    if student_profile:
        electives = conn.execute(
            "SELECT * FROM electives WHERE semester = ?",
            (student_profile["semester"],)
        ).fetchall()

    user_initial = user["full_name"][0].upper() if user and user["full_name"] else "S"

    conn.close()

    return render_template("electives.html", user=user, user_initial=user_initial, student_profile=student_profile, electives=electives)


@app.route("/student/gpa-calculator")
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

    user_initial = user["full_name"][0].upper() if user and user["full_name"] else "S"

    conn.close()

    return render_template("gpa_calculator.html", user=user, user_initial=user_initial, student_profile=student_profile)


@app.route("/student/academic-progress")
def academic_progress_page():
    if "user_id" not in session or session.get("user_role") != "Student":
        return redirect(url_for("login"))

    conn = get_db_connection()

    student_profile = conn.execute(
        "SELECT * FROM student_profiles WHERE student_id = ?",
        (session["user_id"],)
    ).fetchone()

    grades = conn.execute(
        """
        SELECT subject, course_code, credits, grade
        FROM student_grades
        WHERE student_id = ?
        """,
        (session["user_id"],)
    ).fetchall()

    current_gpa = calculate_gpa_from_grades(
        conn.execute(
            "SELECT credits, grade FROM student_grades WHERE student_id = ?",
            (session["user_id"],)
        ).fetchall()
    )

    conn.close()

    return render_template(
        "academic_progress.html",
        student_profile=student_profile,
        grades=grades,
        current_gpa=current_gpa
    )


@app.route("/faculty/dashboard")
def faculty_dashboard():
    if "user_id" not in session or session.get("user_role") != "Faculty":
        return redirect(url_for("login"))

    conn = get_db_connection()

    user = conn.execute(
        "SELECT * FROM users WHERE id = ?",
        (session["user_id"],)
    ).fetchone()

    faculty = conn.execute(
        "SELECT * FROM faculty_profiles WHERE faculty_id = ?",
        (session["user_id"],)
    ).fetchone()

    conn.close()

    user_initial = user["full_name"][0].upper() if user and user["full_name"] else "F"

    return render_template(
        "faculty_dashboard.html",
        user=user,
        faculty=faculty,
        user_initial=user_initial
    )


@app.route("/admin/dashboard")
def admin_dashboard():
    if "user_id" not in session or session.get("user_role") != "Admin":
        return redirect(url_for("login"))

    conn = get_db_connection()

    user = conn.execute(
        "SELECT * FROM users WHERE id = ?",
        (session["user_id"],)
    ).fetchone()

    admin = conn.execute(
        "SELECT * FROM admin_profiles WHERE admin_id = ?",
        (session["user_id"],)
    ).fetchone()

    conn.close()

    user_initial = user["full_name"][0].upper() if user and user["full_name"] else "A"

    return render_template(
        "admin_dashboard.html",
        user=user,
        admin=admin,
        user_initial=user_initial
    )


@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))


if __name__ == "__main__":
    app.run(debug=True)