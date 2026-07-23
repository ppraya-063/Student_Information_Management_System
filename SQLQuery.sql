
-- DATABASE CREATION

IF DB_ID('StudentInformationSystem') IS NOT NULL
BEGIN
    ALTER DATABASE StudentInformationSystem SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE StudentInformationSystem;
END
GO

CREATE DATABASE StudentInformationSystem;
GO

USE StudentInformationSystem;
GO


-- 1. TABLE CREATION

DROP TABLE IF EXISTS Department, Students, Faculty, Admin, Courses, Enrollment, Feedback

-- 1.1 Department 
CREATE TABLE Department
(
    DepartmentID    INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName  VARCHAR(100) NOT NULL UNIQUE,
    HOD             VARCHAR(100) NOT NULL        
);
GO

-- 1.2 Admin 
CREATE TABLE Admin
(
    AdminID         INT IDENTITY(1,1) PRIMARY KEY,
    AdminName       VARCHAR(100) NOT NULL,
    Email           VARCHAR(100) NOT NULL UNIQUE,
    Role            VARCHAR(50)  DEFAULT 'System Administrator'
);
GO

-- 1.3 Students 

CREATE TABLE Students
(
    StudentID       INT IDENTITY(1,1) PRIMARY KEY,
    FirstName       VARCHAR(50)  NOT NULL,
    LastName        VARCHAR(50)  NOT NULL,
    Gender          CHAR(1)      CHECK (Gender IN ('M','F','O')),
    DOB             DATE         NOT NULL,
    Email           VARCHAR(100) NOT NULL UNIQUE,
    Phone           VARCHAR(10)  NOT NULL,
    Address         VARCHAR(200) NULL,
    EnrollmentYear  INT          NOT NULL CHECK (EnrollmentYear BETWEEN 2015 AND 2030),
    DepartmentID    INT          NOT NULL,
    AdminID         INT          NOT NULL,    

    CONSTRAINT FK_Students_Department
        FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
    CONSTRAINT FK_Students_Admin
        FOREIGN KEY (AdminID) REFERENCES Admin(AdminID)
);
GO
 
-- 1.4 Faculty 
CREATE TABLE Faculty
(
    FacultyID       INT IDENTITY(1,1) PRIMARY KEY,
    FacultyName     VARCHAR(100) NOT NULL,
    Email           VARCHAR(100) NOT NULL UNIQUE,
    Phone           VARCHAR(15)  NOT NULL,
    DepartmentID    INT          NOT NULL,
    AdminID         INT          NOT NULL,     -- admin who approved the appointment
    JoiningDate     DATE         DEFAULT GETDATE(),

    CONSTRAINT FK_Faculty_Department
        FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
    CONSTRAINT FK_Faculty_Admin
        FOREIGN KEY (AdminID) REFERENCES Admin(AdminID)
);
GO

-- 1.4 Courses 
CREATE TABLE Courses
(
    CourseID        INT IDENTITY(1,1) PRIMARY KEY,
    CourseName      VARCHAR(100) NOT NULL,
    Credits         INT          NOT NULL CHECK (Credits > 0),
    DepartmentID    INT          NOT NULL,
    FacultyID       INT          NULL,

    CONSTRAINT FK_Courses_Department
        FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
    CONSTRAINT FK_Courses_Faculty
        FOREIGN KEY (FacultyID) REFERENCES Faculty(FacultyID)
        ON DELETE SET NULL
);
GO

