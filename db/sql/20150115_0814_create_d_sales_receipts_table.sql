-- 20150115_0814_create_d_sales_receipts_table.sql

CREATE TABLE prediq_rdev_development.D_SALES_RECEIPTS(
    ID                          int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    -- keys
    DATE_KEY                    date                    NOT NULL,  -- ie 2015-01-16
    API_CUSTOMER_ID_KEY         INT(11)                 NOT NULL,
    API_ADDRESS_ID_KEY          INT(11)                 NOT NULL,   -- how to get this???
-- attributes
    QB_SALES_RECEIPT_ID         INT(11)                 NOT NULL,   -- the Quickbooks sales receipt id
    SYNC_TOKEN  	            INT(11)                 NOT NULL,
    TRANSACTION_DATE 	        DATETIME 	            NOT NULL,
    META_DATA_CREATE_TIME 	    DATETIME 	            NOT NULL,
    META_DATA_LAST_UPDATED_TIME DATETIME                NOT NULL,
    SALES_RECEIPT_TOTAL 	    DECIMAL(10,2) 	        NOT NULL,
    -- bill_address items
    BILL_ADDRESS_ID 	        INT(11) 	            NOT NULL,   -- the Quickbooks bill_address id "bill_address"=>{"id"=>66, ...}
    BILL_ADDRESS_LINE_1 	    VARCHAR(255) 	        NOT NULL,
    BILL_ADDRESS_LINE_2 	    VARCHAR(255) 	            NULL,
    BILL_ADDRESS_LINE_3 	    VARCHAR(255) 	            NULL,
    BILL_ADDRESS_LINE_4 	    VARCHAR(255) 	            NULL,
    BILL_ADDRESS_LINE_5 	    VARCHAR(255) 	            NULL,
    BILL_ADDRESS_CITY 	        VARCHAR(255) 	            NULL,
    BILL_ADDRESS_COUNTRY_SUB_DIVISION_CODE 	VARCHAR(255) 	NULL,
    BILL_ADDRESS_POSTAL_CODE 	VARCHAR(255) 	            NULL,
    BILL_ADDRESS_LAT 	        DECIMAL(10,7) 	            NULL,
    BILL_ADDRESS_LON 	        DECIMAL(10,7) 	            NULL,
    BILL_EMAIL_ADDRESS 	        VARCHAR(255) 	            NULL,
    -- shipping items
    SHIP_ADDRESS_ID 	        INT(11) 	                NULL,
    SHIP_ADDRESS_LINE_1 	    VARCHAR(255) 	            NULL,
    SHIP_ADDRESS_LINE_2 	    VARCHAR(255) 	            NULL,
    SHIP_ADDRESS_LINE_3 	    VARCHAR(255) 	            NULL,
    SHIP_ADDRESS_LINE_4 	    VARCHAR(255) 	            NULL,
    SHIP_ADDRESS_LINE_5 	    VARCHAR(255) 	            NULL,
    SHIP_ADDRESS_CITY 	        VARCHAR(255) 	            NULL,
    SHIP_ADDRESS_COUNTRY_SUB_DIVISION_CODE 	VARCHAR(255) 	NULL,
    SHIP_ADDRESS_POSTAL_CODE 	VARCHAR(255) 	            NULL,
    SHIP_ADDRESS_LAT 	        DECIMAL(10,7) 	            NULL,
    SHIP_ADDRESS_LON 	        DECIMAL(10,7) 	            NULL,
    SHIP_METHOD_REF_NAME 	    VARCHAR(255) 	            NULL,
    SHIP_METHOD_REF_VALUE 	    INT(11) 	                NULL,
    SHIP_METHOD_REF_TYPE 	    VARCHAR(255) 	            NULL,
    SHIP_DATE 	                TIMESTAMP 	                NULL,
    -- Quickbooks ref_type's
    DEPARTMENT_REF_NAME 	    VARCHAR(255) 	            NULL,
    DEPARTMENT_REF_VALUE 	    INT(11) 	                NULL,
    DEPARTMENT_REF_TYPE 	    VARCHAR(255) 	            NULL,
    PAYMENT_METHOD_REF_NAME 	VARCHAR(255) 	            NULL,
    PAYMENT_METHOD_REF_VALUE 	INT(11) 	                NULL,
    PAYMENT_METHOD_REF_TYPE 	VARCHAR(255) 	            NULL,
    CUSTOMER_REF_NAME 	        VARCHAR(255) 	            NULL,
    CUSTOMER_REF_VALUE 	        INT(11) 	                NULL,
    CUSTOMER_REF_TYPE 	        VARCHAR(255) 	            NULL,
    -- various
    BALANCE 	                DECIMAL(10,2) 	            NULL,
    PAYMENT_TYPE 	            VARCHAR(255) 	            NULL,
    CURRENCY_REF 	            TINYINT(1) 	                NULL,
    EXCHANGE_RATE 	            DECIMAL(6,2) 	            NULL,
    GLOBAL_TAX_CALCULATION 	    VARCHAR(255) 	            NULL,
    HOME_TOTAL_AMOUNT 	        DECIMAL(10,2) 	            NULL,
    APPLY_AFTER_TAX_DISCOUNT 	TINYINT(1) 	                NULL,
    CUSTOMER_MEMO 	            VARCHAR(1024) 	            NULL,
    PRIVATE_NOTE 	            VARCHAR(4096) 	            NULL,
    LINKED_TRANSACTION_ID 	    VARCHAR(255) 	            NULL,
    TXN_TAX_CODE_REF 	        VARCHAR(255) 	            NULL,
    TOTAL_TAX 	                DECIMAL(10,4) 	            NULL,
    CREATED_AT 	                TIMESTAMP 	            NOT NULL DEFAULT now(),
    INDEX IDX_DATE_KEY              (DATE_KEY),
    INDEX IDX_API_CUSTOMER_ID       (API_CUSTOMER_ID),
    INDEX IDX_API_ADDRESS_ID        (API_ADDRESS_ID),
    INDEX IDX_QB_SALES_RECEIPT_ID   (QB_SALES_RECEIPT_ID),
    UNIQUE INDEX UNIDX_API_CUSTOMER_ID_QB_SALES_RECEIPT_ID (API_CUSTOMER_ID, QB_SALES_RECEIPT_ID)
    ) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

