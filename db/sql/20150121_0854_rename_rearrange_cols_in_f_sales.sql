-- 20150121_rename_rearrange_cols_in_f_sales.sql

ALTER TABLE prediq_rdev_development.F_SALES CHANGE COLUMN address_id API_ADDRESS_ID     INT(11)         NOT NULL;  -- OK
ALTER TABLE prediq_rdev_development.F_SALES CHANGE COLUMN CUSTOMER_ID API_CUSTOMER_ID   INT(11)         NOT NULL;  -- OK
ALTER TABLE prediq_rdev_development.F_SALES CHANGE COLUMN SALES SALES_TOTAL             DECIMAL(10, 2)  NOT NULL AFTER TRANSACTION_DATE; -- OK


-- Field 	Type 	Allow Null 	Default Value
-- PRIMKEY 	int(11) 	No
-- API_CUSTOMER_ID 	int(11) 	No
-- API_ADDRESS_ID 	int(11) 	No
-- TRANSACTION_DATE 	date 	Yes
-- SALES_TOTAL 	decimal(10,2) 	No