-- 1.5 Enrollment 
CREATE TABLE Enrollment
(
    EnrollmentID    INT IDENTITY(1,1) PRIMARY KEY,
    StudentID       INT NOT NULL,
    CourseID        INT NOT NULL,
    Semester        VARCHAR(20) NOT NULL,
    Grade           CHAR(2) NULL CHECK (Grade IN ('A','A-','B+','B','B-','C+','C','D','F') OR Grade IS NULL),
    EnrollmentDate  DATE DEFAULT GETDATE(),

    CONSTRAINT FK_Enrollment_Student
        FOREIGN KEY (StudentID) REFERENCES Students(StudentID) ON DELETE CASCADE,
    CONSTRAINT FK_Enrollment_Course
        FOREIGN KEY (CourseID) REFERENCES Courses(CourseID) ON DELETE CASCADE,
    CONSTRAINT UQ_Student_Course_Semester UNIQUE (StudentID, CourseID, Semester)
);
GO

-- 1.6 Feedback 
CREATE TABLE Feedback
(
    FeedbackID      INT IDENTITY(1,1) PRIMARY KEY,
    StudentID       INT NOT NULL,
    FacultyID       INT NOT NULL,
    CourseID        INT NOT NULL,
    Rating          INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Comments        VARCHAR(200) NULL,
    FeedbackDate    DATE DEFAULT GETDATE(),

    CONSTRAINT FK_Feedback_Student FOREIGN KEY (StudentID) REFERENCES Students(StudentID) ON DELETE CASCADE,
    CONSTRAINT FK_Feedback_Faculty FOREIGN KEY (FacultyID) REFERENCES Faculty(FacultyID) ON DELETE CASCADE,
    CONSTRAINT FK_Feedback_Course  FOREIGN KEY (CourseID)  REFERENCES Courses(CourseID)
);
GO


-- 2. SAMPLE DATA


-- 2.1 Departments (4)
INSERT INTO Department (DepartmentName, HOD) VALUES
('Computer Science', 'Dr. Anil Sharma'),
('Mathematics',       'Dr. Rita Koirala'),
('Cybersecurity',     'Prof. Bikash Thapa'),
('Business Studies',  'Dr. Meena Adhikari');
GO

-- 2.2 Admin (2) 
INSERT INTO Admin (AdminName, Email, Role) VALUES
('Suman Shrestha', 'suman.admin@college.edu', 'System Administrator'),
('Nisha Karki',     'nisha.admin@college.edu', 'Academic Registrar');
GO

-- 2.3 Faculty (6)
INSERT INTO Faculty (FacultyName, Email, Phone, DepartmentID, AdminID, JoiningDate) VALUES
('Dr. Anil Sharma',   'anil.sharma@college.edu',   '9800000001', 1, 1, '2006-01-09'),
('Dr. Rita Koirala',  'rita.koirala@college.edu',  '9800000002', 2, 1, '2004-09-23'),
('Prof. Bikash Thapa','bikash.thapa@college.edu',  '9800000003', 3, 2, '2005-06-29'),
('Ms. Sunita Lama',   'sunita.lama@college.edu',   '9800000004', 1, 1, '2012-03-15'),
('Mr. Deepak Basnet', 'deepak.basnet@college.edu', '9800000005', 4, 2, '2015-08-01'),
('Dr. Kabita Nepal',  'kabita.nepal@college.edu',  '9800000006', 3, 2, '2010-11-20');
GO

-- 2.4 Courses (8)
INSERT INTO Courses (CourseName, Credits, DepartmentID, FacultyID) VALUES
('Database Management Systems', 4, 1, 1),
('Data Structures',             4, 1, 4),
('Calculus I',                  3, 2, 2),
('Network Security',            4, 3, 3),
('Ethical Hacking',             3, 3, 6),
('Business Communication',      2, 4, 5),
('Web Technologies',            3, 1, 1),
('Operating Systems',           4, 1, 4);
GO

