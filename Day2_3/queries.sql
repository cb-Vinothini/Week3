#------------------------- SIMPLE QUERIES ---------------------------

#SELECT * FROM `students`;

#SELECT * FROM `students` WHERE `name` LIKE 'H%';

#SELECT * FROM `students` WHERE LOWER(`name`) LIKE '%a%';

#SELECT * FROM `students` ORDER BY `name`;

#SELECT * FROM `students` ORDER BY `name` LIMIT 2;

#SELECT * FROM `students` ORDER BY `name` LIMIT 2, 2;

#SELECT * FROM `marks`;

#SELECT * FROM `marks` WHERE `annual` IS NULL;

#SELECT `student_id`, `subject_id`, `year` FROM `marks` WHERE `annual` IS NULL AND `year` = 2005;

#SELECT `student_id`, `subject_id`, `year` FROM `marks` WHERE `quarterly` IS NOT NULL OR `half_yearly` IS NOT NULL OR `annual` IS NOT NULL;

#SELECT `student_id`, `subject_id`, `year`, `quarterly`, `half_yearly`, `annual` FROM `marks` WHERE quarterly > 90 AND `half_yearly` > 90 AND `annual` > 90;

#SELECT `student_id`,`subject_id`,(COALESCE(`quarterly`)+COALESCE(`half_yearly`)+COALESCE(`annual`))/3 AS `average`, `year` FROM MARKS;

#SELECT `student_id`,`subject_id`,(COALESCE(`quarterly`)+COALESCE(`half_yearly`)+COALESCE(`annual`))/3 AS `average`, `year` FROM MARKS WHERE `year` IN (2003, 2004);

#------------------------- ADVANCED QUERIES ---------------------------

#SELECT m.id, s.name, m.subject_id, m.quarterly, m.half_yearly, m.annual, m.year, m.grade FROM `marks` m INNER JOIN `students` s WHERE m.student_id = s.id;

SELECT s.name FROM `marks` m INNER JOIN `students` s WHERE m.quarterly IS NULL AND m.half_yearly IS NULL AND m.annual IS NULL AND s.id = m.student_id;
