#--------------------------------- ALTER TABLE --------------------------

-- 1
-- ALTER TABLE `marks`
-- DROP COLUMN `created_at`,
-- DROP COLUMN `updated_at`;

ALTER TABLE `marks`
ADD COLUMN `created_at` DATETIME,
ADD COLUMN `updated_at` DATETIME;

-- ALTER TABLE `students`
-- DROP COLUMN `created_at`,
-- DROP COLUMN `updated_at`;

ALTER TABLE `students`
ADD COLUMN `created_at` DATETIME,
ADD COLUMN `updated_at` DATETIME;

-- ALTER TABLE `medals`
-- DROP COLUMN `created_at`,
-- DROP COLUMN `updated_at`;

ALTER TABLE `medals`
ADD COLUMN `created_at` DATETIME,
ADD COLUMN `updated_at` DATETIME;

-- 2
UPDATE `marks`
SET `quarterly` = IFNULL(`quarterly` , 0), `half_yearly` = IFNULL(`half_yearly` , 0), `annual` = IFNULL(`annual` , 0)
WHERE `quarterly` IS NULL OR `half_yearly` IS NULL OR `annual` IS NULL;

ALTER TABLE `marks`
MODIFY COLUMN `quarterly` INT(11) NOT NULL DEFAULT 0,
MODIFY COLUMN `half_yearly` INT(11) NOT NULL DEFAULT 0,
MODIFY COLUMN `annual` INT(11) NOT NULL DEFAULT 0;

#--------------------------------- INSERT AND UPDATE --------------------------

ALTER TABLE `marks`
MODIFY COLUMN `created_at` DATETIME DEFAULT NOW() ON UPDATE NOW();
MODIFY COLUMN `updated_at` DATETIME DEFAULT NOW() ON UPDATE NOW();

ALTER TABLE `students`
MODIFY COLUMN `created_at` DATETIME DEFAULT NOW() ON UPDATE NOW();
MODIFY COLUMN `updated_at` DATETIME DEFAULT NOW() ON UPDATE NOW();

ALTER TABLE `medals`
MODIFY COLUMN `created_at` DATETIME DEFAULT NOW() ON UPDATE NOW();
MODIFY COLUMN `updated_at` DATETIME DEFAULT NOW() ON UPDATE NOW();

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

INSERT INTO `students_summary` SELECT s.id, s.name, m.year, AVG(IFNULL(m.annual, 0)) AS `a_percent`, IFNULL(temp.count_medal, 0) as `count_medal`
FROM service_stations.marks m
LEFT JOIN (SELECT student_id, year, COUNT(medal_won) AS `count_medal`
          FROM service_stations.medals
          GROUP BY student_id, year) temp ON m.student_id = temp.student_id AND (temp.year = m.year OR temp.year IS NULL)
INNER JOIN service_stations.students s ON s.id = m.student_id
GROUP BY s.id, m.year, temp.count_medal;

#--------------------------------- TRIGGERS EXERCISE --------------------------

-- 1
USE `service_stations`;

ALTER TABLE `marks`
DROP COLUMN `avg_all`;
ALTER TABLE `marks`
ADD COLUMN `avg_all` FLOAT(11);

DELIMITER $$
DROP TRIGGER IF EXISTS `update_marks_before_insertion`;
CREATE TRIGGER `update_marks_before_insertion`
BEFORE INSERT
ON `marks`
FOR EACH ROW
BEGIN
SET NEW.`avg_all` = (NEW.`quarterly` + NEW.`half_yearly` + NEW.`annual`)/3;
END $$
DELIMITER ;

DELIMITER $$
DROP TRIGGER IF EXISTS `update_marks_before_updation`;
CREATE TRIGGER `update_marks_before_updation`
BEFORE UPDATE
ON `marks`
FOR EACH ROW
BEGIN
SET NEW.`avg_all` = (NEW.`quarterly` + NEW.`half_yearly` + NEW.`annual`)/3;
END $$
DELIMITER ;

UPDATE `marks`
SET avg_all = 0;

-- 2
-- IF NOT EXISTS (SELECT NULL FROM INFORMATION_SCHEMA.COLUMNS
--             WHERE TABLE_SCHEMA = 'service_stations' AND TABLE_NAME = 'medals' AND COLUMN_NAME = 'medal_won') THEN
-- END IF;

ALTER TABLE `medals`
CHANGE COLUMN `medal_won` `medal_received` VARCHAR(10);

ALTER TABLE `medals`
CHANGE COLUMN `medal_received` `medal_won` VARCHAR(10);

-- # a
ALTER TABLE `medals`
DROP COLUMN `medal_received`;

ALTER TABLE `medals`
ADD COLUMN `medal_received` VARCHAR(10);

-- # b
DELIMITER //
DROP TRIGGER IF EXISTS `insert_medals_won_received`;
CREATE TRIGGER `insert_medals_won_received`
BEFORE INSERT
ON `medals`
FOR EACH ROW
BEGIN
IF NEW.medal_received IS NOT NULL THEN
  SET NEW.medal_won = NEW.medal_received;
ELSEIF NEW.medal_won IS NOT NULL THEN
  SET NEW.medal_received = NEW.medal_won;
END IF;
END //
DELIMITER ;

DELIMITER //
DROP TRIGGER IF EXISTS `update_medals_won_received`;
CREATE TRIGGER `update_medals_won_received`
BEFORE UPDATE
ON `medals`
FOR EACH ROW
BEGIN
IF IFNULL(NEW.medal_received, 'NO STRING') <> IFNULL(OLD.medal_received, 'NO STRING') THEN
  SET NEW.medal_won = NEW.medal_received;
ELSEIF IFNULL(NEW.medal_won, 'NO STRING') <> IFNULL(OLD.medal_won, 'NO STRING') THEN
  SET NEW.medal_received = NEW.medal_won;
END IF;
END //
DELIMITER ;

-- UPDATE medals SET medal_received = medal_won;
-- INSERT INTO medals (student_id, game_id, medal_received, year, grade) VALUES (100001, 3, "gold", 2006, 9);
-- UPDATE `medals`
-- SET medal_received = 'gold' WHERE id = 111;

# c
ALTER TABLE `medals`
DROP COLUMN `medal_won`;
