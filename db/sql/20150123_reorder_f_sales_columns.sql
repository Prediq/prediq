-- 20150123_reorder_f_sales_columns.sql


ALTER TABLE prediq_rdev_development.F_SALES CHANGE COLUMN TRANSACTION_DATE TRANSACTION_DATE DATE NOT NULL AFTER PRIMKEY;
