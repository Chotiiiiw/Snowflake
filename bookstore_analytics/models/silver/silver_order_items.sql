{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='order_item_id',
    on_schema_change='fail'
) }}

with source as (
    select * from {{ source('bronze', 'order_items') }}
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
            nullif(trim(order_item_id), '') as bigint
        ) as order_item_id,

        try_cast(
            nullif(trim(order_id), '') as bigint
        ) as order_id,

        try_cast(
            nullif(trim(book_id), '') as bigint
        ) as book_id,

        try_cast(
            nullif(trim(promotion_id), '') as bigint
        ) as promotion_id,

        try_cast(
            nullif(trim(quantity), '') as integer
        ) as quantity,
        try_cast(
            case
            when nullif(trim(unit_price), '') is null
                then null
            when lower(trim(unit_price)) = 'free'
                then '0.00'
            else trim(unit_price)
        end as decimal(12, 2)
        ) as unit_price,

        try_cast(
            nullif(trim(discount_amount), '') as decimal(12, 2)
        ) as discount_amount,

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
        partition by order_item_id
        order by
            _loaded_at desc,
            _source_row_number desc
    ) = 1
),
validated as (
    select
        d.*,

        case
            when d.order_id is null then false
            when o.order_id is not null then true
            else false
        end as is_valid_order_id,

        case
            when d.book_id is null then false
            when b.book_id is not null then true
            else false
        end as is_valid_book_id,

        case
            when d.promotion_id is null then true
            when p.promotion_id is not null then true
            else false
        end as is_valid_promotion_id

    from deduplicated d

    left join {{ ref('silver_orders') }} o
        on d.order_id = o.order_id

    left join {{ ref('silver_books') }} b
        on d.book_id = b.book_id

    left join {{ ref('silver_promotions') }} p
        on d.promotion_id = p.promotion_id
)

select
    *,
    (
        is_valid_order_id
        and is_valid_book_id
        and is_valid_promotion_id
    ) as is_valid_record
from validated
