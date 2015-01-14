/*
 Navicat Premium Data Transfer

 Source Server         : mySQL_local
 Source Server Type    : MySQL
 Source Server Version : 50617
 Source Host           : localhost
 Source Database       : prediq_api_development

 Target Server Type    : MySQL
 Target Server Version : 50617
 File Encoding         : utf-8

 Date: 01/14/2015 09:42:53 AM
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Records of `api_address`
-- ----------------------------
BEGIN;
INSERT INTO prediq_api_development.api_address(
  address_id,
  customer_id,
  qb_company_address_id,
  firstname,
  lastname,
  company,
  company_id,
  tax_id,
  address_1,
  address_2,
  city,
  country_sub_division_code,
  postcode,
  country_id,
  zone_id,
  weather_station_id,
  weather_station_code,
  distance_to_weather_station,
  lat,
  lon,
  primary_address,
  active
)
VALUES (
  '9',                    -- address_id,
  '9',                    -- customer_id,
  '1',                    -- qb_company_address_id,
  'Bill',                 -- firstname,
  'Kiskin',               -- lastname,
  'Billy''s Heli Shop',   -- company,
  '',                     -- company_id,
  '',                     -- tax_id,
  '9666 Whitehurst Dr',   -- address_1,
  '',                     -- address_2,
  'Dallas',               -- city,
  'TX',                   -- country_sub_division_code,
  '75243',                -- postcode,
  '223',                  -- country_id,
  '3634',                 -- zone_id,
  '186',                  -- weather_station_id,
  'KBOI',                 -- weather_station_code,
  '6103.16308594',        -- distance_to_weather_station,
  '43.617164',            -- lat,
  '-116.202027',          -- lon,
  '1',                    -- primary_address,
  true                    -- active

);

COMMIT;

SET FOREIGN_KEY_CHECKS = 1;

/*

-- ----------------------------
--  Table structure for `api_address`
-- ----------------------------
DROP TABLE IF EXISTS `api_address`;
CREATE TABLE `api_address` (
  `address_id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) NOT NULL,
  `qb_company_address_id` int(11) NOT NULL,
  `firstname` varchar(32) NOT NULL,
  `lastname` varchar(32) NOT NULL,
  `company` varchar(32) NOT NULL,
  `company_id` varchar(32) NOT NULL,
  `tax_id` varchar(32) NOT NULL,
  `address_1` varchar(128) NOT NULL,
  `address_2` varchar(128) NOT NULL,
  `city` varchar(128) NOT NULL,
  `postcode` varchar(10) NOT NULL,
  `country_id` int(11) NOT NULL DEFAULT '0',
  `zone_id` int(11) NOT NULL DEFAULT '0',
  `weather_station_id` int(11) NOT NULL,
  `weather_station_code` varchar(16) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `distance_to_weather_station` float(16,8) NOT NULL,
  `lat` double(9,6) NOT NULL,
  `lon` double(9,6) NOT NULL,
  `primary_address` tinyint(1) NOT NULL COMMENT 'Determines if this is the primary address for the user.',
  PRIMARY KEY (`address_id`),
  KEY `customer_id` (`customer_id`),
  KEY `primary_address` (`primary_address`),
  CONSTRAINT `fk_add_cust` FOREIGN KEY (`customer_id`) REFERENCES `api_customer` (`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;


 */