-- 2.5 Students (15) 
INSERT INTO Students (FirstName, LastName, Gender, DOB, Email, Phone, Address, EnrollmentYear, DepartmentID, AdminID) VALUES
('Ram',     'Bahadur',   'M', '2003-05-12', 'ram.bahadur@student.edu',   '9811111111', 'Kathmandu', 2022, 1, 1),
('Sita',    'Gurung',    'F', '2003-08-20', 'sita.gurung@student.edu',   '9822222222', 'Lalitpur',  2022, 1, 1),
('Hari',    'Shrestha',  'M', '2002-11-02', 'hari.shrestha@student.edu', '9833333333', 'Bhaktapur', 2021, 2, 2),
('Gita',    'Rai',       'F', '2004-01-15', 'gita.rai@student.edu',      '9844444444', 'Kathmandu', 2023, 3, 2),
('Suresh',  'Karki',     'M', '2003-03-30', 'suresh.karki@student.edu',  '9855555555', 'Pokhara',   2022, 1, 1),
('Anita',   'Magar',     'F', '2004-06-18', 'anita.magar@student.edu',   '9866666666', 'Kathmandu', 2023, 3, 2),
('Bikash',  'Rai',       'M', '2004-02-20', 'bikash.rai@student.edu',    '9877777777', 'Kathmandu', 2023, 1, 1),
('Kabita',  'Thapa',     'F', '2003-09-09', 'kabita.thapa@student.edu',  '9888888888', 'Chitwan',   2022, 4, 2),
('Prakash', 'Adhikari',  'M', '2002-12-25', 'prakash.adhikari@student.edu','9899999999','Kathmandu', 2021, 1, 1),
('Manisha', 'Poudel',    'F', '2004-04-04', 'manisha.poudel@student.edu','9801111111', 'Lalitpur',  2023, 2, 1),
('Nabin',   'Tamang',    'M', '2003-07-07', 'nabin.tamang@student.edu',  '9802222222', 'Bhaktapur', 2022, 3, 2),
('Sabina',  'Lama',      'F', '2004-10-10', 'sabina.lama@student.edu',   '9803333333', 'Kathmandu', 2023, 1, 1),
('Rajesh',  'KC',        'M', '2002-05-05', 'rajesh.kc@student.edu',     '9804444444', 'Pokhara',   2021, 4, 2),
('Puja',    'Basnet',    'F', '2003-01-01', 'puja.basnet@student.edu',   '9805555555', 'Kathmandu', 2022, 2, 1),
('Deepak',  'Khadka',    'M', '2004-03-03', 'deepak.khadka@student.edu', '9806666666', 'Lalitpur',  2023, 3, 2);
GO

-- 2.6 Enrollment (20)
INSERT INTO Enrollment (StudentID, CourseID, Semester, Grade) VALUES
(1,1,'Fall 2024','A'),   (1,7,'Spring 2025','B+'),
(2,2,'Fall 2024','B+'),  (2,1,'Spring 2025','A-'),
(3,3,'Fall 2024','A-'),  (3,4,'Spring 2025','B'),
(4,4,'Fall 2024','A'),   (4,5,'Spring 2025','A-'),
(5,1,'Fall 2024','B'),   (5,8,'Spring 2025','B+'),
(6,5,'Fall 2024','A'),   (6,4,'Spring 2025','A'),
(7,1,'Fall 2024','A-'),  (7,8,'Spring 2025','B'),
(8,6,'Fall 2024','B+'),
(9,7,'Fall 2024','A'),   (9,2,'Spring 2025','B'),
(10,3,'Fall 2024','B'),
(11,5,'Fall 2024','A-'),
(12,2,'Fall 2024','B+');
GO

-- 2.7 Feedback (20)
INSERT INTO Feedback (StudentID, FacultyID, CourseID, Rating, Comments) VALUES
(1,1,1,5,'Excellent teaching'),      (1,1,7,4,'Good pace'),
(2,4,2,4,'Very helpful'),            (2,1,1,5,'Clear explanations'),
(3,2,3,5,'Explains clearly'),        (3,3,4,4,'Practical examples'),
(4,3,4,3,'Needs more examples'),     (4,6,5,4,'Engaging labs'),
(5,1,1,4,'Good instructor'),         (5,4,8,3,'Fast paced'),
(6,6,5,5,'Best faculty'),            (6,3,4,4,'Well organised'),
(7,1,1,4,'Solid fundamentals'),      (7,4,8,3,'Could slow down'),
(8,5,6,4,'Friendly approach'),
(9,1,7,5,'Very inspiring'),          (9,4,2,3,'Average pace'),
(10,2,3,4,'Detailed notes'),
(11,6,5,5,'Great mentor'),
(12,4,2,4,'Helpful feedback');
GO

