-- setup before loading 
USE ROLE bookstore_engineer;
USE WAREHOUSE bookstore_wh;
USE DATABASE bookstores;
USE SCHEMA bronze;

-- Use the end of Airflow's daily data interval as the S3 partition date.
{% set load_date = data_interval_end.in_timezone("Asia/Bangkok").format("YYYY-MM-DD") %}

-- Keep one stable batch ID across retries of the same Airflow DAG run.
SET batch_id = '{{ run_id }}';
-- check 
SELECT $batch_id;


-- copy from s3 -> stage -> bronze(scheama)

COPY INTO stores
FROM (
    SELECT
        t.$1,
        t.$2,
        t.$3,
        t.$4,
        t.$5,
        METADATA$FILENAME,
        METADATA$FILE_ROW_NUMBER,
        $batch_id,
        CURRENT_TIMESTAMP()
    FROM @books_stage/load_date={{ load_date }}/stores.csv t
)
ON_ERROR = 'ABORT_STATEMENT';

COPY INTO staff 
FROM (
    SELECT
        t.$1,
        t.$2,
        t.$3,
        t.$4,
        t.$5,
        t.$6,
        t.$7,
        t.$8,
        t.$9,
        t.$10,
        t.$11,
        t.$12,
        t.$13,
        t.$14,
        METADATA$FILENAME,
        METADATA$FILE_ROW_NUMBER,
        $batch_id,
        CURRENT_TIMESTAMP()
    FROM @books_stage/load_date={{ load_date }}/staff.csv t
)
ON_ERROR = 'ABORT_STATEMENT';

COPY INTO customers
FROM (
    SELECT
        t.$1,
        t.$2,
        t.$3,
        t.$4,
        t.$5,
        t.$6,
        t.$7,
        t.$8,
        t.$9,
        METADATA$FILENAME,
        METADATA$FILE_ROW_NUMBER,
        $batch_id,
        CURRENT_TIMESTAMP()
    FROM @books_stage/load_date={{ load_date }}/customers.csv t
)
ON_ERROR = 'ABORT_STATEMENT';

COPY INTO publishers 
FROM (
    SELECT
        t.$1,
        t.$2,
        t.$3,
        t.$4,
        t.$5,
        METADATA$FILENAME,
        METADATA$FILE_ROW_NUMBER,
        $batch_id,
        CURRENT_TIMESTAMP()
    FROM @books_stage/load_date={{ load_date }}/publishers.csv t
)
ON_ERROR = 'ABORT_STATEMENT';

COPY INTO authors
FROM (
    SELECT
        t.$1,
        t.$2,
        t.$3,
        t.$4,
        t.$5,
        METADATA$FILENAME,
        METADATA$FILE_ROW_NUMBER,
        $batch_id,
        CURRENT_TIMESTAMP()
    FROM @books_stage/load_date={{ load_date }}/authors.csv t
)
ON_ERROR = 'ABORT_STATEMENT';

COPY INTO categories 
FROM (
    SELECT
        t.$1,
        t.$2,
        t.$3,
        t.$4,
        t.$5,
        METADATA$FILENAME,
        METADATA$FILE_ROW_NUMBER,
        $batch_id,
        CURRENT_TIMESTAMP()
    FROM @books_stage/load_date={{ load_date }}/categories.csv t
)
ON_ERROR = 'ABORT_STATEMENT';

COPY INTO promotions
FROM (
    SELECT
        t.$1,
        t.$2,
        t.$3,
        t.$4,
        t.$5,
        t.$6,
        t.$7,
        t.$8,
        METADATA$FILENAME,
        METADATA$FILE_ROW_NUMBER,
        $batch_id,
        CURRENT_TIMESTAMP()
    FROM @books_stage/load_date={{ load_date }}/promotions.csv t
)
ON_ERROR = 'ABORT_STATEMENT';

COPY INTO books
FROM (
    SELECT
        t.$1,
        t.$2,
        t.$3,
        t.$4,
        t.$5,
        t.$6,
        t.$7,
        t.$8,
        t.$9,
        t.$10,
        METADATA$FILENAME,
        METADATA$FILE_ROW_NUMBER,
        $batch_id,
        CURRENT_TIMESTAMP()
    FROM @books_stage/load_date={{ load_date }}/books.csv t
)
ON_ERROR = 'ABORT_STATEMENT';

COPY INTO book_authors
FROM (
    SELECT
        t.$1,
        t.$2,
        METADATA$FILENAME,
        METADATA$FILE_ROW_NUMBER,
        $batch_id,
        CURRENT_TIMESTAMP()
    FROM @books_stage/load_date={{ load_date }}/book_authors.csv t
)
ON_ERROR = 'ABORT_STATEMENT';

COPY INTO book_categories 
FROM (
    SELECT
        t.$1,
        t.$2,
        METADATA$FILENAME,
        METADATA$FILE_ROW_NUMBER,
        $batch_id,
        CURRENT_TIMESTAMP()
    FROM @books_stage/load_date={{ load_date }}/book_categories.csv t
)
ON_ERROR = 'ABORT_STATEMENT';

COPY INTO orders
FROM (
    SELECT
        t.$1,
        t.$2,
        t.$3,
        t.$4,
        t.$5,
        t.$6,
        t.$7,
        t.$8,
        t.$9,
        METADATA$FILENAME,
        METADATA$FILE_ROW_NUMBER,
        $batch_id,
        CURRENT_TIMESTAMP()
    FROM @books_stage/load_date={{ load_date }}/orders.csv t
)
ON_ERROR = 'ABORT_STATEMENT';

COPY INTO order_items
FROM (
    SELECT
        t.$1,
        t.$2,
        t.$3,
        t.$4,
        t.$5,
        t.$6,
        t.$7,
        METADATA$FILENAME,
        METADATA$FILE_ROW_NUMBER,
        $batch_id,
        CURRENT_TIMESTAMP()
    FROM @books_stage/load_date={{ load_date }}/order_items.csv t
)
ON_ERROR = 'ABORT_STATEMENT';

COPY INTO inventory 
FROM (
    SELECT
        t.$1,
        t.$2,
        t.$3,
        t.$4,
        t.$5,
        METADATA$FILENAME,
        METADATA$FILE_ROW_NUMBER,
        $batch_id,
        CURRENT_TIMESTAMP()
    FROM @books_stage/load_date={{ load_date }}/inventory.csv t
)

ON_ERROR = 'ABORT_STATEMENT';
