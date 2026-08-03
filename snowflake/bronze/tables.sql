-- create database;
use role accountadmin; 
CREATE DATABASE IF NOT EXISTS bookstores;
USE DATABASE bookstores;

use role bookstore_engineer; 

CREATE SCHEMA IF NOT EXISTS bronze;
USE SCHEMA bronze;


CREATE TABLE IF NOT EXISTS customers (
    customer_id          VARCHAR(100),
    customer_name        VARCHAR(255),
    email                VARCHAR(255),
    phone                VARCHAR(50),
    birth_date           VARCHAR(100),
    city                 VARCHAR(100),
    country              VARCHAR(100),
    created_at           VARCHAR(100),
    updated_at           VARCHAR(100),

    _source_filename     VARCHAR(500),
    _source_row_number   NUMBER,
    _batch_id            VARCHAR(100),
    _loaded_at           TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE IF NOT EXISTS stores (
    store_id             VARCHAR(100),
    store_name           VARCHAR(255),
    store_type           VARCHAR(50),
    city                 VARCHAR(100),
    opened_at            VARCHAR(100),

    _source_filename     VARCHAR(500),
    _source_row_number   NUMBER,
    _batch_id            VARCHAR(100),
    _loaded_at           TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE IF NOT EXISTS publishers (
    publisher_id         VARCHAR(100),
    publisher_name       VARCHAR(255),
    country              VARCHAR(100),
    created_at           VARCHAR(100),
    updated_at           VARCHAR(100),

    _source_filename     VARCHAR(500),
    _source_row_number   NUMBER,
    _batch_id            VARCHAR(100),
    _loaded_at           TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE IF NOT EXISTS authors (
    author_id            VARCHAR(100),
    author_name          VARCHAR(255),
    country              VARCHAR(100),
    created_at           VARCHAR(100),
    updated_at           VARCHAR(100),

    _source_filename     VARCHAR(500),
    _source_row_number   NUMBER,
    _batch_id            VARCHAR(100),
    _loaded_at           TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE IF NOT EXISTS categories (
    category_id          VARCHAR(100),
    parent_category_id   VARCHAR(100),
    category_name        VARCHAR(255),
    created_at           VARCHAR(100),
    updated_at           VARCHAR(100),

    _source_filename     VARCHAR(500),
    _source_row_number   NUMBER,
    _batch_id            VARCHAR(100),
    _loaded_at           TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE IF NOT EXISTS promotions (
    promotion_id         VARCHAR(100),
    promotion_name       VARCHAR(255),
    discount_type        VARCHAR(50),
    discount_value       VARCHAR(100),
    starts_at            VARCHAR(100),
    ends_at              VARCHAR(100),
    created_at           VARCHAR(100),
    updated_at           VARCHAR(100),

    _source_filename     VARCHAR(500),
    _source_row_number   NUMBER,
    _batch_id            VARCHAR(100),
    _loaded_at           TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE IF NOT EXISTS staff (
    staff_id             VARCHAR(100),
    store_id             VARCHAR(100),
    manager_staff_id     VARCHAR(100),
    staff_code           VARCHAR(50),
    first_name           VARCHAR(100),
    last_name            VARCHAR(100),
    email                VARCHAR(255),
    phone                VARCHAR(50),
    job_title            VARCHAR(100),
    employment_status    VARCHAR(50),
    hire_date            VARCHAR(100),
    termination_date     VARCHAR(100),
    created_at           VARCHAR(100),
    updated_at           VARCHAR(100),

    _source_filename     VARCHAR(500),
    _source_row_number   NUMBER,
    _batch_id            VARCHAR(100),
    _loaded_at           TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
);


CREATE TABLE IF NOT EXISTS books (
    book_id              VARCHAR(100),
    publisher_id         VARCHAR(100),
    isbn                 VARCHAR(50),
    title                VARCHAR(500),
    language             VARCHAR(50),
    publication_year     VARCHAR(100),
    list_price           VARCHAR(100),
    cost_price           VARCHAR(100),
    created_at           VARCHAR(100),
    updated_at           VARCHAR(100),

    _source_filename     VARCHAR(500),
    _source_row_number   NUMBER,
    _batch_id            VARCHAR(100),
    _loaded_at           TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
);


CREATE TABLE IF NOT EXISTS book_authors (
    book_id              VARCHAR(100),
    author_id            VARCHAR(100),

    _source_filename     VARCHAR(500),
    _source_row_number   NUMBER,
    _batch_id            VARCHAR(100),
    _loaded_at           TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE IF NOT EXISTS book_categories (
    book_id              VARCHAR(100),
    category_id          VARCHAR(100),

    _source_filename     VARCHAR(500),
    _source_row_number   NUMBER,
    _batch_id            VARCHAR(100),
    _loaded_at           TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
);


CREATE TABLE IF NOT EXISTS orders (
    order_id             VARCHAR(100),
    customer_id          VARCHAR(100),
    store_id             VARCHAR(100),
    staff_id             VARCHAR(100),
    sales_channel        VARCHAR(50),
    order_status         VARCHAR(50),
    payment_method       VARCHAR(50),
    ordered_at           VARCHAR(100),
    updated_at           VARCHAR(100),

    _source_filename     VARCHAR(500),
    _source_row_number   NUMBER,
    _batch_id            VARCHAR(100),
    _loaded_at           TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE IF NOT EXISTS order_items (
    order_item_id        VARCHAR(100),
    order_id             VARCHAR(100),
    book_id              VARCHAR(100),
    promotion_id         VARCHAR(100),
    quantity             VARCHAR(100),
    unit_price           VARCHAR(100),
    discount_amount      VARCHAR(100),

    _source_filename     VARCHAR(500),
    _source_row_number   NUMBER,
    _batch_id            VARCHAR(100),
    _loaded_at           TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE IF NOT EXISTS inventory (
    store_id             VARCHAR(100),
    book_id              VARCHAR(100),
    quantity_on_hand     VARCHAR(100),
    reorder_level        VARCHAR(100),
    updated_at           VARCHAR(100),

    _source_filename     VARCHAR(500),
    _source_row_number   NUMBER,
    _batch_id            VARCHAR(100),
    _loaded_at           TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
);


SHOW TABLES IN SCHEMA bookstores.bronze;

