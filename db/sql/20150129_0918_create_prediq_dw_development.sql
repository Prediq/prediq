
CREATE USER 'deploy'@'localhost' IDENTIFIED BY 'dactylmobdavyshaft';

CREATE USER 'reidonly'@'localhost' IDENTIFIED BY 'dactylmobdavyshaft';

CREATE DATABASE `prediq_dw_development` CHARACTER SET utf8 COLLATE utf8_general_ci;
-- CREATE DATABASE `prediq_dw_production` CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE DATABASE `prediq_dw_qa`          CHARACTER SET utf8 COLLATE utf8_general_ci;

GRANT ALL ON `prediq_dw_development`.*  TO `deploy`@localhost IDENTIFIED BY 'dactylmobdavyshaft';
GRANT ALL ON `prediq_dw_qa`.*           TO `deploy`@localhost IDENTIFIED BY 'dactylmobdavyshaft';
GRANT ALL ON `prediq_dw_production`.*   TO `deploy`@localhost IDENTIFIED BY 'dactylmobdavyshaft';

GRANT SELECT ON `prediq_dw_development`.*   TO 'reidonly'@'localhost'  IDENTIFIED BY 'dactylmobdavyshaft';
GRANT SELECT ON `prediq_dw_qa`.*            TO 'reidonly'@'localhost'  IDENTIFIED BY 'dactylmobdavyshaft';
GRANT SELECT ON `prediq_dw_production`.*    TO 'reidonly'@'localhost'  IDENTIFIED BY 'dactylmobdavyshaft';

FLUSH PRIVILEGES;

-- d_date
CREATE TABLE prediq_dw_development.d_date(
CREATE TABLE prediq_dw_qa.d_date(
CREATE TABLE prediq_dw_production.d_date(
    id                          int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    -- keys
    date_key                    date                    NOT NULL,   -- 'DATE'    ie 2015-01-16
    week_day                    varchar(20)             NOT NULL,   -- 'WEEKDAY'
    month_name                  varchar(20)             NOT NULL,   -- 'MONTHNAME'
    week_num                    INT(11)                 NOT NULL,   -- 'WEEKNUM'
    month_num                   INT(11)                 NOT NULL,   -- 'MONTHNUM'
    day_of_year                 INT(11)                 NOT NULL,   -- 'DAYOFYEAR'
    day_of_week                 INT(11)                 NOT NULL,   -- 'DAYOFWEEK'
    day_of_month                INT(11)                 NOT NULL,   -- 'DAYOFMONTH'
    bimester                    INT(11)                 NOT NULL,   -- 'BIMESTER'
    quarter                     INT(11)                 NOT NULL,   -- 'QUARTER'
    half                        INT(11)                 NOT NULL,   -- 'HALF'
    ct_weekday_of_year          INT(11)                 NOT NULL,   -- 'CTWEEKDAYOFYEAR'
    created_at 	                TIMESTAMP 	            NOT NULL DEFAULT now(),
    UNIQUE INDEX idx_date_key   (date_key)
    ) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;


DATE 	date 	Yes
WEEKDAY 	varchar(20) 	Yes
MONTHNAME 	varchar(20) 	Yes
YEARNUM 	int(11) 	Yes
WEEKNUM 	int(11) 	Yes
MONTHNUM 	int(11) 	Yes
DAYOFYEAR 	int(11) 	Yes
DAYOFWEEK 	int(11) 	Yes
DAYOFMONTH 	int(11) 	Yes
BIMESTER 	int(11) 	Yes
QUARTER 	int(11) 	Yes
HALF 	int(11) 	Yes
CTWEEKDAYOFYEAR 	int(11) 	Yes
PRIMKEY 	int(11) 	No