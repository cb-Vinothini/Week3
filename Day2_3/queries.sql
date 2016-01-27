-- #------------------------- SIMPLE QUERIES ---------------------------

-- 1
SELECT *
FROM `students`;

-- 2
SELECT *
FROM `students`
WHERE `name` LIKE 'H%';

-- 3
SELECT *
FROM `students`
WHERE LOWER(`name`)
LIKE '%a%';

-- 4
SELECT *
FROM `students`
ORDER BY `name`;

-- 5
SELECT *
FROM `students`
ORDER BY `name`
LIMIT 2;

-- 6
SELECT *
FROM `students`
ORDER BY `name`
LIMIT 2, 2;

-- 7
SELECT *
FROM `marks`;

-- 8
SELECT *
FROM `marks`
WHERE `annual`
IS NULL;

-- 9
SELECT `student_id`, `subject_id`, `year`
FROM `marks`
WHERE `annual` IS NULL
AND `year` = 2005;

-- 10
SELECT `student_id`, `subject_id`, `year`
FROM `marks`
WHERE `quarterly` IS NOT NULL
OR `half_yearly` IS NOT NULL
OR `annual` IS NOT NULL;

-- 11
SELECT `student_id`, `subject_id`, `year`, `quarterly`, `half_yearly`, `annual`
FROM `marks`
WHERE quarterly > 90
AND `half_yearly` > 90
AND `annual` > 90;

-- 12
SELECT `student_id`,`subject_id`,(IFNULL(`quarterly`, 0)+IFNULL(`half_yearly`, 0)+IFNULL(`annual`, 0))/3 AS `average`, `year`
FROM MARKS;

-- 13
SELECT `student_id`,`subject_id`,(IFNULL(`quarterly`, 0)+IFNULL(`half_yearly`, 0)+IFNULL(`annual`, 0))/3 AS `average`, `year`
FROM MARKS
WHERE `year` IN (2003, 2004);

#------------------------- ADVANCED QUERIES ---------------------------

SELECT m.id, s.name, m.subject_id, m.quarterly, m.half_yearly, m.annual, m.year, m.grade
FROM `marks` m
INNER JOIN `students` s
ON m.student_id = s.id;

-- 1
SELECT s.name
FROM `marks` m
INNER JOIN `students` s
ON s.id = m.student_id
WHERE m.quarterly IS NULL AND m.half_yearly IS NULL AND m.annual IS NULL;

-- 2
SELECT s.name, sum(IFNULL(m.annual,0)) AS `marks`, m.year
FROM `marks` m
INNER JOIN `students` s
ON m.student_id = s.id
GROUP BY m.student_id, m.year;

-- 3
SELECT s.name, SUM(IFNULL(m.quarterly, 0)), m.grade
FROM `marks` m
INNER JOIN `students` s
ON m.student_id = s.id
WHERE m.year = 2003
GROUP BY m.student_id, m.grade;

-- 4
SELECT s.name, m.grade, COUNT(m.medal_won)
FROM `medals` m
INNER JOIN `students` s
ON m.student_id = s.id
WHERE m.grade IN (9, 10)
GROUP BY m.student_id, m.grade
HAVING COUNT(m.medal_won) >=3;

-- 5
SELECT s.name, m.grade, COUNT(m.medal_won) AS NO_OF_MEDALS
FROM `medals` m
RIGHT JOIN `students` s
ON s.id = m.student_id
GROUP BY s.name, m.grade
HAVING COUNT(m.medal_won) <=2;

-- 6
SELECT `student_id`, `year` FROM `marks`
WHERE `annual` > 50
GROUP BY student_id, year
HAVING COUNT(*) = 5
AND student_id IN
  (SELECT s.id FROM `medals` m
    RIGHT JOIN `students` s
    ON s.id = m.student_id
    GROUP BY s.id, m.grade
    HAVING COUNT(m.medal_won) = 0);

-- 7
SELECT s.name, s.id, m.game_id, m.medal_won, m.year, m.grade
FROM `medals` m
INNER JOIN `students` s
ON m.student_id = s.id
WHERE s.id IN (SELECT student_id
                FROM `medals`
                GROUP BY student_id
                HAVING COUNT(medal_won) >= 3);

