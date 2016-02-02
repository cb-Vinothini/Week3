DROP DATABASE IF EXISTS `phone_db`;
CREATE DATABASE `phone_db`;
USE `phone_db`;

DROP TABLE IF EXISTS `contacts`;
CREATE TABLE `contacts`(
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(50) NOT NULL,
  `address` VARCHAR(100) NOT NULL,
  `mobile` VARCHAR(10) DEFAULT NULL,
  `home` VARCHAR(10) DEFAULT NULL,
  `work` VARCHAR(10) DEFAULT NULL
);

-- update contacts set name = "a", address = "c", mobile = 123, home = 234, work = 345 WHERE NAME = "PERSON1" AND ADDRESS = "ADDRESS1";
