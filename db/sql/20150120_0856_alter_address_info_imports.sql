-- 20150120_0856_alter_address_info_imports.sql

ALTER TABLE prediq_api_import_development.address_info_imports CHANGE line1 address_line_1 varchar(255);
ALTER TABLE prediq_api_import_development.address_info_imports CHANGE line2 address_line_2 varchar(255);
ALTER TABLE prediq_api_import_development.address_info_imports CHANGE line3 address_line_3 varchar(255);
ALTER TABLE prediq_api_import_development.address_info_imports CHANGE line4 address_line_4 varchar(255);
ALTER TABLE prediq_api_import_development.address_info_imports CHANGE line5 address_line_5 varchar(255);