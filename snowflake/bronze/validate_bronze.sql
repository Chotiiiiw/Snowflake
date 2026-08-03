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