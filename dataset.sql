-- =========================
-- DROP TABLES
-- =========================
DROP TABLE IF EXISTS electives;
DROP TABLE IF EXISTS student_grades;
DROP TABLE IF EXISTS student_timetable;
DROP TABLE IF EXISTS faculty_timetable;
DROP TABLE IF EXISTS faculty_profiles;
DROP TABLE IF EXISTS admin_profiles;
DROP TABLE IF EXISTS student_profiles;
DROP TABLE IF EXISTS users;

-- =========================
-- USERS
-- =========================
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role TEXT NOT NULL CHECK(role IN ('Student', 'Faculty', 'Admin'))
);

-- =========================
-- PROFILES
-- =========================
CREATE TABLE student_profiles (
    student_id INTEGER PRIMARY KEY,
    register_number TEXT UNIQUE NOT NULL,
    department TEXT NOT NULL,
    program TEXT NOT NULL,
    semester INTEGER NOT NULL,
    section TEXT NOT NULL,
    cgpa REAL NOT NULL,
    credits_earned INTEGER NOT NULL,
    FOREIGN KEY(student_id) REFERENCES users(id)
);

CREATE TABLE faculty_profiles (
    faculty_id INTEGER PRIMARY KEY,
    employee_id TEXT UNIQUE NOT NULL,
    department TEXT NOT NULL,
    designation TEXT NOT NULL,
    specialization TEXT NOT NULL,
    FOREIGN KEY(faculty_id) REFERENCES users(id)
);

CREATE TABLE admin_profiles (
    admin_id INTEGER PRIMARY KEY,
    employee_id TEXT UNIQUE NOT NULL,
    department TEXT NOT NULL,
    designation TEXT NOT NULL,
    FOREIGN KEY(admin_id) REFERENCES users(id)
);

-- =========================
-- TIMETABLES
-- =========================
CREATE TABLE student_timetable (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER NOT NULL,
    day_order INTEGER NOT NULL,
    subject TEXT NOT NULL,
    course_code TEXT NOT NULL,
    start_time TEXT NOT NULL,
    end_time TEXT NOT NULL,
    room TEXT NOT NULL,
    FOREIGN KEY(student_id) REFERENCES users(id)
);

CREATE TABLE faculty_timetable (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    faculty_id INTEGER,
    day_order INTEGER,
    subject TEXT,
    course_code TEXT,
    start_time TEXT,
    end_time TEXT,
    room TEXT
);

-- =========================
-- GRADES
-- =========================
CREATE TABLE student_grades (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER NOT NULL,
    semester INTEGER NOT NULL,
    subject TEXT NOT NULL,
    course_code TEXT NOT NULL,
    credits INTEGER NOT NULL,
    grade TEXT NOT NULL
);

