{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='order_id',
    on_schema_change='fail'
) }}

with source as (
    select * from {{ source('bronze', 'orders') }}
    {% if is_incremental() %}
        where _loaded_at > (
            select coalesce(
                max(_loaded_at),
                '1900-01-01'::timestamp_ltz
            )
            from {{ this }}
        )
    {% endif %}
),

cleaned as (
    select
        try_cast(
            nullif(trim(order_id), '') as bigint
        ) as order_id,
        try_cast(
            nullif(trim(customer_id), '') as bigint
        ) as customer_id,
        try_cast(
            nullif(trim(store_id), '') as bigint
        ) as store_id,
        try_cast(
            nullif(trim(staff_id), '') as bigint
        ) as staff_id,
        cast(
            case 
                when trim(lower(sales_channel)) in ('website', 'web', 'online') then 'Website' 
                when trim(lower(sales_channel)) in ('store', 'in_store') then 'Store'
            end as varchar(50)
        ) as sales_channel,
        cast(
            case 
                when order_status is null then null
                when trim(lower(order_status)) in ('complete', 'completed') then 'Completed'
                else initcap(trim(lower(order_status))) end as varchar(50)
        ) as order_status,
        cast(
            case
                when payment_method is null then null 
                when trim(lower(payment_method)) in ('credit_card', 'credit card') then 'credit_card'
                else trim(lower(payment_method)) 
            end as varchar(50)
        ) as payment_method,
        try_cast(
            nullif(trim(ordered_at), '') as timestamp_ntz
        ) as ordered_at,
        try_cast(
            nullif(trim(updated_at), '') as timestamp_ntz
        ) as updated_at,
        cast(_source_filename as varchar(500))
            as _source_filename,
        cast(_source_row_number as number(38, 0))
            as _source_row_number,
        cast(_batch_id as varchar(100))
            as _batch_id,
        cast(_loaded_at as timestamp_ltz)
            as _loaded_at
    from source

),

deduplicated as (
    select * from cleaned
    qualify row_number() over (
        partition by order_id
        order by
            updated_at desc nulls last,
            _loaded_at desc,
            _source_row_number desc
    ) = 1
)

select * from deduplicated