-- 3. VERIFY DATA LOAD
SELECT * FROM Department;
SELECT * FROM Faculty;
SELECT * FROM Courses;
SELECT * FROM Students;
SELECT * FROM Enrollment;
SELECT * FROM Feedback;
SELECT * FROM Admin;
GO


-- 4. PRACTICAL 3 - CRUD OPERATIONS & SEARCH QUERIES

-- 4.1 INSERT: add a new student
INSERT INTO Students (FirstName, LastName, Gender, DOB, Email, Phone, Address, EnrollmentYear, DepartmentID, AdminID)
VALUES ('Aashish', 'Neupane', 'M', '2004-07-14', 'aashish.neupane@student.edu', '9807777777', 'Kathmandu', 2023, 1, 1);
GO

-- 4.2 INSERT: add a new course
INSERT INTO Courses (CourseName, Credits, DepartmentID, FacultyID)
VALUES ('Cloud Computing', 3, 1, 1);
GO

-- 4.3 UPDATE: correct a student's phone number
UPDATE Students SET Phone = '9877770000' WHERE Email = 'anita.magar@student.edu';
GO

-- 4.4 UPDATE: revise a course's credit value
UPDATE Courses SET Credits = 3 WHERE CourseName = 'Operating Systems';
GO

-- 4.5 DELETE: remove one specific enrollment record
DELETE FROM Enrollment
WHERE StudentID = (SELECT StudentID FROM Students WHERE Email = 'manisha.poudel@student.edu')
  AND CourseID  = (SELECT CourseID  FROM Courses  WHERE CourseName = 'Calculus I');
GO

-- Delete the course you inserted earlier in 4.2
DELETE FROM Courses WHERE CourseName = 'Cloud Computing';
GO

-- Delete the course you inserted earlier in 4.2
DELETE FROM Students WHERE  Email = 'prakash.adhikari@student.edu';
GO

-- 4.6 SELECT with JOIN: student details with enrolled courses
SELECT S.StudentID, S.FirstName + ' ' + S.LastName AS StudentName,
       C.CourseName, E.Semester, E.Grade
FROM Students S
JOIN Enrollment E ON S.StudentID = E.StudentID
JOIN Courses C     ON E.CourseID  = C.CourseID
ORDER BY S.StudentID;
GO

-- 4.7 LIKE: students whose first name starts with 'S'
SELECT StudentID, FirstName, LastName FROM Students WHERE FirstName LIKE 'S%';
GO
-- 4.8 BETWEEN: students born between 2003 and 2004
SELECT StudentID, FirstName, LastName, DOB FROM Students WHERE DOB BETWEEN '2003-01-01' AND '2004-12-31';
GO
-- 4.9 IN: courses in a given set of departments
SELECT CourseID, CourseName FROM Courses WHERE DepartmentID IN (1,3);
GO

-- 4.10 ORDER BY: students ordered by enrollment year (descending)
SELECT FirstName, LastName, EnrollmentYear FROM Students ORDER BY EnrollmentYear DESC;
GO

-- 4.11 DISTINCT: distinct departments that offer courses
SELECT DISTINCT D.DepartmentName
FROM Courses C JOIN Department D ON C.DepartmentID = D.DepartmentID;
GO

-- 4.12 TOP: top 5 highest-credit courses
SELECT TOP 5 CourseName, Credits
FROM Courses
ORDER BY Credits DESC, CourseName ASC;
GO

