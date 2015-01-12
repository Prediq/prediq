USE prediq_rdev_development;

DROP TABLE `WBI_FORECAST_DATA`, `WEATHER`, `WEATHER_TMP`;
DROP TABLE F_SALES_TMP;
DROP TABLE DIM_PREDOM_WEATHER;
DROP TABLE BMS_PROFILE_BACKUP;
DROP TABLE PREDICTOR_MODEL2;

-- Also noticed we had a MyISAM Table in there I converted to InnoDB.

ALTER TABLE  `BMS_PROFILE` ENGINE = INNODB;


-- In the "api" database:

use prediq_api_development;

ALTER TABLE  `api_address` ADD  `primary_address` BOOLEAN NOT NULL COMMENT 'Determines if this is the primary address for the user.' AFTER  `lon` ,
ADD INDEX (  `primary_address` ) ;

UPDATE `api_address` SET `primary_address`=1;

ALTER TABLE `api_customer` DROP `address_id`;