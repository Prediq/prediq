
ALTER TABLE prediq_api_development.api_address ADD COLUMN country_sub_division_code varchar(32) NULL AFTER city;
ALTER TABLE prediq_api_development.api_address ADD COLUMN active BOOLEAN NULL AFTER primary_address;
-- ALTER TABLE prediq_apt.api_address ADD COLUMN country_sub_division_code varchar(32) NULL AFTER postcode;