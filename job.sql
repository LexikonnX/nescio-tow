ALTER TABLE `owned_vehicles` ADD `impound` INT(1) NOT NULL DEFAULT '0' AFTER `type`, ADD `ngarage` VARCHAR(100) NULL DEFAULT NULL AFTER `impound`;
INSERT INTO `jobs` (`name`, `label`, `whitelisted`) VALUES ('tow', 'Towing', '0');
INSERT INTO `jobs` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES ('tow', '0', 'employee', 'Tow master', '30', '{}', '{}');