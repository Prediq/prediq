-- columns added 01/09/2015
/*
    NOTE: We are adding this so that during the initial import process we can check, via 'qb_company_info_id',
    if the QB company_info is already in the api_customer table before we add it from the
    prediq_api_import_development.company_info_imports table
 */
ALTER TABLE prediq_api_development.api_customer ADD COLUMN qb_company_info_id INTEGER NOT NULL AFTER customer_id;

/*
    NOTE: We are adding this so that during the initial import process we can check, via 'qb_company_address_id',
    if the QB company_info is already in the api_address table before we add it from the
    prediq_api_import_development.company_info_imports table
 */
ALTER TABLE prediq_api_development.api_address ADD COLUMN qb_company_address_id INTEGER NOT NULL AFTER customer_id;

