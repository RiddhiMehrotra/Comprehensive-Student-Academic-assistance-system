import sqlite3

conn = sqlite3.connect("materials.db")
cursor = conn.cursor()

# ✅ STUDY MATERIALS TABLE
cursor.execute("""
CREATE TABLE IF NOT EXISTS materials (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    semester INTEGER,
    subject TEXT,
    course_code TEXT,
    material_title TEXT,
    file_type TEXT,
    uploaded_by INTEGER,
    file_link TEXT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
""")

# ✅ ELECTIVE MATERIALS TABLE
cursor.execute("""
CREATE TABLE IF NOT EXISTS elective_materials (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    elective_id INTEGER,
    material_title TEXT,
    file_type TEXT,
    uploaded_by INTEGER,
    file_link TEXT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
""")

conn.commit()
conn.close()

print("Materials DB initialized successfully")