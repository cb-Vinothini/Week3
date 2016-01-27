-- #--------------------------------- ALTER TABLE --------------------------

-- 1
ALTER TABLE `marks`
DROP COLUMN `created_at`,
DROP COLUMN `updated_at`;

ALTER TABLE `marks`
ADD COLUMN `created_at` DATETIME,
ADD COLUMN `updated_at` DATETIME;

ALTER TABLE `students`
DROP COLUMN `created_at`,
DROP COLUMN `updated_at`;

ALTER TABLE `students`
ADD COLUMN `created_at` DATETIME,
ADD COLUMN `updated_at` DATETIME;

ALTER TABLE `medals`
DROP COLUMN `created_at`,
DROP COLUMN `updated_at`;

ALTER TABLE `medals`
ADD COLUMN `created_at` DATETIME,
ADD COLUMN `updated_at` DATETIME;

-- 2
UPDATE `marks`
SET `quarterly` = 0
WHERE `quarterly` IS NULL;

ALTER TABLE `marks`
MODIFY COLUMN `quarterly` INT(11) NOT NULL DEFAULT 0;

UPDATE `marks`
SET `half_yearly` = 0
WHERE `half_yearly` IS NULL;

ALTER TABLE `marks`
MODIFY COLUMN `half_yearly` INT(11) NOT NULL DEFAULT 0;

UPDATE `marks`
SET `annual` = 0
WHERE `annual` IS NULL;

ALTER TABLE `marks`
MODIFY COLUMN `annual` INT(11) NOT NULL DEFAULT 0;

#--------------------------------- INSERT AND UPDATE --------------------------

-- 1
ALTER TABLE `marks`
MODIFY COLUMN `created_at` DATETIME DEFAULT NOW();

ALTER TABLE `marks`
MODIFY COLUMN `updated_at` DATETIME DEFAULT NOW();

ALTER TABLE `students`
MODIFY COLUMN `created_at` DATETIME DEFAULT NOW();

ALTER TABLE `students`
MODIFY COLUMN `updated_at` DATETIME DEFAULT NOW();

ALTER TABLE `medals`
MODIFY COLUMN `created_at` DATETIME DEFAULT NOW();

ALTER TABLE `medals`
MODIFY COLUMN `updated_at` DATETIME DEFAULT NOW();

-- 2
UPDATE `marks`
SET `updated_at` = NOW() WHERE `updated_at` IS NULL;

UPDATE `students`
SET `updated_at` = NOW() WHERE `updated_at` IS NULL;

UPDATE `medals`
SET `updated_at` = NOW() WHERE `updated_at` IS NULL;

#--------------------------------- EXERCISE --------------------------

DROP DATABASE IF EXISTS `training_sample`;
CREATE DATABASE `training_sample`;
USE `training_sample`;

DROP TABLE IF EXISTS `students_summary`;
CREATE TABLE `students_summary`(
  `student_id` BIGINT(19) NOT NULL,
  `student_name` VARCHAR(100),
  `year` INT(11),
  `percentage` FLOAT(10),
  `no_of_medals` INT(10)
);

DELIMITER //
DROP PROCEDURE IF EXISTS `set_table`;
CREATE PROCEDURE `set_table`()
BEGIN
DECLARE `s_id` BIGINT(19) DEFAULT 0;
DECLARE `s_name` VARCHAR(100) DEFAULT '';
DECLARE `y` INT(11) DEFAULT 0;
DECLARE `per` FLOAT(10) DEFAULT 0.0;
DECLARE `no` INT(10) DEFAULT 1;
DECLARE `finished` INTEGER DEFAULT 0;
DECLARE `value_cursor` CURSOR FOR SELECT s.id, s.name, new_table.count_medal, new_table.a_percent, new_table.year
FROM service_stations.students s
INNER JOIN (SELECT table1.student_id, table1.year, table1.grade, table1.q_percent, table1.h_percent, table1.a_percent, table2.count_medal
            FROM (SELECT student_id, year, grade, SUM(COALESCE(quarterly,0))/5 AS `q_percent`, SUM(COALESCE(half_yearly,0))/5 AS `h_percent`, SUM(COALESCE(annual,0))/5 AS `a_percent`
                  FROM service_stations.marks
                  GROUP BY student_id, year, grade) AS `table1`
            LEFT JOIN (SELECT student_id, year, COUNT(medal_won) AS `count_medal`
                        FROM service_stations.medals
                        GROUP BY student_id, year) AS `table2`
            ON table1.student_id = table2.student_id
            AND table1.year = table2.year) AS `new_table`
ON s.id = new_table.student_id;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET `finished` = 1;

OPEN `value_cursor`;
`looping`: LOOP
FETCH `value_cursor` INTO `s_id`, `s_name`, `y`, `per`, `no`;
IF `finished` = 1 THEN
LEAVE `looping`;
END IF;
INSERT INTO `students_summary` VALUES (`s_id`, `s_name`, `y`, `per`, `no`);
END LOOP `looping`;
CLOSE `value_cursor`;
END //
DELIMITER ;

CALL set_table();

#--------------------------------- TRIGGERS EXERCISE --------------------------

-- 1
USE `service_stations`;

ALTER TABLE `marks`
DROP COLUMN `avg_all`;
ALTER TABLE `marks`
ADD COLUMN `avg_all` FLOAT(11);

DELIMITER $$
DROP TRIGGER IF EXISTS `update_marks_after_insertion`;
CREATE TRIGGER `update_marks_after_insertion`
BEFORE INSERT
ON `marks`
FOR EACH ROW
BEGIN
SET NEW.`avg_all` = (NEW.`quarterly` + NEW.`half_yearly` + NEW.`annual`)/3;
END $$
DELIMITER ;

DELIMITER $$
DROP TRIGGER IF EXISTS `update_marks_after_updation`;
CREATE TRIGGER `update_marks_after_updation`
BEFORE UPDATE
ON `marks`
FOR EACH ROW
BEGIN
SET NEW.`avg_all` = (NEW.`quarterly` + NEW.`half_yearly` + NEW.`annual`)/3;
END $$
DELIMITER ;

UPDATE `marks`
SET avg_all = 0;

2
-- IF NOT EXISTS (SELECT NULL FROM INFORMATION_SCHEMA.COLUMNS
--             WHERE TABLE_SCHEMA = 'service_stations' AND TABLE_NAME = 'medals' AND COLUMN_NAME = 'medal_won') THEN
-- END IF;

ALTER TABLE `medals`
CHANGE COLUMN `medal_won` `medal_received` VARCHAR(10);

ALTER TABLE `medals`
CHANGE COLUMN `medal_received` `medal_won` VARCHAR(10);

# a
ALTER TABLE `medals`
ADD COLUMN `medal_received` VARCHAR(10);

# b
DELIMITER //
DROP TRIGGER IF EXISTS `update_medals_won_received`;
CREATE TRIGGER `update_medals_won_received`
-- BEFORE INSERT
BEFORE UPDATE
ON `medals`
FOR EACH ROW
BEGIN
SET NEW.medal_received = NEW.medal_won;
END //
DELIMITER ;

UPDATE `medals`
SET medal_received = NULL;

# c
ALTER TABLE `medals`
DROP COLUMN `medal_won`;
