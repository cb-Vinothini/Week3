DROP DATABASE IF EXISTS `reservation_system`;
CREATE DATABASE `reservation_system`;
USE `reservation_system`;

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`(
  `user_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `login_id` BIGINT(20) NOT NULL,
  `login_password` VARCHAR(20) NOT NULL,
  PRIMARY KEY(user_id)
);

INSERT INTO `users` VALUES ( 1, 1234, 'abc'), ( 2, 2345, 'cbd'), ( 3 , 3456, 'bde'), ( 4, 4567, 'def'), ( 5, 5678, 'efg');

DROP TABLE IF EXISTS `stations`;
CREATE TABLE `stations`(
  `station_id` BIGINT(5) NOT NULL AUTO_INCREMENT,
  `station_code` VARCHAR(5) NOT NULL,
  PRIMARY KEY(`station_id`)
);

INSERT INTO `stations` VALUES (101,'MAS'), (102,'KPM'), (103,'KPD'), (104,'CBE'), (105,'WJR');

DROP TABLE IF EXISTS `routes`;
CREATE TABLE `routes`(
  `route_id` BIGINT(10) NOT NULL AUTO_INCREMENT,
  `origin_station_id` BIGINT(5) NOT NULL,
  `destination_station_id` BIGINT(5) NOT NULL,
  `distance_in_kms` BIGINT(5) NOT NULL,
  PRIMARY KEY(`route_id`),
  CONSTRAINT `fk_origin_station_id` FOREIGN KEY(`origin_station_id`) REFERENCES `stations`(`station_id`),
  CONSTRAINT `fk_desti_station_id` FOREIGN KEY(`destination_station_id`) REFERENCES `stations`(`station_id`)
);

INSERT INTO `routes` VALUES (1001, 101, 102, 120), (1002, 101, 103, 140), (1003, 101, 104, 550), (1004, 102, 103, 100), (1005, 102, 104, 500), (1006, 103, 105, 20), (1007, 104, 105, 525), (1008, 103, 104, 475);

DROP TABLE IF EXISTS `trains`;
CREATE TABLE `trains`(
  `train_no` BIGINT(10) NOT NULL AUTO_INCREMENT,
  `train_name` VARCHAR(20) NOT NULL,
  PRIMARY KEY(`train_no`)
);

INSERT INTO `trains` VALUES (10001, 'KOVAI EXPRESS'), (10002, 'DANBAD'), (10003, 'BLUE MOUNTAIN'), (10004, 'CHERAN'), (10005, 'TIRUPATI EXPRESS'), (10006, 'LALBAGD');

DROP TABLE IF EXISTS `train_route_maps`;
CREATE TABLE `train_route_maps`(
  `route_id` BIGINT(10) NOT NULL,
  `train_no` BIGINT(10) NOT NULL,
  `arrival_time` TIME,
  `departure_time` TIME,
  `duration_in_mins` BIGINT(20),
  CONSTRAINT `pk_route_trainno` PRIMARY KEY(`route_id`, `train_no`),
  CONSTRAINT `fk_route` FOREIGN KEY(`route_id`) REFERENCES `routes` (`route_id`),
  CONSTRAINT `fk_train_no` FOREIGN KEY(`train_no`) REFERENCES `trains` (`train_no`)
);

DROP TRIGGER IF EXISTS `calc_duration_mins`;
DELIMITER $$
CREATE TRIGGER `calc_duration_mins`
BEFORE INSERT
ON train_route_maps
FOR EACH ROW
BEGIN
SET NEW.duration_in_mins = TIME_TO_SEC(TIMEDIFF(NEW.arrival_time, NEW.departure_time))/60;
END
$$
DELIMITER ;

INSERT INTO train_route_maps (route_id, train_no, arrival_time, departure_time) VALUES (1002, 10001, "7:44:00", "06:15:00"), (1003, 10001, "13:45:00", "06:15:00"), (1006, 10001, "20:23:00", "20:03:00"), (1007, 10001, "20:23:00", "14:55:00"), (1008, 10001, "13:45:00", "08:10:00"), (1006, 10002, "19:05:00", "18:40:00"), (1007, 10002, "19:05:00", "12:00:00"), (1002, 10003, "23:05:00", "21:15:00"), (1008, 10003, "28:15:00", "23:05:00"), (1002, 10004, "25:05:00", "23:15:00"), (1008, 10004, "30:15:00", "25:05:00"), (1002, 10005, "12:10:00", "09:30:00"), (1002, 10006, "19:13:00", "4:29:00"), (1006, 10006, "25:10:00", "24:27:00");

DROP TABLE IF EXISTS `coaches`;
CREATE TABLE `coaches`(
  `coach_code` VARCHAR(3) NOT NULL,
  `cost_per_km` INT(5) NOT NULL,
  PRIMARY KEY(`coach_code`)
);

INSERT INTO `coaches` VALUES ('S1', 3), ('S2', 3), ('S3', 3), ('C1', 9), ('C2', 9), ('D1', 6), ('D2', 6), ('D3', 6);

DROP TABLE IF EXISTS `train_coaches`;
CREATE TABLE `train_coaches`(
  `train_no` BIGINT(10) NOT NULL,
  `coach_code` VARCHAR(3) NOT NULL,
  `no_of_seats` INT(10) NOT NULL,
  CONSTRAINT `fk_train_coaches` FOREIGN KEY(`train_no`) REFERENCES `trains` (`train_no`),
  CONSTRAINT `fk_coach_code` FOREIGN KEY(`coach_code`) REFERENCES `coaches` (`coach_code`)
);

INSERT INTO `train_coaches` VALUES (10001, 'S1', 100), (10001, 'S2', 100), (10001, 'S3', 100), (10002, 'D1', 50), (10002, 'C1', 40), (10003, 'D1', 50), (10003, 'C1', 40), (10003, 'C2', 50), (10004, 'D1', 50), (10004, 'C1', 40), (10004, 'C2', 50), (10005, 'S1', 100), (10006, 'S1', 100), (10006, 'S2', 100);

DROP TABLE IF EXISTS `bookings`;
CREATE TABLE `bookings`(
  `booking_ref_no` BIGINT(20) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `route_id` BIGINT(10) NOT NULL,
  `train_no` BIGINT(10) NOT NULL,
  `coach_code` VARCHAR(3) NOT NULL,
  `date_of_journey` DATE NOT NULL,
  `date_of_booking` DATE,
  `no_of_tickets` INT(1) NOT NULL,
  CONSTRAINT `fk_route_booking` FOREIGN KEY(`route_id`) REFERENCES `routes` (`route_id`),
  CONSTRAINT `fk_train_no_booking` FOREIGN KEY(`train_no`) REFERENCES `trains` (`train_no`),
  CONSTRAINT `fk_coach_code_booking` FOREIGN KEY(`coach_code`) REFERENCES `coaches` (`coach_code`)
);

INSERT INTO `bookings` (`route_id`, `train_no`, `coach_code`, `date_of_journey`, `date_of_booking`, `no_of_tickets`) VALUES (1002, 10003, 'D1', "2016-02-14", "2016-01-01", 2), (1003, 10001, 'S2', "2016-04-19", "2016-01-04", 1), (1006,  10006, 'S2', "2016-03-20", "2016-01-22", 4), (1007, 10002, 'C1', "2016-02-10", "2015-12-04", 3), (1008, 10004, 'C2', "2016-01-30", "2015-12-28", 2), (1006, 10002, 'D1', "2016-04-3", NULL, 1), (1006, 10002, 'D1', "2016-04-3", NULL, 1), (1002, 10001, 'S3', "2015-12-07", NULL, 4);
