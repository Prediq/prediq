-- 20150204_0838_create_address_info_imports
-- DROP TABLE prediq_api_import_development.address_info_imports;

CREATE TABLE prediq_api_import_development.address_info_imports (

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
  INDEX idx_qb_company_address_id(qb_company_address_id)
) 
ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

--   `SALES` float DEFAULT NULL,
--   `TRANSACTION_DATE` date DEFAULT NULL,
--   `INSERT_DATE` date DEFAULT NULL,
--   PRIMARY KEY (`PRIMKEY`),
--   KEY `F_SALES_CUST` (`CUSTOMER_ID`),
--   KEY `F_SALES_DATE` (`TRANSACTION_DATE`),
--   KEY `address_id` (`address_id`)



/*
 "company_address"=>
  {"id"=>1,
   "line1"=>"123 Sierra Way",
   "line2"=>nil,
   "line3"=>nil,
   "line4"=>nil,
   "line5"=>nil,
   "city"=>"San Pablo",
   "country"=>nil,
   "country_sub_division_code"=>"CA",
   "postal_code"=>"87999",
   "note"=>nil,
   "lat"=>"36.6788345",
   "lon"=>"-5.4464622"},

*/
