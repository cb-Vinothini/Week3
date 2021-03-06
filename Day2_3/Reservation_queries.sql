
-- 1
SELECT train_name FROM `trains`;
--
-- DROP FUNCTION IF EXISTS `get_station_code`;
-- DELIMITER //
-- CREATE FUNCTION `get_station_code` (`id` BIGINT(5)) RETURNS VARCHAR(5)
-- BEGIN
-- DECLARE `code` VARCHAR(5);
-- SELECT `station_code` INTO `code` FROM `stations` WHERE `station_id` = `id`;
-- RETURN (`code`);
-- END //
-- DELIMITER ;
--
-- DROP FUNCTION IF EXISTS `get_train_name`;
-- DELIMITER //
-- CREATE FUNCTION `get_train_name` (`no` BIGINT(10)) RETURNS VARCHAR(20)
-- BEGIN
-- DECLARE `name` VARCHAR(20);
-- SELECT `train_name` INTO `name` FROM `trains` WHERE `train_no` = `no`;
-- RETURN (`name`);
-- END //
-- DELIMITER ;
--
-- 2
-- SELECT route_id, get_station_code(origin_station_id) AS `origin_station`, get_station_code(destination_station_id) AS `destination_station`, distance_in_kms
-- FROM `routes`;

SELECT r.route_id, s1.station_code AS `origin_station`, s2.station_code AS `destination_station`, r.distance_in_kms
FROM `routes` r
INNER JOIN `stations` s1 ON r.origin_station_id = s1.station_id
INNER JOIN `stations` s2 ON r.destination_station_id = s2.station_id;

-- 3
-- SELECT get_train_name(train_no) AS 'train_name', SUM(no_of_seats) AS `total_no_of_seats`
-- FROM `train_coaches`
-- GROUP BY train_no;

SELECT t.train_name ,SUM(c.no_of_seats) AS `total_no_of_seats`
FROM `train_coaches` c
INNER JOIN `trains` t ON c.train_no = t.train_no
GROUP BY t.train_no;

-- 4
-- SELECT `route_id`, get_station_code(origin_station_id) AS `origin_station`, get_station_code(destination_station_id) AS `destination_station`
-- FROM `routes`
-- WHERE `destination_station_id` = (SELECT `station_id`
--                                   FROM `stations`
--                                   WHERE `station_code` = "CBE");

SELECT r.route_id, s1.station_code AS `origin_station`, s2.station_code AS `destination_station`
FROM `routes` r
INNER JOIN `stations` s1 ON r.origin_station_id = s1.station_id
INNER JOIN `stations` s2 ON r.destination_station_id = s2.station_id
WHERE s2.station_code = "CBE";

-- 5
-- SELECT `route_id`, get_station_code(origin_station_id) AS `origin_station`, get_station_code(destination_station_id) AS `destination_station`
-- FROM `routes`
-- WHERE `origin_station_id` IN (SELECT `station_id`
--                               FROM `stations`
--                               WHERE `station_code` IN ("KPD", "MAS"));

SELECT r.route_id, s1.station_code AS `origin_station`, s2.station_code AS `destination_station`
FROM `routes` r
INNER JOIN `stations` s1 ON r.origin_station_id = s1.station_id
INNER JOIN `stations` s2 ON r.destination_station_id = s2.station_id
WHERE s1.station_code IN ("KPD", "MAS");

-- 6
SELECT *
FROM `bookings`
WHERE date_of_booking
BETWEEN "2015-12-15" AND "2016-01-15";

-- 7
SELECT *
FROM `trains`
WHERE `train_name` LIKE 'L%';

-- 8
SELECT *
FROM `bookings`
WHERE `date_of_booking` IS NOT NULL;

-- 9
SELECT *
FROM `bookings`
WHERE YEAR(`date_of_booking`) = "2015"
AND
YEAR(`date_of_journey`) = "2016";

-- 10
-- SELECT get_train_name(train_no), COUNT(c.coach_code) AS `no_of_coaches`
-- FROM `train_coaches`
-- GROUP BY `train_no`;

SELECT t.train_name, COUNT(c.coach_code) AS `no_of_coaches`
FROM `train_coaches` c
INNER JOIN `trains` t ON t.train_no = c.train_no
GROUP BY t.train_no;

-- 11
-- SELECT get_train_name(train_no), COUNT(b.booking_ref_no) AS `no_of_bookings`
-- FROM `bookings`
-- WHERE train_no = 10002
-- GROUP BY `train_no`;

SELECT t.train_name, COUNT(b.booking_ref_no) AS `no_of_bookings`
FROM `bookings` b
INNER JOIN `trains` t ON t.train_no = b.train_no
WHERE t.train_no = 10002
GROUP BY t.train_no;

