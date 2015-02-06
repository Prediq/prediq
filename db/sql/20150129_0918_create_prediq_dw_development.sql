-- 20150204_1002_create_prediq_dw_development

/*
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

*/

-- d_date
CREATE TABLE IF NOT EXISTS prediq_dw_development.d_date(
-- CREATE TABLE prediq_dw_qa.d_date(
-- CREATE TABLE prediq_dw_production.d_date(
    id                          int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    -- keys
    date_key                    date                    NOT NULL,   -- 'DATE'    ie 2015-01-16
    -- attributes
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


TRUNCATE TABLE prediq_dw_development.d_date;

INSERT INTO prediq_dw_development.d_date(
    date_key,
    week_day,
    month_name,
    week_num,
    month_num,
    day_of_year,
    day_of_week,
    day_of_month,
    bimester,
    quarter,
    half,
    ct_weekday_of_year,
    created_at )
SELECT
    DATE,
    WEEKDAY,
    MONTHNAME,
    YEARNUM,
    WEEKNUM,
    MONTHNUM,
    DAYOFYEAR
    DAYOFWEEK,
    DAYOFMONTH,
    BIMESTER,
    QUARTER,
    HALF,
    CTWEEKDAYOFYEAR,
    now()
FROM prediq_rdev_development.D_DATE;

COMMIT;

CREATE TABLE IF NOT EXISTS prediq_dw_development.d_weather_station(
-- CREATE TABLE prediq_dw_qa.d_date(
-- CREATE TABLE prediq_dw_production.d_date(
    id                          INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    -- keys
    weather_station_id          INT(11)                 NOT NULL,   -- 'WEATHER_STATIONS_ID'
    -- attributes
    station_code                VARCHAR(32)             NOT NULL,   -- 'STATION_CODE'
    lat                         DOUBLE(9,6)             NOT NULL,   -- 'LAT'
    `long`                      DOUBLE(9,6)             NOT NULL,   -- 'LONG'
    elevation_ft                INT(6)                  NOT NULL,   -- 'ELEVATION_FT'
    time_zone                   VARCHAR(40)             NOT NULL,   -- 'TIME_ZONE'
    created_at 	                TIMESTAMP 	            NOT NULL DEFAULT now(),
    UNIQUE INDEX unidx_weather_station_id   (weather_station_id),
    UNIQUE INDEX unidx_station_code         (station_code),
           INDEX idx_lat                    (lat),
           INDEX idx_lat                    (lat)
    ) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

TRUNCATE TABLE prediq_dw_development.d_weather_stations;

INSERT INTO prediq_dw_development.d_weather_stations(
    weather_station_id,
    station_code,
    lat,
    `long`,
    elevation_ft,
    time_zone,
    created_at )
SELECT
    WEATHER_STATIONS_ID,
    STATION_CODE,
    LAT,
    `LONG`,
    ELEVATION_FT,
    TIME_ZONE,
    now()
FROM prediq_rdev_development.WEATHER_STATIONS;

COMMIT;

CREATE TABLE IF NOT EXISTS prediq_dw_development.d_weather_code(
    weather_codes_id 	            INT(11)     NOT NULL AUTO_INCREMENT PRIMARY KEY,
    wbi_2digit_predominate_weather 	INT(2) 	    NOT NULL,
    wbi_2to4_letter_code 	        varchar(4)  NOT NULL,
    predominate_weather_text 	    varchar(75) NOT NULL,
    created_at 	                    TIMESTAMP 	NOT NULL DEFAULT now()
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

TRUNCATE TABLE prediq_dw_development.d_weather_codes;

INSERT INTO prediq_dw_development.d_weather_codes(
    weather_codes_id,
    wbi_2digit_predominate_weather,
    wbi_2to4_letter_code,
    predominate_weather_text,
    created_at )
SELECT
    weather_codes_id,
    wbi_2digit_predominate_weather,
    wbi_2to4_letter_code,
    predominate_weather_text,
    now()
FROM prediq_rdev_development.WEATHER_CODES;

COMMIT;

-- d_company_info
-- hooks up to 'prediq_dw_development.d_sales_receipts' via qb_company_info_id
CREATE TABLE IF NOT EXISTS prediq_dw_development.d_company_info(
-- CREATE TABLE prediq_dw_qa.d_date(
-- CREATE TABLE prediq_dw_production.d_date(
    id                          int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    -- dw keys
    qb_company_info_id          INT(11)                 NOT NULL,   --
    api_customer_id             INT(11)                 NOT NULL,   --  the 'user_id' from the api_customer table
    -- attributes
    sync_token                  INT(11)                         ,
    meta_data_create_time       DATETIME                NOT NULL,
    meta_data_update_time       DATETIME                NOT NULL,   -- select from QB where meta_data_update_time = 'yesterday', then use this to update this table and the d_company_address data if it changed
    company_name                varchar(255)            NOT NULL,
    legal_name                  varchar(255)            NOT NULL,
    primary_phone               varchar(255)                    ,
    company_start_date          DATETIME                NOT NULL,
    fiscal_year_start_month     varchar(32)             NOT NULL,
    country                     varchar(32)             NOT NULL,
    email                       varchar(255)                    ,
    created_at 	                TIMESTAMP 	            NOT NULL DEFAULT now(),
    INDEX idx_qb_company_info_id    (qb_company_info_id),
    INDEX idx_api_customer_id       (api_customer_id)
    ) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

-- hooks up to 'prediq_dw_development.d_company_info' via qb_company_info_id
CREATE TABLE IF NOT EXISTS prediq_dw_development.d_company_address(
-- CREATE TABLE prediq_dw_qa.d_date(
-- CREATE TABLE prediq_dw_production.d_date(
    id                        int(11) NOT     NULL AUTO_INCREMENT PRIMARY KEY,
    address_type              varchar(32)     NOT NULL, -- main, comm, legal
    api_customer_id           int(11)         NOT NULL,
    qb_company_info_id        int(11)         NOT NULL,
    qb_company_address_id     int(11)         NOT NULL,
    weather_stations_id       int(11)         NOT NULL DEFAULT 0, -- "real" value to be filled in later from d_weather_station by getting the closest weather station
    line_1                    varchar(255)        NULL,
    line_2                    varchar(255)        NULL,
    line_3                    varchar(255)        NULL,
    line_4                    varchar(255)        NULL,
    line_5                    varchar(255)        NULL,
    city                      varchar(255)    NULL,
    country                   varchar(255)    NULL,
    country_sub_division_code varchar(255)    NULL,
    postal_code               varchar(255)    NULL,
    lat                       decimal(10,7)   NULL,
    lon                       decimal(10,7)   NULL ,
    INDEX idx_api_customer_id(api_customer_id),
    INDEX idx_qb_company_info_id(qb_company_info_id),
    INDEX idx_qb_company_address_id(qb_company_address_id),
    INDEX idx_qb_company_address_id(weather_stations_id)
)
ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;



-- 20150115_0814_create_d_sales_receipts_table.sql

CREATE TABLE prediq_dw_development.d_sales_receipt(
    id                          int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    -- keys
    date_key                    date                    NOT NULL,  -- ie 2015-01-16
    api_customer_id             INT(11)                 NOT NULL,
    api_address_id              INT(11)                 NOT NULL,   -- how to get this???
    weather_stations_id         INT(11)                 NOT NULL DEFAULT 0, -- "real" value to be filled in later from d_weather_station by getting the closest weather station-- attributes
    qb_sales_receipt_id         INT(11)                 NOT NULL,   -- the Quickbooks sales receipt id
    sync_token  	            INT(11)                 NOT NULL,
    transaction_date 	        DATETIME 	            NOT NULL,
    meta_data_create_time 	    DATETIME 	            NOT NULL,
    meta_data_update_time       DATETIME                NOT NULL,
    sales_receipt_total 	    DECIMAL(10,2) 	        NOT NULL,
    -- bill_address items
    bill_address_id 	        INT(11) 	            NOT NULL,   -- the Quickbooks bill_address id "bill_address"=>{"id"=>66, ...}
    bill_address_line_1 	    VARCHAR(255) 	        NOT NULL,
    bill_address_line_2 	    VARCHAR(255) 	            NULL,
    bill_address_line_3 	    VARCHAR(255) 	            NULL,
    bill_address_line_4 	    VARCHAR(255) 	            NULL,
    bill_address_line_5 	    VARCHAR(255) 	            NULL,
    bill_address_city 	        VARCHAR(255) 	            NULL,
    bill_address_country_sub_division_code 	VARCHAR(255) 	NULL,
    bill_address_postal_code 	VARCHAR(255) 	            NULL,
    bill_address_lat 	        DECIMAL(10,7) 	            NULL,
    bill_address_lon 	        DECIMAL(10,7) 	            NULL,
    bill_email_address 	        VARCHAR(255) 	            NULL,
    -- shipping items
    ship_address_id 	        INT(11) 	                NULL,
    ship_address_line_1 	    VARCHAR(255) 	            NULL,
    ship_address_line_2 	    VARCHAR(255) 	            NULL,
    ship_address_line_3 	    VARCHAR(255) 	            NULL,
    ship_address_line_4 	    VARCHAR(255) 	            NULL,
    ship_address_line_5 	    VARCHAR(255) 	            NULL,
    ship_address_city 	        VARCHAR(255) 	            NULL,
    ship_address_country_sub_division_code 	VARCHAR(255) 	NULL,
    ship_address_postal_code 	VARCHAR(255) 	            NULL,
    ship_address_lat 	        DECIMAL(10,7) 	            NULL,
    ship_address_lon 	        DECIMAL(10,7) 	            NULL,
    ship_method_ref_name 	    VARCHAR(255) 	            NULL,
    ship_method_ref_value 	    INT(11) 	                NULL,
    ship_method_ref_type 	    VARCHAR(255) 	            NULL,
    ship_date 	                TIMESTAMP 	                NULL,
    -- Quickbooks ref_type's
    department_ref_name 	    VARCHAR(255) 	            NULL,
    department_ref_value 	    INT(11) 	                NULL,
    department_ref_type 	    VARCHAR(255) 	            NULL,
    payment_method_ref_name 	VARCHAR(255) 	            NULL,
    payment_method_ref_value 	INT(11) 	                NULL,
    payment_method_ref_type 	VARCHAR(255) 	            NULL,
    customer_ref_name 	        VARCHAR(255) 	            NULL,
    customer_ref_value 	        INT(11) 	                NULL,
    customer_ref_type 	        VARCHAR(255) 	            NULL,
    -- various
    balance 	                DECIMAL(10,2) 	            NULL,
    payment_type 	            VARCHAR(255) 	            NULL,
    currency_ref 	            TINYINT(1) 	                NULL,
    exchange_rate 	            DECIMAL(6,2) 	            NULL,
    global_tax_calculation 	    VARCHAR(255) 	            NULL,
    home_total_amount 	        DECIMAL(10,2) 	            NULL,
    apply_after_tax_discount 	TINYINT(1) 	                NULL,
    customer_memo 	            VARCHAR(1024) 	            NULL,
    private_note 	            VARCHAR(4096) 	            NULL,
    linked_transaction_id 	    VARCHAR(255) 	            NULL,
    txn_tax_code_ref 	        VARCHAR(255) 	            NULL,
    total_tax 	                DECIMAL(10,4) 	            NULL,
    created_at 	                TIMESTAMP 	            NOT NULL DEFAULT now(),
    INDEX idx_date_key              (date_key),
    INDEX idx_api_customer_id       (api_customer_id),
    INDEX idx_api_address_id        (api_address_id),
    INDEX idx_weather_stations_id   (weather_stations_id),
    INDEX idx_qb_sales_receipt_id   (qb_sales_receipt_id),
    UNIQUE INDEX unidx_api_customer_id_qb_sales_receipt_id (api_customer_id, qb_sales_receipt_id)
    ) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

CREATE TABLE prediq_dw_development.f_sales_total(
    id                          INT(11)                 NOT NULL AUTO_INCREMENT PRIMARY KEY,
    -- keys
    transaction_date            DATE                    NOT NULL,
    api_customer_id             INT(11)                 NOT NULL,
    api_address_id              INT(11)                 NOT NULL,   -- how to get this???
    weather_stations_id         INT(11)                 NOT NULL DEFAULT 0, -- "real" value to be filled in later from d_weather_station by getting the closest weather station
    -- attributes
    sales_total                 DECIMAL(10,2)           NOT NULL,
    created_at 	                TIMESTAMP 	            NOT NULL DEFAULT now(),
    INDEX idx_transaction_date              (transaction_date),
    INDEX idx_api_customer_id               (api_customer_id),
    INDEX idx_api_address_id                (api_address_id),
    INDEX idx_weather_stations_id           (weather_stations_id),
    UNIQUE INDEX unidx_date_cust_addr_weath (transaction_date, api_customer_id, api_address_id, weather_stations_id)
    ) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;