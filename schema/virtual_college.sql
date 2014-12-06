DROP DATABASE IF EXISTS virtual_college;
CREATE DATABASE virtual_college;

use virtual_college;

DROP TABLE IF EXISTS virtual_college.students;
CREATE TABLE virtual_college.students (
	`id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(150) NOT NULL,
	`email` VARCHAR(150) NOT NULL,
	`address` VARCHAR(150) NOT NULL,
	`city` VARCHAR(150) NOT NULL,
	`state` VARCHAR(150) NOT NULL,
	`zip` VARCHAR(30) NOT NULL,
	`phone1` VARCHAR(20) NOT NULL,
	`phone2` VARCHAR(20) NULL DEFAULT NULL,
	`phone3` VARCHAR(20) NULL DEFAULT NULL,
	`phone4` VARCHAR(20) NULL DEFAULT NULL,
	PRIMARY KEY ( `id` ),
	INDEX ( `name` ),
	UNIQUE INDEX ( `email` )
) ENGINE=INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;

DROP TABLE IF EXISTS virtual_college.professors;
CREATE TABLE virtual_college.professors (
	`id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(150) NOT NULL,
	`email` VARCHAR(50) NOT NULL,
	`office_location` VARCHAR(100) NULL DEFAULT NULL,
	`office_hours` VARCHAR(100) NULL DEFAULT NULL,
	`office_phone` VARCHAR(20) NULL DEFAULT NULL,
	PRIMARY KEY ( `id` ),
	INDEX ( `name` ),
	UNIQUE INDEX ( `email` )
) ENGINE=INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;

DROP TABLE IF EXISTS virtual_college.semesters;
CREATE TABLE virtual_college.semesters (
	`id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
	`semester` VARCHAR(50) NOT NULL,
	`calendar_start` DATETIME NOT NULL,
	`calendar_end` DATETIME NOT NULL,
	PRIMARY KEY ( `id` ),
	UNIQUE INDEX ( `semester` )
) ENGINE=INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;


DROP TABLE IF EXISTS virtual_college.classes;
CREATE TABLE virtual_college.classes (
	`id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
	`catalog_name` VARCHAR(150) NOT NULL,
	`catalog_no` VARCHAR(50) NOT NULL,
	`semester` INTEGER UNSIGNED NOT NULL,
	`credit_hours` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
	`prof_id` INTEGER UNSIGNED NOT NULL,
	PRIMARY KEY ( `id` ),
	INDEX ( `catalog_name` ),
	INDEX ( `prof_id` ),
	INDEX ( `semester` ),
	UNIQUE INDEX ( `catalog_no` ),
	FOREIGN KEY ( prof_id ) REFERENCES professors( id ),
	FOREIGN KEY ( semester ) REFERENCES semesters( id )
) ENGINE=INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;

DROP TABLE IF EXISTS virtual_college.users;
CREATE TABLE virtual_college.users (
	`id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
	`username` VARCHAR(150) NOT NULL,
	`password` VARCHAR(64) NOT NULL,
	`salt` VARCHAR(64) NOT NULL,
	`student_id` INTEGER UNSIGNED NULL DEFAULT NULL,
	`prof_id` INTEGER UNSIGNED NULL DEFAULT NULL,
	`user_banned` TINYINT UNSIGNED NOT NULL DEFAULT 0,
	PRIMARY KEY ( `id` ),
	UNIQUE INDEX ( `username` ),
	FOREIGN KEY ( `student_id` ) REFERENCES `students` ( `id` ),
	FOREIGN KEY ( `prof_id` ) REFERENCES `professors` ( `id` )
) ENGINE=INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;

DROP TABLE IF EXISTS virtual_college.enrollment;
CREATE TABLE virtual_college.enrollment (
	`id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
	`class_id` INTEGER UNSIGNED NOT NULL,
	`student_id` INTEGER UNSIGNED NOT NULL,
	`confirmed` TINYINT UNSIGNED NOT NULL DEFAULT 0,
	PRIMARY KEY ( `id` ),
	FOREIGN KEY ( `class_id` ) REFERENCES `classes` ( `id` ),
	FOREIGN KEY ( `student_id` ) REFERENCES `students` ( `id` )
) ENGINE=INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;

DROP TABLE IF EXISTS virtual_college.gpa;
CREATE TABLE virtual_college.gpa (
	`id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
	`grade` CHAR(2) NOT NULL,
	`credit_hours` TINYINT NOT NULL,
	`quality_points` DECIMAL(4, 1),
	PRIMARY KEY ( `id` ),
	UNIQUE INDEX ( `grade`, `credit_hours` )
) ENGINE=INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;

-- Preload grade values for determining grade point average
INSERT INTO gpa VALUES
(NULL, 'A', 2, '8.0'),(NULL, 'A', 3, '12.0'),(NULL, 'A', 4, '16.0'),
(NULL, 'A-', 2, '7.4'),(NULL, 'A-', 3, '11.1'),(NULL, 'A-', 4, '14.8'),
(NULL, 'B+', 2, '6.6'),(NULL, 'B+', 3, '9.9'),(NULL, 'B+', 4, '13.2'),
(NULL, 'B', 2, '6.0'),(NULL, 'B', 3, '9.0'),(NULL, 'B', 4, '12.0'),
(NULL, 'B-', 2, '5.4'),(NULL, 'B-', 3, '8.1'),(NULL, 'B-', 4, '10.8'),
(NULL, 'C+', 2, '4.6'),(NULL, 'C+', 3, '6.9'),(NULL, 'C+', 4, '9.2'),
(NULL, 'C', 2, '4.0'),(NULL, 'C', 3, '6.0'),(NULL, 'C', 4, '8.0'),
(NULL, 'C-', 2, '3.4'),(NULL, 'C-', 3, '5.1'),(NULL, 'C-', 4, '6.8'),
(NULL, 'F', 2, '0'),(NULL, 'F', 3, '0'),(NULL, 'F', 4, '0'),
(NULL, 'WU', 2, '0'),(NULL, 'WU', 3, '0'),(NULL, 'WU', 4, '0');

DROP TABLE IF EXISTS virtual_college.grades;
CREATE TABLE virtual_college.grades (
	`id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
	`description` VARCHAR(100) NOT NULL,
	`class_id` INTEGER UNSIGNED NOT NULL,
	`student_id` INTEGER UNSIGNED NOT NULL,
	`gpa_id` INTEGER UNSIGNED NOT NULL,
	PRIMARY KEY ( `id` ),
	INDEX (`class_id` ),
	INDEX (`student_id` ),
	INDEX (`gpa_id` ),
	UNIQUE INDEX ( `class_id`, `student_id` ),
	FOREIGN KEY ( class_id ) REFERENCES classes ( `id` ),
	FOREIGN KEY ( student_id ) REFERENCES students ( `id` ),
	FOREIGN KEY ( gpa_id ) REFERENCES gpa ( `id` )
) ENGINE=INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;

















