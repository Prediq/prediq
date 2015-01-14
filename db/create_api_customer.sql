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

 Date: 01/14/2015 08:57:50 AM
*/
SET FOREIGN_KEY_CHECKS = 0;
SET NAMES utf8;
/*

-- ----------------------------
--  Table structure for `api_customer`
-- ----------------------------
DROP TABLE IF EXISTS `api_customer`;
CREATE TABLE `api_customer` (
  `customer_id` int(11) NOT NULL AUTO_INCREMENT,
  `qb_company_info_id` int(11) NOT NULL,
  `store_id` int(11) NOT NULL DEFAULT '0',
  `firstname` varchar(32) NOT NULL,
  `lastname` varchar(32) NOT NULL,
  `email` varchar(96) NOT NULL,
  `telephone` varchar(32) NOT NULL,
  `fax` varchar(32) NOT NULL,
  `encrypted_password` varchar(70) NOT NULL DEFAULT '',
  `salt` varchar(9) NOT NULL,
  `api_key` char(32) DEFAULT NULL,
  `newsletter` tinyint(1) NOT NULL DEFAULT '0',
  `customer_group_id` int(11) NOT NULL,
  `ip` varchar(40) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL,
  `approved` tinyint(1) NOT NULL,
  `token` varchar(255) NOT NULL,
  `date_added` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `reset_password_token` varchar(255) DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(11) NOT NULL DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) DEFAULT NULL,
  `last_sign_in_ip` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`customer_id`),
  UNIQUE KEY `index_api_customer_on_email` (`email`),
  UNIQUE KEY `api_key` (`api_key`),
  UNIQUE KEY `index_api_customer_on_reset_password_token` (`reset_password_token`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;
*/
-- ----------------------------
--  Records of `api_customer`
-- ----------------------------
BEGIN;
INSERT INTO prediq_api_development.api_customer(
  customer_id,
  qb_company_info_id,
  store_id,
  firstname,
  lastname,
  email,
  telephone,
  fax,
  encrypted_password,
  salt,
  api_key,
  newsletter,
  customer_group_id,
  ip,
  status,
  approved,
  token,
  date_added,
  reset_password_token,
  reset_password_sent_at,
  remember_created_at,
  sign_in_count,
  current_sign_in_at,
  last_sign_in_at,
  current_sign_in_ip,
  last_sign_in_ip,
  created_at,
  updated_at )
VALUES (
  '9',                                   -- customer_id,
  '0',                                   -- qb_company_info_id,
  '0',                                   -- store_id,
  'Bill',                                -- firstname,
  'Kiskin',                              -- lastname,
  'bill@prediq.com',                     -- email,
  '12345677889',                         -- telephone,
  '',                                    -- fax,
  '0cbc6611f5540bd0809a388dc95a615b',    -- encrypted_password,
  '0526ddb24',                           -- salt,
  'bbc042e2011fbf9b9fc10a96d2f9b7uc',    -- api_key,
  '1',                                   -- newsletter,
  '1',                                   -- customer_group_id,
  '70.116.134.54',                       -- ip,
  '1',                                   -- status,
  '1',                                   -- approved,
  '',                                    -- token,
  '2015-01-14 09:18:33',                 -- date_added,
  null,                                  -- reset_password_token,
  null,                                  -- reset_password_sent_at,
  null,                                  -- remember_created_at,
  '0',                                   -- sign_in_count,
  null,                                  -- current_sign_in_at,
   null,                                 -- last_sign_in_at,
   null,                                 -- current_sign_in_ip,
   null,                                 -- last_sign_in_ip,
  '2015-01-14 09:18:33',                 -- created_at,
  '2015-01-14 09:18:33');                -- updated_at )
COMMIT;

SET FOREIGN_KEY_CHECKS = 1;







