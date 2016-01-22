DROP DATABASE IF EXISTS `service_stations`;
CREATE DATABASE IF NOT EXISTS `service_stations`;
USE `service_stations`;

DROP TABLE IF EXISTS `service_station`;
CREATE TABLE `service_station`(
	`id`  INT UNSIGNED NOT NULL ,
	`name` VARCHAR(30) NOT NULL ,
	`address` VARCHAR(50) NOT NULL,
	`contactNo` INT NOT NULL CHECK (contachPhNo BETWEEN 1000000000 AND 9999999999),
	PRIMARY KEY (id)
);

DROP TABLE IF EXISTS `employees`;
CREATE TABLE `employees`(
  `id` INT UNSIGNED NOT NULL,
  `name` VARCHAR(30) NOT NULL,
  `dob` DATE NOT NULL,
  `contact_no` INT NOT NULL CHECK (contach_no BETWEEN 1000000000 AND 9999999999),
  PRIMARY KEY(`id`)
);

DROP TABLE IF EXISTS `customers`;
CREATE TABLE `customers`(
  `id` INT UNSIGNED NOT NULL,
  `name` VARCHAR(30) NOT NULL,
  `dob` DATE NOT NULL,
  `contac_no` INT NOT NULL CHECK (`contac_no` LIKE REPLICATE('[0-9]', 10)),
  `empID` INT UNSIGNED,
  PRIMARY KEY(`id`),
  CONSTRAINT `fk_cust_emp` FOREIGN KEY (`empID`) REFERENCES `employees` (`id`)
);

DROP TABLE IF EXISTS `vehicles`;
CREATE TABLE `vehicles`(
  `id` INT UNSIGNED NOT NULL,
  `type` ENUM ('Bike', 'Car', 'Bus'),
  `brand` VARCHAR(10) NOT NULL,
  `color` VARCHAR(10) NOT NULL,
  `service_charge` INT NOT NULL,
  PRIMARY KEY(`id`)
);

DROP TABLE IF EXISTS `invoices`;
CREATE TABLE `invoices`(
  `id` INT UNSIGNED NOT NULL,
  `name_of_owner` INT UNSIGNED NOT NULL,
  `vehicled` INT NOT NULL,
  `amount_total` INT UNSIGNED NOT NULL,
  `employee_assigned` INT UNSIGNED NOT NULL,
  PRIMARY KEY(`id`),
  CONSTRAINT `fk_invoice_cust` FOREIGN KEY(`name_of_owner`) REFERENCES `customers` (`id`),
  CONSTRAINT `fk_invoice_emp` FOREIGN KEY(`employee_assigned`) REFERENCES `employees` (`id`)
);
