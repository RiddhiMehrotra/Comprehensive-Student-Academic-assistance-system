import sqlite3

conn = sqlite3.connect("student_assistant.db")
cursor = conn.cursor()

cursor.execute("""
CREATE TABLE IF NOT EXISTS elective_materials (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    elective_id INTEGER NOT NULL,
    material_title TEXT NOT NULL,
    file_type TEXT NOT NULL,
    uploaded_by INTEGER NOT NULL,
    file_link TEXT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
""")

conn.commit()
conn.close()

print("elective_materials table created")