-- -- #------------------------- SIMPLE QUERIES ---------------------------
--
-- -- 1
-- SELECT *
-- FROM `students`;
--
-- -- 2
-- SELECT *
-- FROM `students`
-- WHERE `name` LIKE 'H%';
--
-- -- 3
-- SELECT *
-- FROM `students`
-- WHERE `name`
-- LIKE '%a%';
--
-- -- 4
-- SELECT *
-- FROM `students`
-- ORDER BY `name`;
--
-- -- 5
-- SELECT *
-- FROM `students`
-- ORDER BY `name`
-- LIMIT 2;
--
-- -- 6
-- SELECT *
-- FROM `students`
-- ORDER BY `name`
-- LIMIT 2, 2;
--
-- -- 1
-- SELECT *
-- FROM `marks`;
--
-- -- 2
-- SELECT *
-- FROM `marks`
-- WHERE `annual`
-- IS NULL;
--
-- -- 3
-- SELECT `student_id`, `subject_id`, `year`
-- FROM `marks`
-- WHERE `annual` IS NULL
-- AND `year` = 2005;
--
-- -- 4
-- SELECT `student_id`, `subject_id`, `year`
-- FROM `marks`
-- WHERE `quarterly` IS NOT NULL
-- OR `half_yearly` IS NOT NULL
-- OR `annual` IS NOT NULL;
--
-- -- 5
-- SELECT `student_id`, `subject_id`, `year`, `quarterly`, `half_yearly`, `annual`
-- FROM `marks`
-- WHERE quarterly > 90
-- AND `half_yearly` > 90
-- AND `annual` > 90;
--
-- -- 6
-- SELECT `student_id`,`subject_id`,(IFNULL(`quarterly`, 0)+IFNULL(`half_yearly`, 0)+IFNULL(`annual`, 0))/3 AS `average`, `year`
-- FROM MARKS;
--
-- -- 7
-- SELECT `student_id`,`subject_id`,(IFNULL(`quarterly`, 0)+IFNULL(`half_yearly`, 0)+IFNULL(`annual`, 0))/3 AS `average`, `year`
-- FROM MARKS
-- WHERE `year` IN (2003, 2004);
--
-- #------------------------- SIMPLE QUERIES USING INNER JOIN ---------------------------
--
-- -- 1
-- SELECT `name`
-- FROM `students`;
--
-- -- 2
-- SELECT `name`
-- FROM `students`
-- WHERE `name` LIKE 'H%';
--
-- -- 3
-- SELECT `name`
-- FROM `students`
-- WHERE `name`
-- LIKE '%a%';
--
-- -- 4
-- SELECT `name`
-- FROM `students`
-- ORDER BY `name`;
--
-- -- 5
-- SELECT `name`
-- FROM `students`
-- ORDER BY `name`
-- LIMIT 2;
--
-- -- 6
-- SELECT `name`
-- FROM `students`
-- ORDER BY `name`
-- LIMIT 2, 2;
--
-- -- 1
-- SELECT s.name, m.subject_id, m.quarterly, m.half_yearly, m.annual, m.year, m.grade
-- FROM `marks` m
-- INNER JOIN `students` s ON s.id = m.student_id;
--
-- -- 2
-- SELECT m.id, s.name, m.subject_id, m.quarterly, m.half_yearly, m.annual, m.year, m.grade
-- FROM `marks` m
-- INNER JOIN `students` s ON m.student_id = s.id
-- WHERE m.annual IS NULL;
--
-- -- 3
-- SELECT s.name, m.subject_id, m.year
-- FROM `marks` m
-- INNER JOIN `students` s ON m.student_id = s.id
-- WHERE `annual` IS NULL
-- AND `year` = 2007;
--
-- -- 4
-- SELECT s.name , m.subject_id, m.year
-- FROM `marks` m
-- INNER JOIN `students` s ON s.id = m.student_id
-- WHERE `quarterly` IS NOT NULL
-- OR `half_yearly` IS NOT NULL
-- OR `annual` IS NOT NULL;
--
-- -- 5
-- SELECT s.name, m.`subject_id`, m.`year`, m.`quarterly`, m.`half_yearly`, m.`annual`
-- FROM `marks` m
-- INNER JOIN `students` s ON s.id = m.student_id
-- WHERE quarterly > 90
-- AND `half_yearly` > 90
-- AND `annual` > 90;
--
-- -- 6
-- SELECT s.name, m.subject_id,(IFNULL(m.`quarterly`, 0)+IFNULL(m.`half_yearly`, 0)+IFNULL(m.`annual`, 0))/3 AS `average`, m.`year`
-- FROM `marks` m
-- INNER JOIN `students` s ON m.student_id = s.id;
--
-- -- 7
-- SELECT s.name, m.subject_id,(IFNULL(m.`quarterly`, 0)+IFNULL(m.`half_yearly`, 0)+IFNULL(m.`annual`, 0))/3 AS `average`, m.`year`
-- FROM `marks` m
-- INNER JOIN `students` s ON m.student_id = s.id
-- WHERE m.year IN (2003, 2004);
--
--
-- #------------------------- ADVANCED QUERIES ---------------------------
--
-- SELECT m.id, s.name, m.subject_id, m.quarterly, m.half_yearly, m.annual, m.year, m.grade
-- FROM `marks` m
-- INNER JOIN `students` s
-- ON m.student_id = s.id;
--
-- -- 1
-- SELECT s.name
-- FROM `marks` m
-- INNER JOIN `students` s
-- ON s.id = m.student_id
-- WHERE m.quarterly IS NULL AND m.half_yearly IS NULL AND m.annual IS NULL;
--
-- -- 2
-- SELECT s.name, sum(IFNULL(m.annual,0)) AS `marks`, m.year
-- FROM `marks` m
-- INNER JOIN `students` s
-- ON m.student_id = s.id
-- GROUP BY m.student_id, m.year;
--
-- -- 3
-- SELECT s.name, SUM(IFNULL(m.quarterly, 0)), m.grade
-- FROM `marks` m
-- INNER JOIN `students` s
-- ON m.student_id = s.id
-- WHERE m.year = 2003
-- GROUP BY m.student_id, m.grade;
--
-- -- 4
-- SELECT s.name, m.grade, COUNT(m.medal_won)
-- FROM `medals` m
-- INNER JOIN `students` s
-- ON m.student_id = s.id
-- WHERE m.grade IN (9, 10)
-- GROUP BY m.student_id, m.grade
-- HAVING COUNT(m.medal_won) >=3;
--
-- -- 5
-- SELECT s.name, m.grade, COUNT(m.medal_won) AS NO_OF_MEDALS
-- FROM `medals` m
-- RIGHT JOIN `students` s
-- ON s.id = m.student_id
-- GROUP BY s.name, m.grade
-- HAVING COUNT(m.medal_won) <=2;
--
-- -- 6
-- SELECT s.name, ma.year
-- FROM `medals` m
-- RIGHT JOIN `students` s ON m.student_id = s.id
-- INNER JOIN `marks` ma ON ma.student_id = s.id AND m.medal_won IS NULL
-- WHERE ma.annual > 40
-- GROUP BY ma.student_id, ma.year
-- HAVING COUNT(ma.annual) = 5;
--
-- -- 7
-- SELECT s.name, s.id, m.game_id, m.medal_won, m.year, m.grade
-- FROM `medals` m
-- INNER JOIN `students` s
-- ON m.student_id = s.id
-- WHERE s.id IN (SELECT student_id
--                 FROM `medals`
--                 GROUP BY student_id
--                 HAVING COUNT(medal_won) >= 3);
--
-- -- 8
SELECT s.name, IFNULL(temp.count_medal, 0) as `count_medal`, AVG(IFNULL(m.quarterly, 0)) AS `q_percent`, AVG(IFNULL(m.half_yearly, 0)) AS `h_percent`, AVG(IFNULL(m.annual, 0)) AS `a_percent`, m.year, m.grade
FROM `marks` m
LEFT JOIN (SELECT student_id, year, COUNT(medal_won) AS `count_medal`
          FROM `medals`
          GROUP BY student_id, year) temp ON m.student_id = temp.student_id AND (temp.year = m.year OR temp.year IS NULL)
