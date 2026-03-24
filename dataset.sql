DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS student_profiles;
DROP TABLE IF EXISTS faculty_profiles;
DROP TABLE IF EXISTS admin_profiles;
DROP TABLE IF EXISTS student_timetable;
DROP TABLE IF EXISTS student_grades;
DROP TABLE IF EXISTS materials;
DROP TABLE IF EXISTS electives;

CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role TEXT NOT NULL CHECK(role IN ('Student', 'Faculty', 'Admin'))
);

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

CREATE TABLE student_grades (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER NOT NULL,
    semester INTEGER NOT NULL,
    subject TEXT NOT NULL,
    course_code TEXT NOT NULL,
    credits INTEGER NOT NULL,
    grade TEXT NOT NULL,
    FOREIGN KEY(student_id) REFERENCES users(id)
);

CREATE TABLE materials (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    semester INTEGER NOT NULL,
    subject TEXT NOT NULL,
    course_code TEXT NOT NULL,
    material_title TEXT NOT NULL,
    file_type TEXT NOT NULL,
    uploaded_by INTEGER NOT NULL,
    file_link TEXT,
    FOREIGN KEY(uploaded_by) REFERENCES users(id)
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

INSERT INTO users (id, full_name, email, password, role) VALUES
(1, 'Riddhi Mehrotra', 'rm8537@srmist.edu.in', '12345', 'Student'),
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
(12, 'Varun Bhat', 'varun.bhat@srmist.edu.in', '12345', 'Student'),
(13, 'Tanvi Reddy', 'tanvi.reddy@srmist.edu.in', '12345', 'Student'),
(14, 'Arjun Das', 'arjun.das@srmist.edu.in', '12345', 'Student'),
(15, 'Pooja Krishnan', 'pooja.krishnan@srmist.edu.in', '12345', 'Student'),

(101, 'Dr. Kavitha Raman', 'kavitha.raman@srmist.edu.in', '12345', 'Faculty'),
(102, 'Dr. Suresh Kumar', 'suresh.kumar@srmist.edu.in', '12345', 'Faculty'),
(103, 'Dr. Deepa Narayanan', 'deepa.narayanan@srmist.edu.in', '12345', 'Faculty'),
(104, 'Prof. Manoj Pillai', 'manoj.pillai@srmist.edu.in', '12345', 'Faculty'),
(105, 'Dr. Lakshmi Priya', 'lakshmi.priya@srmist.edu.in', '12345', 'Faculty'),
(106, 'Prof. Arvind Raj', 'arvind.raj@srmist.edu.in', '12345', 'Faculty'),

(201, 'Admin Office 1', 'admin1@srmist.edu.in', '12345', 'Admin'),
(202, 'Admin Office 2', 'admin2@srmist.edu.in', '12345', 'Admin'),
(203, 'System Administrator', 'sysadmin@srmist.edu.in', '12345', 'Admin');

INSERT INTO student_profiles (student_id, register_number, department, program, semester, section, cgpa, credits_earned) VALUES
(1, 'RA2311003012362', 'CSE', 'B.Tech', 4, 'R2', 8.10, 68),
(2, 'RA2311003012363', 'CSE', 'B.Tech', 4, 'A', 8.45, 70),
(3, 'RA2311003012364', 'CSE', 'B.Tech', 4, 'A', 8.22, 69),
(4, 'RA2311003012365', 'CSE', 'B.Tech', 4, 'B', 7.98, 66),
(5, 'RA2311003012366', 'CSE', 'B.Tech', 4, 'B', 8.62, 71),
(6, 'RA2311003012367', 'CSE', 'B.Tech', 4, 'B', 7.76, 64),
(7, 'RA2311003012368', 'CSE', 'B.Tech', 4, 'C', 8.31, 68),
(8, 'RA2311003012369', 'CSE', 'B.Tech', 4, 'C', 8.05, 67),
(9, 'RA2311003012370', 'CSE', 'B.Tech', 4, 'C', 8.74, 72),
(10, 'RA2311003012371', 'CSE', 'B.Tech', 4, 'D', 7.89, 65),
(11, 'RA2311003012372', 'CSE', 'B.Tech', 4, 'D', 8.12, 68),
(12, 'RA2311003012373', 'CSE', 'B.Tech', 4, 'D', 8.38, 69),
(13, 'RA2311003012374', 'CSE', 'B.Tech', 4, 'E', 8.56, 70),
(14, 'RA2311003012375', 'CSE', 'B.Tech', 4, 'E', 7.95, 66),
(15, 'RA2311003012376', 'CSE', 'B.Tech', 4, 'E', 8.28, 68);

INSERT INTO faculty_profiles (faculty_id, employee_id, department, designation, specialization) VALUES
(101, 'EMP1001', 'CSE', 'Associate Professor', 'Database Systems'),
(102, 'EMP1002', 'CSE', 'Assistant Professor', 'Compiler Design'),
(103, 'EMP1003', 'CSE', 'Professor', 'Software Engineering'),
(104, 'EMP1004', 'CSE', 'Assistant Professor', 'Cloud Computing'),
(105, 'EMP1005', 'CSE', 'Associate Professor', 'Artificial Intelligence'),
(106, 'EMP1006', 'CSE', 'Assistant Professor', 'IoT');

INSERT INTO admin_profiles (admin_id, employee_id, department, designation) VALUES
(201, 'ADM2001', 'Academic Office', 'Academic Coordinator'),
(202, 'ADM2002', 'Examination Cell', 'Exam Administrator'),
(203, 'ADM2003', 'IT Services', 'System Administrator');


-- Clear old timetable
DELETE FROM student_timetable;

-- =========================
-- STUDENT 1 TIMETABLE
-- =========================
INSERT INTO student_timetable (student_id, day_order, subject, course_code, start_time, end_time, room) VALUES
(1, 1, 'Software Engineering', '21CSC303J', '08:00 AM', '08:50 AM', 'AB1-204'),
(1, 1, 'Compiler Design', '21CSC304J', '09:00 AM', '09:50 AM', 'AB1-205'),
(1, 1, 'Machine Learning', '21CSC305J', '10:00 AM', '10:50 AM', 'AB3-101'),

(1, 2, 'DBMS', '21CSC301J', '08:00 AM', '08:50 AM', 'AB1-201'),
(1, 2, 'Operating Systems', '21CSC302J', '09:00 AM', '09:50 AM', 'AB1-202'),
(1, 2, 'Compiler Design', '21CSC304J', '10:00 AM', '10:50 AM', 'AB1-205'),

(1, 3, 'Software Engineering', '21CSC303J', '08:00 AM', '08:50 AM', 'AB1-204'),
(1, 3, 'Computer Networks', '21CSC306J', '09:00 AM', '09:50 AM', 'AB2-305'),
(1, 3, 'Machine Learning', '21CSC305J', '10:00 AM', '10:50 AM', 'AB3-101'),

(1, 4, 'AR/VR', '21CSE353T', '12:30 PM', '01:20 PM', 'AB2-402'),
(1, 4, 'Software Engineering', '21CSC303J', '02:20 PM', '03:10 PM', 'AB1-204'),

(1, 5, 'Operating Systems', '21CSC302J', '08:00 AM', '08:50 AM', 'AB1-202'),
(1, 5, 'DBMS', '21CSC301J', '09:00 AM', '09:50 AM', 'AB1-201');


-- =========================
-- STUDENT 2 TIMETABLE
-- =========================
INSERT INTO student_timetable (student_id, day_order, subject, course_code, start_time, end_time, room) VALUES
(2, 1, 'DBMS', '21CSC301J', '08:00 AM', '08:50 AM', 'AB1-201'),
(2, 1, 'Machine Learning', '21CSC305J', '09:00 AM', '09:50 AM', 'AB3-101'),

(2, 2, 'Software Engineering', '21CSC303J', '08:00 AM', '08:50 AM', 'AB1-204'),
(2, 2, 'Computer Networks', '21CSC306J', '09:00 AM', '09:50 AM', 'AB2-305'),

(2, 3, 'Operating Systems', '21CSC302J', '08:00 AM', '08:50 AM', 'AB1-202'),
(2, 3, 'Compiler Design', '21CSC304J', '09:00 AM', '09:50 AM', 'AB1-205'),

(2, 4, 'AR/VR', '21CSE353T', '01:25 PM', '02:15 PM', 'AB2-402'),

(2, 5, 'Machine Learning', '21CSC305J', '08:00 AM', '08:50 AM', 'AB3-101'),
(2, 5, 'DBMS', '21CSC301J', '09:00 AM', '09:50 AM', 'AB1-201');


-- =========================
-- STUDENT 3 TIMETABLE
-- =========================
INSERT INTO student_timetable (student_id, day_order, subject, course_code, start_time, end_time, room) VALUES
(3, 1, 'Computer Networks', '21CSC306J', '08:00 AM', '08:50 AM', 'AB2-305'),
(3, 1, 'Operating Systems', '21CSC302J', '09:00 AM', '09:50 AM', 'AB1-202'),

(3, 2, 'Compiler Design', '21CSC304J', '08:00 AM', '08:50 AM', 'AB1-205'),
(3, 2, 'Machine Learning', '21CSC305J', '09:00 AM', '09:50 AM', 'AB3-101'),

(3, 3, 'Software Engineering', '21CSC303J', '08:00 AM', '08:50 AM', 'AB1-204'),

(3, 4, 'AR/VR', '21CSE353T', '12:30 PM', '01:20 PM', 'AB2-402'),

(3, 5, 'DBMS', '21CSC301J', '08:00 AM', '08:50 AM', 'AB1-201'),
(3, 5, 'Computer Networks', '21CSC306J', '09:00 AM', '09:50 AM', 'AB2-305');

INSERT INTO student_grades (student_id, semester, subject, course_code, credits, grade) VALUES
(1, 4, 'Data Science', '21CSE305J', 3, 'A'),
(1, 4, 'Compiler Design', '21CSC304J', 4, 'O'),
(1, 4, 'SEPM', '21CSC303J', 3, 'A+'),
(1, 4, 'Cloud Enterprises', '21CSE309J', 3, 'A'),

(2, 4, 'Data Science', '21CSE305J', 3, 'A+'),
(2, 4, 'Compiler Design', '21CSC304J', 4, 'A'),
(2, 4, 'SEPM', '21CSC303J', 3, 'A'),

(3, 4, 'DBMS', '21CSC301J', 4, 'A'),
(3, 4, 'SEPM', '21CSC303J', 3, 'B+'),
(3, 4, 'Compiler Design', '21CSC304J', 4, 'A'),

(4, 4, 'Cloud Computing', '21CSE307J', 3, 'B+'),
(5, 4, 'Machine Learning Basics', '21CSE401E', 3, 'A+'),
(6, 4, 'Business Analytics', '21MGT404E', 3, 'A'),
(7, 4, 'Cloud Security', '21CSE402E', 3, 'B'),
(8, 4, 'SEPM', '21CSC303J', 3, 'A'),
(9, 4, 'Compiler Design', '21CSC304J', 4, 'O'),
(10, 4, 'Data Visualization', '21CSE403E', 3, 'A'),
(11, 4, 'Internet of Things', '21CSE312J', 3, 'A'),
(12, 4, 'Cloud Computing', '21CSE307J', 3, 'A'),
(13, 4, 'DBMS', '21CSC301J', 4, 'A+'),
(14, 4, 'Business Analytics', '21MGT404E', 3, 'B+'),
(15, 4, 'Machine Learning Basics', '21CSE401E', 3, 'A');

INSERT INTO materials (semester, subject, course_code, material_title, file_type, uploaded_by, file_link) VALUES
(4, 'Environmental Impact Assessment', '21ENV201J', 'Environmental Impact Assessment Notes', 'PDF', 101, '#'),
(4, 'Augmented, Virtual and Mixed Reality', '21CSE353T', 'AVMR Unit 1 Notes', 'PDF', 105, '#'),
(4, 'Software Engineering and Project Management', '21CSC303J', 'SEPM Lecture Slides', 'PPT', 103, '#'),
(4, 'Internet of Things', '21CSE312J', 'IoT Module 2 Notes', 'PDF', 106, '#'),
(4, 'Compiler Design', '21CSC304J', 'Compiler Design Question Bank', 'PDF', 102, '#'),
(4, 'Cloud Computing', '21CSE307J', 'Cloud Computing Lab Manual', 'PDF', 104, '#');

INSERT INTO electives (semester, subject, course_code, type, faculty_incharge, credits, description) VALUES
(4, 'Machine Learning Basics', '21CSE401E', 'Professional Elective', 'Dr. Lakshmi Priya', 3, 'Introduction to supervised and unsupervised learning concepts.'),
(4, 'Cloud Security', '21CSE402E', 'Open Elective', 'Prof. Manoj Pillai', 3, 'Fundamentals of cloud threats, encryption, and access control.'),
(4, 'Data Visualization', '21CSE403E', 'Professional Elective', 'Dr. Kavitha Raman', 3, 'Techniques for visual representation of structured and unstructured data.'),
(4, 'Business Analytics', '21MGT404E', 'Open Elective', 'Prof. Arvind Raj', 3, 'Use of analytics for managerial decision making.'),
(4, 'Cyber Security Essentials', '21CSE404E', 'Professional Elective', 'Dr. Suresh Kumar', 3, 'Core concepts of information security, attacks, and defense.'),
(4, 'AR/VR Interaction Design', '21CSE405E', 'Professional Elective', 'Dr. Deepa Narayanan', 3, 'Design principles for immersive experiences and interfaces.');