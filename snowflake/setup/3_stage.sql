-- setup before loading 
USE ROLE bookstore_engineer;
USE WAREHOUSE bookstore_wh;
USE DATABASE bookstores;
USE SCHEMA bronze;

-- create file format 
CREATE OR REPLACE FILE FORMAT csv_format
    TYPE = CSV
    FIELD_DELIMITER = ','
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    EMPTY_FIELD_AS_NULL = FALSE
    TRIM_SPACE = FALSE
    ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE;

-- create stage 
CREATE OR REPLACE STAGE books_stage
    URL = 's3://your-bucket-name/'
    STORAGE_INTEGRATION = bookstore_s3_int
    FILE_FORMAT = csv_format;

-- check stage
LIST @books_stage;