-- 4.13 Aliases: shortened, readable output
SELECT S.FirstName AS FName, S.LastName AS LName, C.CourseName AS Course
FROM Students AS S
INNER JOIN Enrollment AS E ON S.StudentID = E.StudentID
INNER JOIN Courses AS C ON E.CourseID = C.CourseID;
GO


-- 5. PRACTICAL 4 - RELATIONAL ALGEBRA & TRANSACTIONS


-- 5.1 SELECTION (sigma): female students only
SELECT * FROM Students WHERE Gender = 'F';
GO

-- 5.2 PROJECTION (pi): only names
SELECT FirstName, LastName FROM Students;
GO

-- 5.3 JOIN: students with the courses they take
SELECT S.FirstName, C.CourseName
FROM Students S JOIN Enrollment E ON S.StudentID = E.StudentID
                JOIN Courses C ON E.CourseID = C.CourseID;
GO

-- 5.4 UNION: combined list of student and faculty first names
SELECT FirstName AS PersonName FROM Students
UNION
SELECT FacultyName FROM Faculty;
GO

-- 5.5 INTERSECTION: emails common to both Students and Faculty (expected empty)
SELECT Email FROM Students
INTERSECT
SELECT Email FROM Faculty;
GO

-- 5.6 DIFFERENCE: students who have never submitted feedback
SELECT StudentID FROM Students
EXCEPT
SELECT StudentID FROM Feedback;
GO

-- 5.7 CARTESIAN PRODUCT: every department paired with every admin (illustrative only)
SELECT D.DepartmentName, A.AdminName FROM Department D CROSS JOIN Admin A;
GO


-- 5.8 Transactions 

-- COMMIT: change is saved permanently
BEGIN TRANSACTION;
    INSERT INTO Students (FirstName, LastName, Gender, DOB, Email, Phone, Address, EnrollmentYear, DepartmentID, AdminID)
    VALUES ('Sarita', 'Bhandari', 'F', '2004-08-08', 'sarita1.bhandari@student.edu', '9808888888', 'Kathmandu', 2023, 1, 1);
COMMIT;
GO

-- ROLLBACK: change is undone
BEGIN TRANSACTION;
    INSERT INTO Students (FirstName, LastName, Gender, DOB, Email, Phone, Address, EnrollmentYear, DepartmentID, AdminID)
    VALUES ('Test', 'User', 'M', '2004-01-01', 'test.user@student.edu', '9800000000', 'Kathmandu', 2023, 1, 1);
ROLLBACK;
GO

-- SAVEPOINT: partial rollback within a transaction
BEGIN TRANSACTION;
    UPDATE Students SET Phone = '9809999999' WHERE Email = 'sarita.bhandari@student.edu';
    SAVE TRANSACTION BeforeGradeUpdate;
    UPDATE Enrollment SET Grade = 'F' WHERE StudentID = 1 AND CourseID = 1; -- accidental change
    ROLLBACK TRANSACTION BeforeGradeUpdate;   -- undo only the grade change
COMMIT;
GO

-- Proof: 'Sarita' exists, 'Test' does not, grade for StudentID 1/CourseID 1 unchanged
SELECT * FROM Students WHERE FirstName IN ('Sarita','Test');
SELECT * FROM Enrollment WHERE StudentID = 1 AND CourseID = 1;
GO


-- 6. PRACTICAL 5 - DATABASE OPERATIONS


-- 6.1 INNER JOIN: students with their enrolled courses and faculty
SELECT S.FirstName, S.LastName, C.CourseName, F.FacultyName, E.Grade
FROM Students S
INNER JOIN Enrollment E ON S.StudentID = E.StudentID
INNER JOIN Courses C    ON E.CourseID  = C.CourseID
INNER JOIN Faculty F    ON C.FacultyID = F.FacultyID;
GO

-- 6.2 LEFT JOIN: students who are NOT enrolled in any course
SELECT S.StudentID, S.FirstName, S.LastName
FROM Students S
LEFT JOIN Enrollment E ON S.StudentID = E.StudentID
WHERE E.EnrollmentID IS NULL;
GO