-- 8
SELECT s.name, new_table.count_medal, new_table.q_percent, new_table.h_percent, new_table.a_percent, new_table.year, new_table.grade
FROM `students` s
INNER JOIN (SELECT table1.student_id, table1.year, table1.grade, table1.q_percent, table1.h_percent, table1.a_percent, table2.count_medal
            FROM (SELECT student_id, year, grade, SUM(COALESCE(quarterly,0))/5 AS `q_percent`, SUM(COALESCE(half_yearly,0))/5 AS `h_percent`, SUM(COALESCE(annual,0))/5 AS `a_percent`
                  FROM `marks`
                  GROUP BY student_id, year, grade) AS `table1`
            LEFT JOIN (SELECT student_id, year, COUNT(medal_won) AS `count_medal`
                        FROM `medals`
                        GROUP BY student_id, year) AS `table2`
            ON table1.student_id = table2.student_id
            AND table1.year = table2.year) AS `new_table`
ON s.id = new_table.student_id;

-- SELECT temp1.student_id, temp1.year, SUM(COALESCE(temp1.quarterly,0))/5 AS `q_percent`, SUM(COALESCE(temp1.half_yearly,0))/5 AS `h_percent`, SUM(COALESCE(temp1.annual,0))/5 AS `a_percent`, COUNT(COALESCE(temp2.medal_won,0)) FROM `marks` temp1 LEFT JOIN `medals` temp2 ON temp1.student_id = temp2.student_id AND temp1.year = temp2.year GROUP BY temp1.student_id, temp1.year;
-- SELECT s.name, COUNT(med.medal_won)/5, SUM(COALESCE(mark.quarterly,0))/5/4 AS `q_percent`, SUM(COALESCE(mark.half_yearly,0))/5/4 AS `h_percent`, SUM(COALESCE(mark.annual,0))/5/4 AS `a_percent`, mark.year, mark.grade  FROM `students` s INNER JOIN `marks` mark  ON s.id = mark.student_id INNER JOIN `medals` med ON med.student_id = s.id AND mark.student_id = med.student_id GROUP BY s.id, mark.year, mark.grade;
--
-- SELECT s.id, COUNT(new_table.medal_won), SUM(COALESCE(new_table.quarterly,0))/5 AS `q_percent`, SUM(COALESCE(new_table.half_yearly,0))/5 AS `h_percent`, SUM(COALESCE(new_table.annual,0))/5 AS `a_percent`, new_table.year, new_table.grade  FROM `students` s INNER JOIN (SELECT temp1.student_id, temp1.year, COUNT(temp2.medal_won), temp2.game_id, temp1.quarterly, temp1.half_yearly, temp1.annual, temp1.grade FROM `marks` temp1 LEFT JOIN `medals` temp2 ON temp1.student_id = temp2.student_id AND temp1.year = temp2.year) new_table  ON s.id = new_table.student_id GROUP BY s.id, new_table.year, new_table.grade ;
--
-- 9

DELIMITER //
DROP FUNCTION IF EXISTS `set_grade`;
CREATE FUNCTION `set_grade`(mark INT ) RETURNS VARCHAR(1)
BEGIN
DECLARE `var` VARCHAR(1);
IF mark >= 450 THEN
SET `var` = 'S';
ELSEIF mark >= 400 THEN
SET `var` = 'A';
ELSEIF mark >= 350 THEN
SET `var` = 'B';
ELSEIF mark >= 300 THEN
SET `var` = 'C';
ELSEIF mark >= 250 THEN
SET `var` = 'D';
ELSEIF mark >= 200 THEN
SET `var` = 'E';
ELSE
SET `var` = 'F';
END IF;
RETURN (`var`);
END//
DELIMITER ;

SELECT s.name, set_grade(SUM(COALESCE(m.quarterly, 0))), set_grade(SUM(COALESCE(m.half_yearly, 0))), set_grade(SUM(COALESCE(m.annual, 0))), m.year, m.grade
FROM `marks` m
INNER JOIN `students` s
ON m.student_id = s.id
GROUP BY m.student_id, m.year, m.grade;
