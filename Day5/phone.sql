-- DROP DATABASE IF EXISTS `phone_db`;
-- CREATE DATABASE `phone_db`;

-- DROP TABLE IF EXISTS `contacts`;
-- CREATE TABLE `contacts`(
--   `name` VARCHAR(50) NOT NULL,
--   `address` VARCHAR(100) NOT NULL,
--   `mobile` INT(10) CHECK (`mobile` LIKE REPLICATE('[0-9]', 10)),
--   `home` INT(10) CHECK (`home` LIKE REPLICATE('[0-9]', 10)),
--   `work` INT(10) CHECK (`work` BETWEEN 1000000000 AND 999999999)
-- );

update contacts set name = "a", address = "c", mobile = 123, home = 234, work = 345 WHERE NAME = "PERSON1" AND ADDRESS = "ADDRESS1";
