-- table created 01/09/2015
CREATE TABLE prediq_api_import_development.address_info_imports (

  id                        int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  api_customer_id           int(11) NOT NULL,
  qb_company_info_id        int(11) NOT NULL,
  qb_company_address_id     int(11) NOT NULL,
  line1                     int(11)     NULL,
  line2                     int(11)     NULL,
  line3                     int(11)     NULL,
  line4                     int(11)     NULL,
  line5                     int(11)     NULL,
  city                      varchar(255) NULL,
  country                   varchar(255) NULL,
  country_sub_division_code varchar(255) NULL,
  postal_code               varchar(255) NULL,
  lat                       decimal(10,7) NULL,
  lon                       decimal(10,7) NULL );

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
