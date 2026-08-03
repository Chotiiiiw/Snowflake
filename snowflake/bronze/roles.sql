-- start 
USE ROLE ACCOUNTADMIN;

-- Project role
CREATE ROLE IF NOT EXISTS bookstore_engineer;

-- Add role to the standard Snowflake hierarchy
GRANT ROLE bookstore_engineer TO ROLE SYSADMIN;

-- Replace with the Snowflake username running the project
GRANT ROLE bookstore_engineer TO USER your_snowflake_username;

-- Shared compute provisioned by an administrator
CREATE WAREHOUSE IF NOT EXISTS bookstore_wh
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;

-- Database container provisioned by an administrator
CREATE DATABASE IF NOT EXISTS bookstores;

--bookstore_engineer role can use compute
GRANT USAGE, OPERATE
ON WAREHOUSE bookstore_wh
TO ROLE bookstore_engineer;

-- bookstore_engineer role can enter the database and create project schemas
GRANT USAGE
ON DATABASE bookstores
TO ROLE bookstore_engineer;


-- Storage Integration must be created by ACCOUNTADMIN.
-- Replace the ARN with the IAM Role ARN, not an IAM User ARN.
CREATE STORAGE INTEGRATION IF NOT EXISTS bookstore_s3_int
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = 'S3'
    ENABLED = TRUE
    STORAGE_AWS_ROLE_ARN =
        'arn:aws:iam::<your_aws_account>:role/snowflake_books_s3_role'
    STORAGE_ALLOWED_LOCATIONS = (
        's3://your-bucket-name/'
    );

GRANT USAGE
ON INTEGRATION bookstore_s3_int
TO ROLE bookstore_engineer;

GRANT USAGE
ON DATABASE bookstores
TO ROLE bookstore_engineer;

GRANT CREATE SCHEMA
ON DATABASE bookstores
TO ROLE bookstore_engineer;

GRANT USAGE
ON ALL SCHEMAS IN DATABASE bookstores
TO ROLE bookstore_engineer;

GRANT USAGE
ON FUTURE SCHEMAS IN DATABASE bookstores
TO ROLE bookstore_engineer;

GRANT SELECT, INSERT, UPDATE, DELETE 
ON ALL TABLES IN DATABASE bookstores 
TO ROLE bookstore_engineer;

GRANT SELECT, INSERT, UPDATE, DELETE 
ON FUTURE TABLES IN DATABASE bookstores 
TO ROLE bookstore_engineer;


-- Verify
SHOW GRANTS TO ROLE bookstore_engineer;
DESC INTEGRATION bookstore_s3_int;
