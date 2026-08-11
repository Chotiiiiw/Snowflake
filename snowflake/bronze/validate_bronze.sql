WITH table_counts AS (
    SELECT 'stores' AS table_name, COUNT(*) AS row_count
    FROM bookstores.bronze.stores

    UNION ALL
    SELECT 'staff', COUNT(*) FROM bookstores.bronze.staff

    UNION ALL
    SELECT 'customers', COUNT(*) FROM bookstores.bronze.customers

    UNION ALL
    SELECT 'publishers', COUNT(*) FROM bookstores.bronze.publishers

    UNION ALL
    SELECT 'authors', COUNT(*) FROM bookstores.bronze.authors

    UNION ALL
    SELECT 'categories', COUNT(*) FROM bookstores.bronze.categories

    UNION ALL
    SELECT 'promotions', COUNT(*) FROM bookstores.bronze.promotions

    UNION ALL
    SELECT 'books', COUNT(*) FROM bookstores.bronze.books

    UNION ALL
    SELECT 'book_authors', COUNT(*) FROM bookstores.bronze.book_authors

    UNION ALL
    SELECT 'book_categories', COUNT(*) FROM bookstores.bronze.book_categories

    UNION ALL
    SELECT 'orders', COUNT(*) FROM bookstores.bronze.orders

    UNION ALL
    SELECT 'order_items', COUNT(*) FROM bookstores.bronze.order_items

    UNION ALL
    SELECT 'inventory', COUNT(*) FROM bookstores.bronze.inventory
)

SELECT COUNT_IF(row_count = 0) = 0 AS all_tables_have_data
FROM table_counts;
