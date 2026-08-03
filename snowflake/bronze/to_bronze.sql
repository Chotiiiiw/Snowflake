-- setup before loading 
USE ROLE bookstore_engineer;
USE WAREHOUSE compute_wh;
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

-- create batch_id
SET batch_id = (select UUID_STRING());
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
    FROM @books_stage/stores.csv t
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
    FROM @books_stage/staff.csv t
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
    FROM @books_stage/customers.csv t
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
    FROM @books_stage/publishers.csv t
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
    FROM @books_stage/authors.csv t
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
    FROM @books_stage/categories.csv t
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
    FROM @books_stage/promotions.csv t
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
    FROM @books_stage/books.csv t
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
    FROM @books_stage/book_authors.csv t
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
    FROM @books_stage/book_categories.csv t
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
    FROM @books_stage/orders.csv t
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
    FROM @books_stage/order_items.csv t
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
    FROM @books_stage/inventory.csv t
)
ON_ERROR = 'ABORT_STATEMENT';


-- check 
SELECT 'stores' AS table_name, COUNT(*) AS row_count FROM stores
UNION ALL
SELECT 'staff', COUNT(*) FROM staff
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'publishers', COUNT(*) FROM publishers
UNION ALL
SELECT 'authors', COUNT(*) FROM authors
UNION ALL
SELECT 'categories', COUNT(*) FROM categories
UNION ALL
SELECT 'promotions', COUNT(*) FROM promotions
UNION ALL
SELECT 'books', COUNT(*) FROM books
UNION ALL
SELECT 'book_authors', COUNT(*) FROM book_authors
UNION ALL
SELECT 'book_categories', COUNT(*) FROM book_categories
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'inventory', COUNT(*) FROM inventory
ORDER BY table_name;

--check for books table 
SELECT
    _source_filename,
    _batch_id,
    COUNT(*) AS rowss,
    MIN(_loaded_at) AS loaded_at
FROM books
GROUP BY
    _source_filename,
    _batch_id;
