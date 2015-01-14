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

 Date: 01/14/2015 10:04:05 AM
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

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
  `country_sub_division_code` varchar(32) DEFAULT NULL,
  `postcode` varchar(10) NOT NULL,
  `country_id` int(11) NOT NULL DEFAULT '0',
  `zone_id` int(11) NOT NULL DEFAULT '0',
  `weather_station_id` int(11) NOT NULL,
  `weather_station_code` varchar(16) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `distance_to_weather_station` float(16,8) NOT NULL,
  `lat` double(9,6) NOT NULL,
  `lon` double(9,6) NOT NULL,
  `primary_address` tinyint(1) NOT NULL COMMENT 'Determines if this is the primary address for the user.',
  `active` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`address_id`),
  KEY `customer_id` (`customer_id`),
  KEY `primary_address` (`primary_address`),
  CONSTRAINT `fk_add_cust` FOREIGN KEY (`customer_id`) REFERENCES `api_customer` (`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;

-- ----------------------------
--  Records of `api_address`
-- ----------------------------
BEGIN;
INSERT INTO `api_address` VALUES ('1', '1', '0', 'Boise', 'Restaurant', '', '', '', '246 N 8th St', '', 'Boise', null, '83702', '223', '3634', '186', 'KBOI', '6103.16308594', '43.617164', '-116.202027', '1', null), ('2', '2', '0', 'Indianapolis', 'Fast-Food', '', '', '', '719 Massachusetts Ave', '', 'Indianapolis', null, '46204', '223', '3636', '453', 'KEYE', '15288.00292969', '39.790928', '-86.122407', '1', null), ('3', '3', '0', 'Denver', 'Golf', '', '', '', '2156 Red Hawk Ridge Dr', '', 'Castle Rock', null, '80109', '223', '3625', '86', 'KAPA', '20397.34375000', '39.389092', '-104.887857', '1', null), ('4', '4', '0', 'Shawnee', 'Hardware', '', '', '', '603 E Independence St', '', 'Shawnee', null, '74804', '223', '3660', '294', 'KCQB', '42320.23828125', '35.347175', '-96.887677', '1', null), ('5', '5', '0', 'Houston', 'Golf', '', '', '', '12000 Almeda Rd', '', 'Houston', null, '77045', '223', '3669', '803', 'KLVJ', '13707.04785156', '29.619034', '-95.417436', '1', null), ('6', '6', '0', 'Salt Lake City', 'Restaurant', '', '', '', '111 E Broadway # 170', '', 'Salt Lake City', null, '84111', '223', '3670', '1253', 'KSLC', '2816.96630859', '34.057147', '-118.242247', '1', null), ('7', '7', '0', 'Detroit', 'Auto-Parts', '', '', '', '14201 Schaefer Hwy', '', 'Detroit', null, '48227', '223', '3645', '382', 'KDTW', '14681.50292969', '42.363587', '-83.177653', '1', null), ('8', '8', '0', 'Lubbock', 'Auto-Parts', '', '', '', '2126 19th St', '', 'Lubbock', null, '79401', '223', '3669', '752', 'KLBB', '9944.64843750', '33.577815', '-101.853167', '1', null);
COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