-- 12
-- SELECT get_train_name(train_no), SUM(`no_of_tickets`) AS `no_of_bookings`
-- FROM `bookings`
-- WHERE train_no = 10002
-- GROUP BY `train_no`;

SELECT t.train_name, SUM(b.no_of_tickets) AS `no_of_bookings`
FROM `bookings` b
INNER JOIN `trains` t ON t.train_no = b.train_no
WHERE t.train_no = 10002 GROUP BY t.train_no;

-- 13
SELECT *
FROM `routes`
WHERE `distance_in_kms` = (SELECT MIN(distance_in_kms)
                            FROM `routes`);

-- 14
-- SELECT get_train_name(train_no), SUM(`no_of_tickets`) AS `no_of_bookings`
-- FROM `bookings`
-- GROUP BY `train_no`;

SELECT t.train_name, SUM(b.no_of_tickets) AS `no_of_bookings`
FROM `bookings` b
INNER JOIN `trains` t ON t.train_no = b.train_no
GROUP BY t.train_no;

-- 15
SELECT coach_code, cost_per_km*50 AS `cost_for_50kms`
FROM `coaches`;

-- 16
-- SELECT get_train_name(train_no) AS `trian_name`, departure_time
-- FROM `train_route_maps`
-- WHERE `route_id` IN (SELECT `route_id`
--                       FROM `routes`
--                       WHERE get_station_code(origin_station_id) = 'MAS');

SELECT t.train_name, m.departure_time
FROM `routes` r
INNER JOIN `stations` s ON s.station_id = r.origin_station_id
INNER JOIN `train_route_maps` m ON r.route_id = m.route_id
INNER JOIN `trains` t ON t.train_no = m.train_no
WHERE s.station_code = 'MAS';

-- 17
-- SELECT get_train_name(train_no)
-- FROM `bookings`
-- GROUP BY `train_no`
-- HAVING SUM(`no_of_tickets`) >= 3;

SELECT t.train_name
FROM `bookings` b
INNER JOIN `trains` t ON t.train_no = b.train_no
GROUP BY t.train_no
HAVING SUM(b.no_of_tickets) >= 3;

-- 18
-- SELECT get_train_name(train_no)
-- FROM `bookings`
-- GROUP BY `train_no`
-- HAVING SUM(`no_of_tickets`) <= 3;

SELECT t.train_name
FROM `bookings` b
INNER JOIN `trains` t ON t.train_no = b.train_no
GROUP BY t.train_no
HAVING SUM(b.no_of_tickets) <= 3;

-- 19
-- SELECT get_train_name(b.train_no), get_station_code(r.origin_station_id) AS `origin_station`, get_station_code(r.destination_station_id) AS `destination_station`, b.coach_code
-- FROM `bookings` b
-- INNER JOIN `routes` r ON b.route_id = r.route_id
-- WHERE b.date_of_journey > "2016-03-01";

SELECT t.train_name, s1.station_code AS `origin_station`, s2.station_code AS `destination_station`, b.coach_code
FROM `bookings` b
INNER JOIN `routes` r ON b.route_id = r.route_id
INNER JOIN `trains` t ON t.train_no = b.train_no
INNER JOIN `stations` s1 ON s1.station_id = r.origin_station_id
INNER JOIN `stations` s2 ON s2.station_id = r.destination_station_id
WHERE b.date_of_journey > "2016-03-01";

-- 20
-- SELECT get_train_name(train_no) AS `trian_name`
-- FROM `train_route_maps`
-- WHERE `route_id` IN (SELECT route_id
--                       FROM ROUTES
--                       WHERE get_station_code(origin_station_id) = "MAS"
--                       AND get_station_code(destination_station_id) = "CBE");

SELECT t.train_name
FROM `train_route_maps` m
INNER JOIN `routes` r ON m.route_id = r.route_id
INNER JOIN `stations` s1 ON r.origin_station_id = s1.station_id
INNER JOIN `stations` s2 ON r.destination_station_id = s2.station_id
INNER JOIN `trains` t ON t.train_no = m.train_no
WHERE s1.station_code = "MAS" AND s2.station_code = "CBE";

-- 21
-- SELECT DISTINCT(get_train_name(train_no))
-- FROM `bookings`
-- WHERE `date_of_booking` >= '2016-01-01';#CURDATE();

SELECT DISTINCT(t.train_name)
FROM `bookings` b
INNER JOIN `trains` t ON t.train_no = b.train_no
WHERE `date_of_booking` >= '2016-01-01';#CURDATE();