-- =========================
-- MATERIALS & ELECTIVES
-- =========================
CREATE TABLE materials (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    semester INTEGER NOT NULL,
    subject TEXT NOT NULL,
    course_code TEXT NOT NULL,
    material_title TEXT NOT NULL,
    file_type TEXT NOT NULL,
    uploaded_by INTEGER NOT NULL,
    file_link TEXT,
    uploaded_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE electives (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    semester INTEGER NOT NULL,
    subject TEXT NOT NULL,
    course_code TEXT NOT NULL,
    type TEXT NOT NULL,
    faculty_incharge TEXT NOT NULL,
    credits INTEGER NOT NULL,
    description TEXT NOT NULL
);

CREATE TABLE elective_materials (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    elective_id INTEGER NOT NULL,
    material_title TEXT NOT NULL,
    file_type TEXT NOT NULL,
    uploaded_by INTEGER NOT NULL,
    file_link TEXT,
    uploaded_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- USERS DATA
-- =========================
INSERT INTO users VALUES
(1, 'Varun Bhat', 'varun.bhat@srmist.edu.in', '12345', 'Student'),
(2, 'Ananya Sharma', 'ananya.sharma@srmist.edu.in', '12345', 'Student'),
(3, 'Priya Nair', 'priya.nair@srmist.edu.in', '12345', 'Student'),
(4, 'Aarav Kapoor', 'aarav.kapoor@srmist.edu.in', '12345', 'Student'),
(5, 'Ishita Verma', 'ishita.verma@srmist.edu.in', '12345', 'Student'),
(6, 'Rahul Menon', 'rahul.menon@srmist.edu.in', '12345', 'Student'),
(7, 'Sneha Iyer', 'sneha.iyer@srmist.edu.in', '12345', 'Student'),
(8, 'Karan Malhotra', 'karan.malhotra@srmist.edu.in', '12345', 'Student'),
(9, 'Meera Joshi', 'meera.joshi@srmist.edu.in', '12345', 'Student'),
(10, 'Aditya Rao', 'aditya.rao@srmist.edu.in', '12345', 'Student'),
(11, 'Nikita Singh', 'nikita.singh@srmist.edu.in', '12345', 'Student'),
(12, 'Riddhi Mehrotra', 'rm8537@srmist.edu.in', '12345', 'Student'),
(13, 'Tanvi Reddy', 'tanvi.reddy@srmist.edu.in', '12345', 'Student'),
(14, 'Arjun Das', 'arjun.das@srmist.edu.in', '12345', 'Student'),
(15, 'Pooja Krishnan', 'pooja.krishnan@srmist.edu.in', '12345', 'Student'),

(101, 'Dr. Kavitha Raman', 'kavitha.raman@srmist.edu.in', '12345', 'Faculty'),
(102, 'Dr. Suresh Kumar', 'suresh.kumar@srmist.edu.in', '12345', 'Faculty'),
(103, 'Dr. Deepa Narayanan', 'deepa.narayanan@srmist.edu.in', '12345', 'Faculty'),
(104, 'Prof. Manoj Pillai', 'manoj.pillai@srmist.edu.in', '12345', 'Faculty'),
(105, 'Dr. Lakshmi Priya', 'lakshmi.priya@srmist.edu.in', '12345', 'Faculty'),
(106, 'Prof. Arvind Raj', 'arvind.raj@srmist.edu.in', '12345', 'Faculty'),

(201, 'Admin Office', 'admin@srmist.edu.in', '12345', 'Admin');
INSERT INTO admin_profiles VALUES
(201, 'ADM1001', 'CSE', 'System Administrator');
-- =========================
-- STUDENT PROFILES (SEM 1–6)
-- =========================

INSERT INTO student_profiles VALUES
(1,'RA2311003012373','CSE','B.Tech',1,'AB1',8.6,20),
(2,'RA2311003012363','CSE','B.Tech',1,'A2',8.3,22),
(3,'RA2311003012364','CSE','B.Tech',2,'AB2',8.0,35),
(4,'RA2311003012365','CSE','B.Tech',2,'B2',7.9,36),
(5,'RA2311003012366','CSE','B.Tech',3,'C',8.2,50),
(6,'RA2311003012367','CSE','B.Tech',3,'C1',7.8,48),
(7,'RA2311003012368','CSE','B.Tech',4,'D1',8.3,68),
(8,'RA2311003012369','CSE','B.Tech',4,'D2',8.1,67),
(9,'RA2311003012370','CSE','B.Tech',5,'E1',8.5,90),
(10,'RA2311003012371','CSE','B.Tech',5,'E2',8.2,92),
(11,'RA2311003012372','CSE','B.Tech',5,'E2',8.4,94),
(12,'RA2311003012362','CSE','B.Tech',6,'R2',8.9,120),
(13,'RA2311003012374','CSE','B.Tech',6,'F1',8.7,112),
(14,'RA2311003012375','CSE','B.Tech',6,'F2',8.3,108),
(15,'RA2311003012376','CSE','B.Tech',6,'F3',8.4,109);

-- =========================
-- FACULTY PROFILES
-- =========================
INSERT INTO faculty_profiles VALUES
(101,'EMP1001','CSE','Associate Professor','DBMS'),
(102,'EMP1002','CSE','Assistant Professor','Compiler'),
(103,'EMP1003','CSE','Professor','Software Engineering'),
(104,'EMP1004','CSE','Assistant Professor','Cloud'),
(105,'EMP1005','CSE','Associate Professor','AI/ML'),
(106,'EMP1006','CSE','Assistant Professor','IoT');

-- =========================
-- STUDENT TIMETABLE (BASED ON YOUR REAL CSE COURSES SEM 1–6)
-- =========================
DELETE FROM student_timetable;

-- -------------------------------------------------
-- SEMESTER 1 STUDENTS: 1, 2
-- -------------------------------------------------
INSERT INTO student_timetable (student_id, day_order, subject, course_code, start_time, end_time, room) VALUES
-- Student 1
(1,1,'Constitution of India','21LEM101T','08:00 AM','08:50 AM','AB1-101'),
(1,1,'Communicative English','21LEH101T','09:00 AM','09:50 AM','AB1-102'),
(1,1,'Calculus and Linear Algebra','21MAB101T','10:00 AM','10:50 AM','AB1-103'),
(1,1,'Calculus and Linear Algebra','21MAB101T','10:55 AM','11:45 AM','AB1-103'),
(1,1,'Semiconductor Physics and Computational Methods','21PYB102J','12:25 PM','01:15 PM','AB1-104'),


(1,2,'Semiconductor Physics and Computational Methods','21PYB102J','08:00 AM','08:50 AM','AB1-104'),
(1,2,'Electrical and Electronics Engineering','21EES101T','09:00 AM','09:50 AM','AB1-105'),
(1,2,'Programming for Problem Solving','21CSS101J','10:00 AM','10:50 AM','AB1-106'),

(1,3,'Environmental Science','21CYM101T','08:00 AM','08:50 AM','AB1-107'),
(1,3,'Engineering Graphics and Design','21MES102L','09:00 AM','09:50 AM','AB1-108'),
(1,3,'Professional Skills and Practices','21PDM101L','10:00 AM','10:50 AM','AB1-109'),

(1,4,'Calculus and Linear Algebra','21MAB101T','08:00 AM','08:50 AM','AB1-103'),
(1,4,'Programming for Problem Solving','21CSS101J','09:00 AM','09:50 AM','AB1-106'),
(1,4,'Communicative English','21LEH101T','10:00 AM','10:50 AM','AB1-102'),

(1,5,'Semiconductor Physics and Computational Methods','21PYB102J','08:00 AM','08:50 AM','AB1-104'),
(1,5,'Environmental Science','21CYM101T','09:00 AM','09:50 AM','AB1-107'),
(1,5,'Constitution of India','21LEM101T','10:00 AM','10:50 AM','AB1-101'),

-- Student 2
(2,1,'Communicative English','21LEH101T','08:00 AM','08:50 AM','AB1-102'),
(2,1,'Calculus and Linear Algebra','21MAB101T','09:00 AM','09:50 AM','AB1-103'),
(2,1,'Programming for Problem Solving','21CSS101J','10:00 AM','10:50 AM','AB1-106'),

(2,2,'Constitution of India','21LEM101T','08:00 AM','08:50 AM','AB1-101'),
(2,2,'Semiconductor Physics and Computational Methods','21PYB102J','09:00 AM','09:50 AM','AB1-104'),
(2,2,'Electrical and Electronics Engineering','21EES101T','10:00 AM','10:50 AM','AB1-105'),

(2,3,'Environmental Science','21CYM101T','08:00 AM','08:50 AM','AB1-107'),
(2,3,'Engineering Graphics and Design','21MES102L','09:00 AM','09:50 AM','AB1-108'),
(2,3,'Professional Skills and Practices','21PDM101L','10:00 AM','10:50 AM','AB1-109'),

(2,4,'Calculus and Linear Algebra','21MAB101T','08:00 AM','08:50 AM','AB1-103'),
(2,4,'Communicative English','21LEH101T','09:00 AM','09:50 AM','AB1-102'),
(2,4,'Programming for Problem Solving','21CSS101J','10:00 AM','10:50 AM','AB1-106'),

(2,5,'Electrical and Electronics Engineering','21EES101T','08:00 AM','08:50 AM','AB1-105'),
(2,5,'Environmental Science','21CYM101T','09:00 AM','09:50 AM','AB1-107'),
(2,5,'Constitution of India','21LEM101T','10:00 AM','10:50 AM','AB1-101');


-- -------------------------------------------------
-- SEMESTER 2 STUDENTS: 3, 4
-- -------------------------------------------------
INSERT INTO student_timetable (student_id, day_order, subject, course_code, start_time, end_time, room) VALUES
-- Student 3
(3,1,'German','21LEH104T','08:00 AM','08:50 AM','AB2-201'),
(3,1,'Advanced Calculus and Complex Analysis','21MAB102T','09:00 AM','09:50 AM','AB2-202'),
(3,1,'Chemistry','21CYB101J','10:00 AM','10:50 AM','AB2-203'),

(3,2,'Introduction to Computational Biology','21BTB102T','08:00 AM','08:50 AM','AB2-204'),
(3,2,'Philosophy of Engineering','21GNH101J','09:00 AM','09:50 AM','AB2-205'),
(3,2,'Object Oriented Design and Programming','21CSC101T','10:00 AM','10:50 AM','AB2-206'),

(3,3,'General Aptitude','21PDM102L','08:00 AM','08:50 AM','AB2-207'),
(3,3,'Basic Civil and Mechanical Workshop','21MES101L','09:00 AM','09:50 AM','AB2-208'),
(3,3,'Physical and Mental Health Using Yoga','21GNM101L','10:00 AM','10:50 AM','AB2-209'),

(3,4,'Advanced Calculus and Complex Analysis','21MAB102T','08:00 AM','08:50 AM','AB2-202'),
(3,4,'Chemistry','21CYB101J','09:00 AM','09:50 AM','AB2-203'),
(3,4,'Object Oriented Design and Programming','21CSC101T','10:00 AM','10:50 AM','AB2-206'),

(3,5,'German','21LEH104T','08:00 AM','08:50 AM','AB2-201'),
(3,5,'Philosophy of Engineering','21GNH101J','09:00 AM','09:50 AM','AB2-205'),
(3,5,'Introduction to Computational Biology','21BTB102T','10:00 AM','10:50 AM','AB2-204'),

-- Student 4
(4,1,'Advanced Calculus and Complex Analysis','21MAB102T','08:00 AM','08:50 AM','AB2-202'),
(4,1,'German','21LEH104T','09:00 AM','09:50 AM','AB2-201'),
(4,1,'Object Oriented Design and Programming','21CSC101T','10:00 AM','10:50 AM','AB2-206'),

(4,2,'Chemistry','21CYB101J','08:00 AM','08:50 AM','AB2-203'),
(4,2,'Introduction to Computational Biology','21BTB102T','09:00 AM','09:50 AM','AB2-204'),
(4,2,'Philosophy of Engineering','21GNH101J','10:00 AM','10:50 AM','AB2-205'),

(4,3,'General Aptitude','21PDM102L','08:00 AM','08:50 AM','AB2-207'),
(4,3,'Basic Civil and Mechanical Workshop','21MES101L','09:00 AM','09:50 AM','AB2-208'),
(4,3,'Physical and Mental Health Using Yoga','21GNM101L','10:00 AM','10:50 AM','AB2-209'),

(4,4,'Chemistry','21CYB101J','08:00 AM','08:50 AM','AB2-203'),
(4,4,'Advanced Calculus and Complex Analysis','21MAB102T','09:00 AM','09:50 AM','AB2-202'),
(4,4,'German','21LEH104T','10:00 AM','10:50 AM','AB2-201'),

(4,5,'Object Oriented Design and Programming','21CSC101T','08:00 AM','08:50 AM','AB2-206'),
(4,5,'Philosophy of Engineering','21GNH101J','09:00 AM','09:50 AM','AB2-205'),
(4,5,'Introduction to Computational Biology','21BTB102T','10:00 AM','10:50 AM','AB2-204');


-- -------------------------------------------------
-- SEMESTER 3 STUDENTS: 5, 6
-- -------------------------------------------------
INSERT INTO student_timetable (student_id, day_order, subject, course_code, start_time, end_time, room) VALUES
-- Student 5
(5,1,'Transforms and Boundary Value Problems','21MAB201T','08:00 AM','08:50 AM','AB3-301'),
(5,1,'Data Structures and Algorithms','21CSC201J','09:00 AM','09:50 AM','AB3-302'),
(5,1,'Operating Systems','21CSC202J','10:00 AM','10:50 AM','AB3-303'),

(5,2,'Computer Organization and Architecture','21CSS201T','08:00 AM','08:50 AM','AB3-304'),
(5,2,'Advanced Programming Practice','21CSC203P','09:00 AM','09:50 AM','AB3-305'),
(5,2,'Design Thinking and Methodology','21DCS201P','10:00 AM','10:50 AM','AB3-306'),

(5,3,'Professional Ethics','21LEM201T','08:00 AM','08:50 AM','AB3-307'),
(5,3,'Data Structures and Algorithms','21CSC201J','09:00 AM','09:50 AM','AB3-302'),
(5,3,'Operating Systems','21CSC202J','10:00 AM','10:50 AM','AB3-303'),

(5,4,'Transforms and Boundary Value Problems','21MAB201T','08:00 AM','08:50 AM','AB3-301'),
(5,4,'Computer Organization and Architecture','21CSS201T','09:00 AM','09:50 AM','AB3-304'),
(5,4,'Advanced Programming Practice','21CSC203P','10:00 AM','10:50 AM','AB3-305'),

(5,5,'Design Thinking and Methodology','21DCS201P','08:00 AM','08:50 AM','AB3-306'),
(5,5,'Professional Ethics','21LEM201T','09:00 AM','09:50 AM','AB3-307'),
(5,5,'Data Structures and Algorithms','21CSC201J','10:00 AM','10:50 AM','AB3-302'),

-- Student 6
(6,1,'Data Structures and Algorithms','21CSC201J','08:00 AM','08:50 AM','AB3-302'),
(6,1,'Operating Systems','21CSC202J','09:00 AM','09:50 AM','AB3-303'),
(6,1,'Transforms and Boundary Value Problems','21MAB201T','10:00 AM','10:50 AM','AB3-301'),

(6,2,'Advanced Programming Practice','21CSC203P','08:00 AM','08:50 AM','AB3-305'),
(6,2,'Computer Organization and Architecture','21CSS201T','09:00 AM','09:50 AM','AB3-304'),
(6,2,'Design Thinking and Methodology','21DCS201P','10:00 AM','10:50 AM','AB3-306'),

(6,3,'Professional Ethics','21LEM201T','08:00 AM','08:50 AM','AB3-307'),
(6,3,'Operating Systems','21CSC202J','09:00 AM','09:50 AM','AB3-303'),
(6,3,'Data Structures and Algorithms','21CSC201J','10:00 AM','10:50 AM','AB3-302'),

(6,4,'Transforms and Boundary Value Problems','21MAB201T','08:00 AM','08:50 AM','AB3-301'),
(6,4,'Advanced Programming Practice','21CSC203P','09:00 AM','09:50 AM','AB3-305'),
(6,4,'Computer Organization and Architecture','21CSS201T','10:00 AM','10:50 AM','AB3-304'),

(6,5,'Design Thinking and Methodology','21DCS201P','08:00 AM','08:50 AM','AB3-306'),
(6,5,'Professional Ethics','21LEM201T','09:00 AM','09:50 AM','AB3-307'),
(6,5,'Operating Systems','21CSC202J','10:00 AM','10:50 AM','AB3-303');


-- -------------------------------------------------
-- SEMESTER 4 STUDENTS: 7, 8
-- -------------------------------------------------
INSERT INTO student_timetable (student_id, day_order, subject, course_code, start_time, end_time, room) VALUES
-- Student 7
(7,1,'Probability and Queueing Theory','21MAB204T','08:00 AM','08:50 AM','AB4-401'),
(7,1,'Design and Analysis of Algorithms','21CSC204J','09:00 AM','09:50 AM','AB4-402'),
(7,1,'Database Management Systems','21CSC205P','10:00 AM','10:50 AM','AB4-403'),

(7,2,'Artificial Intelligence','21CSC206T','08:00 AM','08:50 AM','AB4-404'),
(7,2,'Digital Image Processing','21CSE251T','09:00 AM','09:50 AM','AB4-405'),
(7,2,'Social Engineering','21PDH209T','10:00 AM','10:50 AM','AB4-406'),

(7,3,'Universal Human Values - II: Understanding Harmony and Ethical Human Conduct','21LEM202T','08:00 AM','08:50 AM','AB4-407'),
(7,3,'Probability and Queueing Theory','21MAB204T','09:00 AM','09:50 AM','AB4-401'),
(7,3,'Design and Analysis of Algorithms','21CSC204J','10:00 AM','10:50 AM','AB4-402'),

(7,4,'Database Management Systems','21CSC205P','08:00 AM','08:50 AM','AB4-403'),
(7,4,'Artificial Intelligence','21CSC206T','09:00 AM','09:50 AM','AB4-404'),
(7,4,'Digital Image Processing','21CSE251T','10:00 AM','10:50 AM','AB4-405'),

(7,5,'Social Engineering','21PDH209T','08:00 AM','08:50 AM','AB4-406'),
(7,5,'Universal Human Values - II: Understanding Harmony and Ethical Human Conduct','21LEM202T','09:00 AM','09:50 AM','AB4-407'),
(7,5,'Database Management Systems','21CSC205P','10:00 AM','10:50 AM','AB4-403'),

-- Student 8
(8,1,'Design and Analysis of Algorithms','21CSC204J','08:00 AM','08:50 AM','AB4-402'),
(8,1,'Probability and Queueing Theory','21MAB204T','09:00 AM','09:50 AM','AB4-401'),
(8,1,'Artificial Intelligence','21CSC206T','10:00 AM','10:50 AM','AB4-404'),

(8,2,'Database Management Systems','21CSC205P','08:00 AM','08:50 AM','AB4-403'),
(8,2,'Digital Image Processing','21CSE251T','09:00 AM','09:50 AM','AB4-405'),
(8,2,'Social Engineering','21PDH209T','10:00 AM','10:50 AM','AB4-406'),

(8,3,'Universal Human Values - II: Understanding Harmony and Ethical Human Conduct','21LEM202T','08:00 AM','08:50 AM','AB4-407'),
(8,3,'Probability and Queueing Theory','21MAB204T','09:00 AM','09:50 AM','AB4-401'),
(8,3,'Database Management Systems','21CSC205P','10:00 AM','10:50 AM','AB4-403'),

(8,4,'Artificial Intelligence','21CSC206T','08:00 AM','08:50 AM','AB4-404'),
(8,4,'Design and Analysis of Algorithms','21CSC204J','09:00 AM','09:50 AM','AB4-402'),
(8,4,'Digital Image Processing','21CSE251T','10:00 AM','10:50 AM','AB4-405'),

(8,5,'Social Engineering','21PDH209T','08:00 AM','08:50 AM','AB4-406'),
(8,5,'Universal Human Values - II: Understanding Harmony and Ethical Human Conduct','21LEM202T','09:00 AM','09:50 AM','AB4-407'),
(8,5,'Probability and Queueing Theory','21MAB204T','10:00 AM','10:50 AM','AB4-401');


-- -------------------------------------------------
-- SEMESTER 5 STUDENTS: 9, 10, 11
-- -------------------------------------------------
INSERT INTO student_timetable (student_id, day_order, subject, course_code, start_time, end_time, room) VALUES
-- Student 9
(9,1,'Discrete Mathematics','21MAB302T','08:00 AM','08:50 AM','AB5-501'),
(9,1,'Formal Language and Automata','21CSC301T','09:00 AM','09:50 AM','AB5-502'),
(9,1,'Computer Networks','21CSC302J','10:00 AM','10:50 AM','AB5-503'),

(9,2,'Machine Learning','21CSC305P','08:00 AM','08:50 AM','AB5-504'),
(9,2,'SERBOT: Project-Based Learning in Robotics','21CSE305P','09:00 AM','09:50 AM','AB5-505'),
(9,2,'Clean and Green Energy','21EEO307T','10:00 AM','10:50 AM','AB5-506'),

(9,3,'Indian Art Form','21LEM301T','08:00 AM','08:50 AM','AB5-507'),
(9,3,'Community Connect','21GNP301L','09:00 AM','09:50 AM','AB5-508'),
(9,3,'Discrete Mathematics','21MAB302T','10:00 AM','10:50 AM','AB5-501'),

(9,4,'Formal Language and Automata','21CSC301T','08:00 AM','08:50 AM','AB5-502'),
(9,4,'Computer Networks','21CSC302J','09:00 AM','09:50 AM','AB5-503'),
(9,4,'Machine Learning','21CSC305P','10:00 AM','10:50 AM','AB5-504'),

(9,5,'SERBOT: Project-Based Learning in Robotics','21CSE305P','08:00 AM','08:50 AM','AB5-505'),
(9,5,'Clean and Green Energy','21EEO307T','09:00 AM','09:50 AM','AB5-506'),
(9,5,'Indian Art Form','21LEM301T','10:00 AM','10:50 AM','AB5-507'),

-- Student 10
(10,1,'Formal Language and Automata','21CSC301T','08:00 AM','08:50 AM','AB5-502'),
(10,1,'Discrete Mathematics','21MAB302T','09:00 AM','09:50 AM','AB5-501'),
(10,1,'Machine Learning','21CSC305P','10:00 AM','10:50 AM','AB5-504'),

(10,2,'Computer Networks','21CSC302J','08:00 AM','08:50 AM','AB5-503'),
(10,2,'SERBOT: Project-Based Learning in Robotics','21CSE305P','09:00 AM','09:50 AM','AB5-505'),
(10,2,'Clean and Green Energy','21EEO307T','10:00 AM','10:50 AM','AB5-506'),

(10,3,'Indian Art Form','21LEM301T','08:00 AM','08:50 AM','AB5-507'),
(10,3,'Community Connect','21GNP301L','09:00 AM','09:50 AM','AB5-508'),
(10,3,'Formal Language and Automata','21CSC301T','10:00 AM','10:50 AM','AB5-502'),

(10,4,'Discrete Mathematics','21MAB302T','08:00 AM','08:50 AM','AB5-501'),
(10,4,'Computer Networks','21CSC302J','09:00 AM','09:50 AM','AB5-503'),
(10,4,'Machine Learning','21CSC305P','10:00 AM','10:50 AM','AB5-504'),

(10,5,'SERBOT: Project-Based Learning in Robotics','21CSE305P','08:00 AM','08:50 AM','AB5-505'),
(10,5,'Clean and Green Energy','21EEO307T','09:00 AM','09:50 AM','AB5-506'),
(10,5,'Indian Art Form','21LEM301T','10:00 AM','10:50 AM','AB5-507'),

-- Student 11
(11,1,'Computer Networks','21CSC302J','08:00 AM','08:50 AM','AB5-503'),
(11,1,'Discrete Mathematics','21MAB302T','09:00 AM','09:50 AM','AB5-501'),
(11,1,'Formal Language and Automata','21CSC301T','10:00 AM','10:50 AM','AB5-502'),

(11,2,'Machine Learning','21CSC305P','08:00 AM','08:50 AM','AB5-504'),
(11,2,'SERBOT: Project-Based Learning in Robotics','21CSE305P','09:00 AM','09:50 AM','AB5-505'),
(11,2,'Clean and Green Energy','21EEO307T','10:00 AM','10:50 AM','AB5-506'),

(11,3,'Community Connect','21GNP301L','08:00 AM','08:50 AM','AB5-508'),
(11,3,'Indian Art Form','21LEM301T','09:00 AM','09:50 AM','AB5-507'),
(11,3,'Computer Networks','21CSC302J','10:00 AM','10:50 AM','AB5-503'),

(11,4,'Formal Language and Automata','21CSC301T','08:00 AM','08:50 AM','AB5-502'),
(11,4,'Discrete Mathematics','21MAB302T','09:00 AM','09:50 AM','AB5-501'),
(11,4,'Machine Learning','21CSC305P','10:00 AM','10:50 AM','AB5-504'),

(11,5,'SERBOT: Project-Based Learning in Robotics','21CSE305P','08:00 AM','08:50 AM','AB5-505'),
(11,5,'Clean and Green Energy','21EEO307T','09:00 AM','09:50 AM','AB5-506'),
(11,5,'Indian Art Form','21LEM301T','10:00 AM','10:50 AM','AB5-507');


-- -------------------------------------------------
-- SEMESTER 6 STUDENTS: 12, 13, 14, 15
-- -------------------------------------------------
INSERT INTO student_timetable (student_id, day_order, subject, course_code, start_time, end_time, room) VALUES
-- Student 12
(12,1,'Environmental Impact Assessment','21ICEO306T','08:00 AM','08:50 AM','LH221'),
(12,1,'Software Engineering and Project Management','21CSC303J','09:00 AM','09:50 AM','LH614'),
(12,1,'Compiler Design','21CSC304J','10:00 AM','10:50 AM','LH614'),
(12,1,'Compiler Design','21CSC304J','10:55 AM','11:45 AM','LH614'),
(12,1,'No Slots','N/A','12:25 PM','01:15 PM','N/A'),
(12,1,'Software Engineering and Project Management','21CSC303J','01:20 PM','02:10 PM','LH614'),

(12,2,'Software Engineering and Project Management','21CSC303J','08:00 AM','08:50 AM','LH614'),
(12,2,'Software Engineering and Project Management','21CSC303J','08:50 AM','09:40 AM','LH614'),
(12,2,'Environmental Impact Assessment','21ICEO306T','09:45 AM','10:35 AM','LH221'),
(12,2,'Environmental Impact Assessment','21ICEO306T','10:40 AM','11:30 AM','LH221'),
(12,2,'Enterprise Cloud Engineering for Insurance Technology','21CSE734P','11:35 AM','12:25 PM','LH1306'),
(12,2,'Compiler Design','21CSC304J','03:10 PM','04:00 PM','CLS414'),
(12,2,'Compiler Design','21CSC304J','04:00 PM','04:50 PM','CLS414'), 


(12,3,'Compiler Design','21CSC304J','12:30 PM','01:20 PM','LH614'),
(12,3,'Compiler Design','21CSC304J','01:25 PM','02:15 PM','LH614'),
(12,3,'Enterprise Cloud Engineering for Insurance Technology','21CSE734P','02:20 PM','03:10 PM','LH1306'),
(12,3,'Augmented, Virtual and Mixed Reality','21CSE353T','03:10 PM','04:00 PM','LH320'),
(12,3,'Software Engineering and Project Management','21CSC303J','04:00 PM','04:50 PM','LH614'),

(12,4,'Compiler Design','21CSC304J','08:00 AM','08:50 AM','LH614'),
(12,4,'Augmented, Virtual and Mixed Reality','21CSE353T','09:00 AM','09:50 AM','LH614'),
(12,4,'Environmental Impact Assessment','21ICEO306T','10:00 AM','10:50 AM','LH221'),

(12,5,'Compiler Design','21CSC304J','02:20 PM','03:10 PM','LH614'),
(12,5,'Data Science','21CSS303T','03:10 PM','04:00 PM','LH614'),
(12,3,'Augmented, Virtual and Mixed Reality','21CSE353T','04:00 PM','04:50 PM','LH320'),
(12,5,'Project','21CSP302L','04:50 PM','05:30 PM','N/A'),


-- Student 13
(13,1,'Software Engineering and Project Management','21CSC303J','08:00 AM','08:50 AM','AB6-602'),
(13,1,'Environmental Impact Assessment','21ICEO306T','09:00 AM','09:50 AM','AB6-601'),
(13,1,'Compiler Design','21CSC304J','10:00 AM','10:50 AM','AB6-603'),

(13,2,'Project','21CSP302L','08:00 AM','08:50 AM','AB6-606'),
(13,2,'Augmented, Virtual and Mixed Reality','21CSE353T','09:00 AM','09:50 AM','AB6-604'),
(13,2,'Enterprise Cloud Engineering for Insurance Technology','21CSE734P','10:00 AM','10:50 AM','AB6-605'),

(13,3,'Data Science','21CSS303T','08:00 AM','08:50 AM','AB6-607'),
(13,3,'Indian Traditional Knowledge','21LEM302T','09:00 AM','09:50 AM','AB6-608'),
(13,3,'Compiler Design','21CSC304J','10:00 AM','10:50 AM','AB6-603'),

(13,4,'Software Engineering and Project Management','21CSC303J','08:00 AM','08:50 AM','AB6-602'),
(13,4,'Environmental Impact Assessment','21ICEO306T','09:00 AM','09:50 AM','AB6-601'),
(13,4,'Augmented, Virtual and Mixed Reality','21CSE353T','10:00 AM','10:50 AM','AB6-604'),

(13,5,'Project','21CSP302L','08:00 AM','08:50 AM','AB6-606'),
(13,5,'Data Science','21CSS303T','09:00 AM','09:50 AM','AB6-607'),
(13,5,'Indian Traditional Knowledge','21LEM302T','10:00 AM','10:50 AM','AB6-608'),

-- Student 14
(14,1,'Compiler Design','21CSC304J','08:00 AM','08:50 AM','AB6-603'),
(14,1,'Software Engineering and Project Management','21CSC303J','09:00 AM','09:50 AM','AB6-602'),
(14,1,'Environmental Impact Assessment','21ICEO306T','10:00 AM','10:50 AM','AB6-601'),

(14,2,'Enterprise Cloud Engineering for Insurance Technology','21CSE734P','08:00 AM','08:50 AM','AB6-605'),
(14,2,'Augmented, Virtual and Mixed Reality','21CSE353T','09:00 AM','09:50 AM','AB6-604'),
(14,2,'Project','21CSP302L','10:00 AM','10:50 AM','AB6-606'),

(14,3,'Indian Traditional Knowledge','21LEM302T','08:00 AM','08:50 AM','AB6-608'),
(14,3,'Data Science','21CSS303T','09:00 AM','09:50 AM','AB6-607'),
(14,3,'Compiler Design','21CSC304J','10:00 AM','10:50 AM','AB6-603'),

(14,4,'Software Engineering and Project Management','21CSC303J','08:00 AM','08:50 AM','AB6-602'),
(14,4,'Environmental Impact Assessment','21ICEO306T','09:00 AM','09:50 AM','AB6-601'),
(14,4,'Project','21CSP302L','10:00 AM','10:50 AM','AB6-606'),

(14,5,'Augmented, Virtual and Mixed Reality','21CSE353T','08:00 AM','08:50 AM','AB6-604'),
(14,5,'Enterprise Cloud Engineering for Insurance Technology','21CSE734P','09:00 AM','09:50 AM','AB6-605'),
(14,5,'Data Science','21CSS303T','10:00 AM','10:50 AM','AB6-607'),

-- Student 15
(15,1,'Environmental Impact Assessment','21ICEO306T','08:00 AM','08:50 AM','AB6-601'),
(15,1,'Compiler Design','21CSC304J','09:00 AM','09:50 AM','AB6-603'),
(15,1,'Software Engineering and Project Management','21CSC303J','10:00 AM','10:50 AM','AB6-602'),

(15,2,'Project','21CSP302L','08:00 AM','08:50 AM','AB6-606'),
(15,2,'Augmented, Virtual and Mixed Reality','21CSE353T','09:00 AM','09:50 AM','AB6-604'),
(15,2,'Enterprise Cloud Engineering for Insurance Technology','21CSE734P','10:00 AM','10:50 AM','AB6-605'),

(15,3,'Data Science','21CSS303T','08:00 AM','08:50 AM','AB6-607'),
(15,3,'Indian Traditional Knowledge','21LEM302T','09:00 AM','09:50 AM','AB6-608'),
(15,3,'Environmental Impact Assessment','21ICEO306T','10:00 AM','10:50 AM','AB6-601'),

(15,4,'Compiler Design','21CSC304J','08:00 AM','08:50 AM','AB6-603'),
(15,4,'Software Engineering and Project Management','21CSC303J','09:00 AM','09:50 AM','AB6-602'),
(15,4,'Data Science','21CSS303T','10:00 AM','10:50 AM','AB6-607'),

(15,5,'Project','21CSP302L','08:00 AM','08:50 AM','AB6-606'),
(15,5,'Augmented, Virtual and Mixed Reality','21CSE353T','09:00 AM','09:50 AM','AB6-604'),
(15,5,'Indian Traditional Knowledge','21LEM302T','10:00 AM','10:50 AM','AB6-608');

DELETE FROM student_timetable
WHERE subject = 'No Slots' OR course_code = 'N/A';

-- =========================
-- STUDENT GRADES
-- =========================
INSERT INTO student_grades (student_id, semester, subject, course_code, credits, grade) VALUES

-- Student 1 (Semester 1)
(1, 1, 'Constitution of India', '21LEM101T', 0, 'O'),
(1, 1, 'Communicative English', '21LEH101T', 3, 'A'),
(1, 1, 'Calculus and Linear Algebra', '21MAB101T', 4, 'A+'),
(1, 1, 'Semiconductor Physics and Computational Methods', '21PYB102J', 4, 'A'),
(1, 1, 'Electrical and Electronics Engineering', '21EES101T', 3, 'B+'),
(1, 1, 'Programming for Problem Solving', '21CSS101J', 4, 'A'),
(1, 1, 'Environmental Science', '21CYM101T', 0, 'O'),
(1, 1, 'Engineering Graphics and Design', '21MES102L', 2, 'A'),
(1, 1, 'Professional Skills and Practices', '21PDM101L', 0, 'O'),

-- Student 2 (Semester 1)
(2, 1, 'Constitution of India', '21LEM101T', 0, 'A+'),
(2, 1, 'Communicative English', '21LEH101T', 3, 'A'),
(2, 1, 'Calculus and Linear Algebra', '21MAB101T', 4, 'A'),
(2, 1, 'Semiconductor Physics and Computational Methods', '21PYB102J', 4, 'B+'),
(2, 1, 'Electrical and Electronics Engineering', '21EES101T', 3, 'A'),
(2, 1, 'Programming for Problem Solving', '21CSS101J', 4, 'A+'),
(2, 1, 'Environmental Science', '21CYM101T', 0, 'O'),
(2, 1, 'Engineering Graphics and Design', '21MES102L', 2, 'A'),
(2, 1, 'Professional Skills and Practices', '21PDM101L', 0, 'O'),

-- Student 3 (Semester 2)
(3, 2, 'German', '21LEH104T', 3, 'A'),
(3, 2, 'Advanced Calculus and Complex Analysis', '21MAB102T', 4, 'A+'),
(3, 2, 'Chemistry', '21CYB101J', 5, 'A'),
(3, 2, 'Introduction to Computational Biology', '21BTB102T', 2, 'B+'),
(3, 2, 'Philosophy of Engineering', '21GNH101J', 2, 'A'),
(3, 2, 'Object Oriented Design and Programming', '21CSC101T', 3, 'A+'),
(3, 2, 'General Aptitude', '21PDM102L', 0, 'O'),
(3, 2, 'Basic Civil and Mechanical Workshop', '21MES101L', 2, 'A'),
(3, 2, 'Physical and Mental Health Using Yoga', '21GNM101L', 0, 'O'),

-- Student 4 (Semester 2)
(4, 2, 'German', '21LEH104T', 3, 'B+'),
(4, 2, 'Advanced Calculus and Complex Analysis', '21MAB102T', 4, 'A'),
(4, 2, 'Chemistry', '21CYB101J', 5, 'A'),
(4, 2, 'Introduction to Computational Biology', '21BTB102T', 2, 'A'),
(4, 2, 'Philosophy of Engineering', '21GNH101J', 2, 'B+'),
(4, 2, 'Object Oriented Design and Programming', '21CSC101T', 3, 'A'),
(4, 2, 'General Aptitude', '21PDM102L', 0, 'O'),
(4, 2, 'Basic Civil and Mechanical Workshop', '21MES101L', 2, 'A'),
(4, 2, 'Physical and Mental Health Using Yoga', '21GNM101L', 0, 'O'),

-- Student 5 (Semester 3)
(5, 3, 'Transforms and Boundary Value Problems', '21MAB201T', 4, 'A'),
(5, 3, 'Data Structures and Algorithms', '21CSC201J', 4, 'A+'),
(5, 3, 'Operating Systems', '21CSC202J', 4, 'A'),
(5, 3, 'Computer Organization and Architecture', '21CSS201T', 4, 'B+'),
(5, 3, 'Advanced Programming Practice', '21CSC203P', 4, 'A'),
(5, 3, 'Design Thinking and Methodology', '21DCS201P', 3, 'A'),
(5, 3, 'Professional Ethics', '21LEM201T', 0, 'O'),

-- Student 6 (Semester 3)
(6, 3, 'Transforms and Boundary Value Problems', '21MAB201T', 4, 'B+'),
(6, 3, 'Data Structures and Algorithms', '21CSC201J', 4, 'A'),
(6, 3, 'Operating Systems', '21CSC202J', 4, 'A'),
(6, 3, 'Computer Organization and Architecture', '21CSS201T', 4, 'A'),
(6, 3, 'Advanced Programming Practice', '21CSC203P', 4, 'A+'),
(6, 3, 'Design Thinking and Methodology', '21DCS201P', 3, 'A'),
(6, 3, 'Professional Ethics', '21LEM201T', 0, 'O'),

-- Student 7 (Semester 4)
(7, 4, 'Probability and Queueing Theory', '21MAB204T', 4, 'A'),
(7, 4, 'Design and Analysis of Algorithms', '21CSC204J', 4, 'A+'),
(7, 4, 'Database Management Systems', '21CSC205P', 4, 'A'),
(7, 4, 'Artificial Intelligence', '21CSC206T', 3, 'A'),
(7, 4, 'Digital Image Processing', '21CSE251T', 3, 'B+'),
(7, 4, 'Social Engineering', '21PDH209T', 2, 'A'),
(7, 4, 'Universal Human Values - II: Understanding Harmony and Ethical Human Conduct', '21LEM202T', 3, 'A'),

-- Student 8 (Semester 4)
(8, 4, 'Probability and Queueing Theory', '21MAB204T', 4, 'B+'),
(8, 4, 'Design and Analysis of Algorithms', '21CSC204J', 4, 'A'),
(8, 4, 'Database Management Systems', '21CSC205P', 4, 'A+'),
(8, 4, 'Artificial Intelligence', '21CSC206T', 3, 'A'),
(8, 4, 'Digital Image Processing', '21CSE251T', 3, 'A'),
(8, 4, 'Social Engineering', '21PDH209T', 2, 'A'),
(8, 4, 'Universal Human Values - II: Understanding Harmony and Ethical Human Conduct', '21LEM202T', 3, 'B+'),

-- Student 9 (Semester 5)
(9, 5, 'Discrete Mathematics', '21MAB302T', 4, 'A'),
(9, 5, 'Formal Language and Automata', '21CSC301T', 3, 'A'),
(9, 5, 'Computer Networks', '21CSC302J', 4, 'A+'),
(9, 5, 'Machine Learning', '21CSC305P', 3, 'A'),
(9, 5, 'SERBOT: Project-Based Learning in Robotics', '21CSE305P', 3, 'A'),
(9, 5, 'Clean and Green Energy', '21EEO307T', 3, 'B+'),
(9, 5, 'Indian Art Form', '21LEM301T', 0, 'O'),
(9, 5, 'Community Connect', '21GNP301L', 1, 'O'),

-- Student 10 (Semester 5)
(10, 5, 'Discrete Mathematics', '21MAB302T', 4, 'A'),
(10, 5, 'Formal Language and Automata', '21CSC301T', 3, 'B+'),
(10, 5, 'Computer Networks', '21CSC302J', 4, 'A'),
(10, 5, 'Machine Learning', '21CSC305P', 3, 'A+'),
(10, 5, 'SERBOT: Project-Based Learning in Robotics', '21CSE305P', 3, 'A'),
(10, 5, 'Clean and Green Energy', '21EEO307T', 3, 'A'),
(10, 5, 'Indian Art Form', '21LEM301T', 0, 'O'),
(10, 5, 'Community Connect', '21GNP301L', 1, 'O'),

-- Student 11 (Semester 5)
(11, 5, 'Discrete Mathematics', '21MAB302T', 4, 'A+'),
(11, 5, 'Formal Language and Automata', '21CSC301T', 3, 'A'),
(11, 5, 'Computer Networks', '21CSC302J', 4, 'A'),
(11, 5, 'Machine Learning', '21CSC305P', 3, 'A'),
(11, 5, 'SERBOT: Project-Based Learning in Robotics', '21CSE305P', 3, 'B+'),
(11, 5, 'Clean and Green Energy', '21EEO307T', 3, 'A'),
(11, 5, 'Indian Art Form', '21LEM301T', 0, 'O'),
(11, 5, 'Community Connect', '21GNP301L', 1, 'O'),

-- Student 12 (Semester 6) - Riddhi
(12, 6, 'Environmental Impact Assessment', '21ICEO306T', 3, 'A'),
(12, 6, 'Software Engineering and Project Management', '21CSC303J', 4, 'A+'),
(12, 6, 'Compiler Design', '21CSC304J', 4, 'O'),
(12, 6, 'Augmented, Virtual and Mixed Reality', '21CSE353T', 3, 'A'),
(12, 6, 'Enterprise Cloud Engineering for Insurance Technology', '21CSE734P', 3, 'A'),
(12, 6, 'Project', '21CSP302L', 2, 'O'),
(12, 6, 'Data Science', '21CSS303T', 3, 'A+'),
(12, 6, 'Indian Traditional Knowledge', '21LEM302T', 2, 'A'),

-- Student 13 (Semester 6)
(13, 6, 'Environmental Impact Assessment', '21ICEO306T', 3, 'A'),
(13, 6, 'Software Engineering and Project Management', '21CSC303J', 4, 'A'),
(13, 6, 'Compiler Design', '21CSC304J', 4, 'A+'),
(13, 6, 'Augmented, Virtual and Mixed Reality', '21CSE353T', 3, 'A'),
(13, 6, 'Enterprise Cloud Engineering for Insurance Technology', '21CSE734P', 3, 'B+'),
(13, 6, 'Project', '21CSP302L', 2, 'A'),
(13, 6, 'Data Science', '21CSS303T', 3, 'A'),
(13, 6, 'Indian Traditional Knowledge', '21LEM302T', 2, 'O'),

-- Student 14 (Semester 6)
(14, 6, 'Environmental Impact Assessment', '21ICEO306T', 3, 'B+'),
(14, 6, 'Software Engineering and Project Management', '21CSC303J', 4, 'A'),
(14, 6, 'Compiler Design', '21CSC304J', 4, 'A'),
(14, 6, 'Augmented, Virtual and Mixed Reality', '21CSE353T', 3, 'A+'),
(14, 6, 'Enterprise Cloud Engineering for Insurance Technology', '21CSE734P', 3, 'A'),
(14, 6, 'Project', '21CSP302L', 2, 'A'),
(14, 6, 'Data Science', '21CSS303T', 3, 'A'),
(14, 6, 'Indian Traditional Knowledge', '21LEM302T', 2, 'A'),

-- Student 15 (Semester 6)
(15, 6, 'Environmental Impact Assessment', '21ICEO306T', 3, 'A'),
(15, 6, 'Software Engineering and Project Management', '21CSC303J', 4, 'B+'),
(15, 6, 'Compiler Design', '21CSC304J', 4, 'A'),
(15, 6, 'Augmented, Virtual and Mixed Reality', '21CSE353T', 3, 'A'),
(15, 6, 'Enterprise Cloud Engineering for Insurance Technology', '21CSE734P', 3, 'A+'),
(15, 6, 'Project', '21CSP302L', 2, 'O'),
(15, 6, 'Data Science', '21CSS303T', 3, 'A'),
(15, 6, 'Indian Traditional Knowledge', '21LEM302T', 2, 'A');
-- =========================
-- FACULTY TIMETABLE
-- =========================

DELETE FROM faculty_timetable;

INSERT INTO faculty_timetable (faculty_id, day_order, subject, course_code, start_time, end_time, room) VALUES

-- 101 : Dr. Kavitha Raman (2 subjects)
(101, 1, 'DBMS', 'CS301', '08:00 AM', '08:50 AM', 'TP1414'),
(101, 1,'Advanced DBMS','CS401','11:35 AM', '12:25 PM','TP604'),
(101, 1, 'DBMS', 'CS301', '08:50 AM', '09:40 AM', 'LH221'),
(101, 2, 'DBMS', 'CS301', '08:50 AM', '09:40 AM', 'LH512'),
(101, 2, 'Advanced DBMS', 'CS401', '04:00 PM', '04:50 PM', 'TP604'),
(101, 3, 'Advanced DBMS', 'CS401', '10:40 AM', '11:30 AM', 'TP301'),
(101, 3, 'Advanced DBMS', 'CS401', '12:30 PM', '1:20 PM', 'TP604'),
(101, 4, 'Advanced DBMS', 'CS401', '11:35 AM', '12:25 PM', 'TP301'),
(101, 5, 'DBMS', 'CS301', '01:25 PM', '02:15 PM', 'LH221'),

-- 102 : Dr. Suresh Kumar (2 subjects)
(102, 1, 'Compiler Design', '21CSC304J', '08:00 AM', '08:50 AM', 'LH614'),
(102, 1, 'Compiler Design', '21CSC304J', '08:50 AM', '09:40 AM', 'LH614'),
(102, 1, 'Formal Languages', 'CS305', '12:30 PM', '01:20 PM', 'LH615'),
(102, 1, 'Formal Languages', 'CS305', '03:10 PM', '04:00 PM', 'LH618'),
(102, 2, 'Compiler Design', '21CSC304J', '03:10 PM', '04:00 PM', 'CLS414'),
(102, 3, 'Formal Languages', 'CS305', '12:30 PM', '01:20 PM', 'LH615'),
(102, 3, 'Formal Languages', 'CS305', '01:25 PM', '02:15 PM', 'LH615'),
(102, 4, 'Compiler Design', '21CSC304J', '08:00 AM', '08:50 AM', 'AB6-603'),
(102, 5, 'Formal Languages', 'CS305', '08:50 AM', '09:40 AM', 'LH615'),
(102, 5, 'Formal Languages', 'CS305', '02:20 PM', '03:10 PM', 'LH520'),

-- 103 : Dr. Deepa Narayanan (3 subjects)
(103, 1, 'Software Engineering and Project Management', '21CSC303J', '08:00 AM', '08:50 AM', 'LH614'),
(103, 1, 'Project Management', 'CS402', '01:25 PM', '02:10 PM', 'TP202'),
(103, 1, 'Software Engineering and Project Management', '21CSC303J', '03:10 PM', '04:00 PM', 'TP709'),
(103, 2, 'Software Engineering and Project Management', '21CSC303J', '08:00 AM', '08:50 AM', 'LH614'),
(103, 2, 'Agile Development', 'CS403', '08:50 AM', '09:40 AM', 'LH615'),
(103, 4, 'Agile Development', 'CS403', '08:50 AM', '09:40 AM', 'TP1203'),
(103, 4, 'Agile Development', 'CS403', '09:45 AM', '10:35 AM', 'TP1203'),
(103, 5, 'Project Management', 'CS402', '11:35 AM', '12:25 PM', 'LH1120'),
(103, 5, 'Agile Development', 'CS403', '01:25 PM', '02:15 PM', 'TP1203'),

-- 104 : Prof. Manoj Pillai (1 subject)
(104, 1, 'Enterprise Cloud Engineering for Insurance Technology', '21CSE734P', '02:20 PM', '03:10 PM', 'LH1306'),
(104, 2, 'Enterprise Cloud Engineering for Insurance Technology', '21CSE734P', '11:35 AM', '12:25 PM', 'LH1003'),
(104, 3, 'Enterprise Cloud Engineering for Insurance Technology', '21CSE734P', '09:00 AM', '09:40 AM', 'LH1306'),
(104, 4, 'Enterprise Cloud Engineering for Insurance Technology', '21CSE734P', '09:45 AM', '10:35 AM', 'LH1003'),
(104, 5, 'Enterprise Cloud Engineering for Insurance Technology', '21CSE734P', '11:35 AM', '12:25 PM', 'LH1306'),

-- 105 : Dr. Lakshmi Priya (4 subjects)
(105, 1, 'Machine Learning', '21CSC305P', '09:45 AM', '10:35 AM', 'TP105'),
(105, 1, 'Artificial Intelligence', 'CS502', '11:35 AM', '12:25 PM', 'TP414'),
(105, 2, 'Machine Learning', '21CSC305P', '11:35 AM', '12:25 PM', 'CLS414'),
(105, 2, 'Deep Learning', 'CS503', '12:30 PM', '01:20 PM', 'LH520'),
(105, 3, 'Data Mining', 'CS504', '09:45 AM', '10:35 AM', 'LH1313'),
(105, 3, 'Artificial Intelligence', 'CS502', '10:40 AM', '11:30 AM', 'LH1310'),
(105, 4, 'Deep Learning', 'CS503', '10:40 AM', '11:30 AM', 'LH520'),
(105, 4, 'Machine Learning', '21CSC305P',  '01:25 PM', '02:15 PM', 'CLS412'),
(105, 5, 'Data Mining', 'CS504', '12:30 PM', '01:20 PM', 'LH1313'),

-- 106 : Prof. Arvind Raj (2 subjects)
(106, 1, 'IoT Systems', '21CSE401T', '09:00 AM', '09:40 AM', 'IoT-Lab'),
(106, 2, 'IoT Systems', '21CSE401T', '10:40 AM', '11:30 AM', 'IoT-Lab'),
(106, 3, 'Embedded Systems', 'CS410', '11:35 AM', '12:25 PM', 'Embedded-Lab'),
(106, 4, 'IoT Systems', '21CSE401T', '12:30 PM', '01:20 PM', 'IoT-Lab'),
(106, 4, 'IoT Systems', '21CSE401T', '01:25 PM', '02:15 PM', 'IoT-Lab'),
(106, 5, 'Embedded Systems', 'CS410', '08:50 AM', '09:40 AM', 'Embedded-Lab'),
(106, 5, 'Embedded Systems', 'CS410', '02:20 PM', '03:10 PM', 'Embedded-Lab');
-- =========================
-- MATERIALS
-- =========================
INSERT INTO materials VALUES
(NULL,1,'Maths','MA101','Unit 1 Notes','PDF',101,'#',CURRENT_TIMESTAMP),
(NULL,2,'DSA','CS201','DSA Notes','PDF',102,'#',CURRENT_TIMESTAMP),
(NULL,3,'DBMS','CS301','DBMS Notes','PDF',101,'#',CURRENT_TIMESTAMP),
(NULL,4,'SE','CS303','SE Slides','PPT',103,'#',CURRENT_TIMESTAMP),
(NULL,5,'AI','CS501','AI Notes','PDF',105,'#',CURRENT_TIMESTAMP),
(NULL,6,'Cloud','CS601','Cloud Notes','PDF',104,'#',CURRENT_TIMESTAMP);
DELETE FROM materials
WHERE file_link = '#';
SELECT material_title, file_link FROM materials;

-- =========================
-- ELECTIVES
-- =========================
INSERT INTO electives VALUES
(NULL,2,'Web Dev','CS202E','Professional','Dr. Suresh Kumar',3,'Frontend + backend'),
(NULL,4,'Machine Learning Basics','CS401E','Professional','Dr. Lakshmi Priya',3,'Intro ML'),
(NULL,5,'Deep Learning','CS501E','Professional','Dr. Lakshmi Priya',3,'Advanced ML'),
(NULL,6,'Blockchain','CS601E','Open','Prof. Arvind Raj',3,'Distributed systems');