-- 6.3 RIGHT JOIN: courses that have NOT been taken by any student
SELECT C.CourseID, C.CourseName
FROM Enrollment E
RIGHT JOIN Courses C ON E.CourseID = C.CourseID
WHERE E.EnrollmentID IS NULL;
GO

-- 6.4 FULL JOIN: complete picture of students and courses whether matched or not
SELECT S.FirstName, C.CourseName
FROM Students S
FULL JOIN Enrollment E ON S.StudentID = E.StudentID
FULL JOIN Courses C ON E.CourseID = C.CourseID;
GO

-- 6.5 SELF JOIN: compare grades of different students in the same course
SELECT A.StudentID AS Student1, B.StudentID AS Student2, A.CourseID, A.Grade AS Grade1, B.Grade AS Grade2
FROM Enrollment A
INNER JOIN Enrollment B ON A.CourseID = B.CourseID AND A.StudentID < B.StudentID;
GO

-- 6.6 CROSS JOIN: every course paired with every faculty (for planning purposes)
SELECT C.CourseName, F.FacultyName FROM Courses C CROSS JOIN Faculty F;
GO


-- 6.7 Aggregate functions 

-- COUNT: students enrolled per course
SELECT C.CourseName, COUNT(E.StudentID) AS TotalStudents
FROM Courses C LEFT JOIN Enrollment E ON C.CourseID = E.CourseID
GROUP BY C.CourseName ORDER BY TotalStudents DESC;
GO

-- SUM: total credits a student is currently taking
SELECT S.StudentID, S.FirstName, SUM(C.Credits) AS TotalCredits
FROM Students S JOIN Enrollment E ON S.StudentID = E.StudentID
                JOIN Courses C ON E.CourseID = C.CourseID
GROUP BY S.StudentID, S.FirstName;
GO

-- AVG: average grade points (numeric mapping) per course
SELECT C.CourseName, AVG(
    CASE E.Grade WHEN 'A' THEN 4.0 WHEN 'A-' THEN 3.7 WHEN 'B+' THEN 3.3
                 WHEN 'B' THEN 3.0 WHEN 'B-' THEN 2.7 WHEN 'C+' THEN 2.3
                 WHEN 'C' THEN 2.0 WHEN 'D' THEN 1.0 ELSE 0 END) AS AvgGradePoint
FROM Enrollment E JOIN Courses C ON E.CourseID = C.CourseID
GROUP BY C.CourseName;
GO

-- MAX / MIN: highest and lowest credit courses and grade
SELECT MAX(Credits) AS HighestCredits, MIN(Credits) AS LowestCredits FROM Courses;
GO

SELECT C.CourseName,
       MAX(CASE E.Grade WHEN 'A' THEN 4.0 WHEN 'A-' THEN 3.7 WHEN 'B+' THEN 3.3
                        WHEN 'B' THEN 3.0 WHEN 'B-' THEN 2.7 WHEN 'C+' THEN 2.3
                        WHEN 'C' THEN 2.0 WHEN 'D' THEN 1.0 ELSE 0 END) AS HighestGradePoint,
       MIN(CASE E.Grade WHEN 'A' THEN 4.0 WHEN 'A-' THEN 3.7 WHEN 'B+' THEN 3.3
                        WHEN 'B' THEN 3.0 WHEN 'B-' THEN 2.7 WHEN 'C+' THEN 2.3
                        WHEN 'C' THEN 2.0 WHEN 'D' THEN 1.0 ELSE 0 END) AS LowestGradePoint
FROM Enrollment E
JOIN Courses C ON E.CourseID = C.CourseID
GROUP BY C.CourseName;
GO

-- 6.8 GROUP BY / HAVING 

