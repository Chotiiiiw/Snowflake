## Setup order
1. Run `snowflake/bronze/roles.sql` in Snowflake as a user that can use `ACCOUNTADMIN`.
2. At the end of that script, `DESC INTEGRATION bookstore_s3_int` returns `STORAGE_AWS_IAM_USER_ARN` and `STORAGE_AWS_EXTERNAL_ID`.
3. In AWS IAM, set up IAM. (I'll change this later.)
6. Run the remaining files in this order:
   1. `snowflake/bronze/tables.sql`
   2. `snowflake/bronze/to_bronze.sql`
   3. `snowflake/bronze/validate_bronze.sql`
