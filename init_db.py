import sqlite3

DB_NAME = "student_assistant.db"
SQL_FILE = "dataset.sql"

def initialize_database():
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()

    with open(SQL_FILE, "r", encoding="utf-8") as file:
        sql_script = file.read()

    # Split by semicolon and execute statements individually
    statements = sql_script.split(';')
    for statement in statements:
        statement = statement.strip()
        if statement:
            try:
                cursor.execute(statement)
            except Exception as e:
                print(f"Warning: {e}")
    
    conn.commit()
    conn.close()

    print("Database initialized successfully.")

if __name__ == "__main__":
    initialize_database()