INNER JOIN `students` s ON s.id = m.student_id
GROUP BY s.id, m.year, m.grade, temp.count_medal;
--
-- -- 9
-- DELIMITER //
-- DROP FUNCTION IF EXISTS `set_grade`;
-- CREATE FUNCTION `set_grade`(mark INT ) RETURNS VARCHAR(1)
-- BEGIN
-- DECLARE `var` VARCHAR(1);
--   CASE
--     WHEN mark >= 450 AND mark < 500 THEN
--     SET `var` = 'S';
--     WHEN mark >= 400 AND mark < 450 THEN
--     SET `var` = 'A';
--     WHEN mark >= 350 AND mark < 400 THEN
--     SET `var` = 'B';
--     WHEN mark >= 300 AND mark < 350 THEN
--     SET `var` = 'C';
--     WHEN mark >= 250 AND mark < 300 THEN
--     SET `var` = 'D';
--     WHEN mark >= 200 AND mark < 250 THEN
--     SET `var` = 'E';
--     ELSE
--     SET `var` = 'F';
--   END CASE;
-- RETURN (`var`);
-- END//
-- DELIMITER ;
--
-- SELECT s.name, set_grade(SUM(IFNULL(m.quarterly, 0))), set_grade(SUM(IFNULL(m.half_yearly, 0))), set_grade(SUM(IFNULL(m.annual, 0))), m.year, m.grade
-- FROM `marks` m
-- INNER JOIN `students` s
-- ON m.student_id = s.id
-- GROUP BY m.student_id, m.year, m.grade;
