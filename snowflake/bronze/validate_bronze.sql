WITH table_counts AS (
    SELECT 'stores' AS table_name, COUNT(*) AS row_count
    FROM bookstores.bronze.stores
    WHERE _batch_id = '{{ run_id }}'

    UNION ALL
    SELECT 'staff', COUNT(*) FROM bookstores.bronze.staff
    WHERE _batch_id = '{{ run_id }}'

    UNION ALL
    SELECT 'customers', COUNT(*) FROM bookstores.bronze.customers
    WHERE _batch_id = '{{ run_id }}'

    UNION ALL
    SELECT 'publishers', COUNT(*) FROM bookstores.bronze.publishers
    WHERE _batch_id = '{{ run_id }}'

    UNION ALL
    SELECT 'authors', COUNT(*) FROM bookstores.bronze.authors
    WHERE _batch_id = '{{ run_id }}'

    UNION ALL
    SELECT 'categories', COUNT(*) FROM bookstores.bronze.categories
    WHERE _batch_id = '{{ run_id }}'

    UNION ALL
    SELECT 'promotions', COUNT(*) FROM bookstores.bronze.promotions
    WHERE _batch_id = '{{ run_id }}'

    UNION ALL
    SELECT 'books', COUNT(*) FROM bookstores.bronze.books
    WHERE _batch_id = '{{ run_id }}'

    UNION ALL
    SELECT 'book_authors', COUNT(*) FROM bookstores.bronze.book_authors
    WHERE _batch_id = '{{ run_id }}'

    UNION ALL
    SELECT 'book_categories', COUNT(*) FROM bookstores.bronze.book_categories
    WHERE _batch_id = '{{ run_id }}'

    UNION ALL
    SELECT 'orders', COUNT(*) FROM bookstores.bronze.orders
    WHERE _batch_id = '{{ run_id }}'

    UNION ALL
    SELECT 'order_items', COUNT(*) FROM bookstores.bronze.order_items
    WHERE _batch_id = '{{ run_id }}'

    UNION ALL
    SELECT 'inventory', COUNT(*) FROM bookstores.bronze.inventory
    WHERE _batch_id = '{{ run_id }}'
)

SELECT COUNT_IF(row_count = 0) = 0 AS all_tables_loaded
FROM table_counts;