-- GROUP BY: number of students per course
SELECT CourseID, COUNT(StudentID) AS TotalStudents FROM Enrollment GROUP BY CourseID;
GO

-- HAVING: only courses with more than 1 enrolled student
SELECT C.CourseName,
       AVG(CASE E.Grade WHEN 'A' THEN 4.0 WHEN 'A-' THEN 3.7 WHEN 'B+' THEN 3.3
                        WHEN 'B' THEN 3.5 WHEN 'B-' THEN 2.7 WHEN 'C+' THEN 2.3
                        WHEN 'C' THEN 2.0 WHEN 'D' THEN 1.0 ELSE 0 END) AS AvgGradePoint
FROM Enrollment E
JOIN Courses C ON E.CourseID = C.CourseID
GROUP BY C.CourseName
HAVING AVG(CASE E.Grade WHEN 'A' THEN 4.0 WHEN 'A-' THEN 3.7 WHEN 'B+' THEN 3.3
                        WHEN 'B' THEN 3.5 WHEN 'B-' THEN 2.7 WHEN 'C+' THEN 2.3
                        WHEN 'C' THEN 2.0 WHEN 'D' THEN 1.0 ELSE 0 END) < 3.5;
GO

-- 6.9 Subquery: students who scored an 'A' in any course
SELECT FirstName, LastName FROM Students
WHERE StudentID IN (SELECT StudentID FROM Enrollment WHERE Grade = 'A');
GO

-- 6.10 View: reusable virtual table of student performance
CREATE OR ALTER VIEW vw_StudentPerformance AS
SELECT S.StudentID, S.FirstName + ' ' + S.LastName AS StudentName,
       C.CourseName, F.FacultyName, E.Semester, E.Grade
FROM Students S
JOIN Enrollment E ON S.StudentID = E.StudentID
JOIN Courses C ON E.CourseID = C.CourseID
LEFT JOIN Faculty F ON C.FacultyID = F.FacultyID;
GO

SELECT * FROM vw_StudentPerformance;
GO

-- 6.11 Stored Procedure: enroll a student in a course
CREATE OR ALTER PROCEDURE sp_EnrollStudent
    @StudentID INT, @CourseID INT, @Semester VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM Enrollment WHERE StudentID = @StudentID AND CourseID = @CourseID AND Semester = @Semester)
    BEGIN
        INSERT INTO Enrollment (StudentID, CourseID, Semester) VALUES (@StudentID, @CourseID, @Semester);
        PRINT 'Enrollment successful.';
    END
    ELSE
        PRINT 'Student already enrolled in this course for this semester.';
END
GO

EXEC sp_EnrollStudent @StudentID = 13, @CourseID = 6, @Semester = 'Fall 2025';
GO

-- 6.12 Trigger: automatically log grade changes
CREATE TABLE GradeChangeLog
(
    LogID       INT IDENTITY(1,1) PRIMARY KEY,
    EnrollmentID INT,
    OldGrade    CHAR(2),
    NewGrade    CHAR(2),
    ChangedOn   DATETIME DEFAULT GETDATE()
);
GO

CREATE OR ALTER TRIGGER trg_GradeChange
ON Enrollment
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(Grade)
    BEGIN
        INSERT INTO GradeChangeLog (EnrollmentID, OldGrade, NewGrade)
        SELECT d.EnrollmentID, d.Grade, i.Grade
        FROM deleted d JOIN inserted i ON d.EnrollmentID = i.EnrollmentID
        WHERE ISNULL(d.Grade,'') <> ISNULL(i.Grade,'');
    END
END
GO

UPDATE Enrollment SET Grade = 'A' WHERE EnrollmentID = 9;
SELECT * FROM GradeChangeLog;
GO

-- 6.13 Index: speed up frequent lookups
CREATE NONCLUSTERED INDEX IX_Students_LastNames ON Students(LastName);
CREATE NONCLUSTERED INDEX IX_Enrollments_CourseID ON Enrollment(CourseID);
GO

