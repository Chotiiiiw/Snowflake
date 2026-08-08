with order_items as (

    select *
    from {{ ref('silver_order_items') }}
    where is_valid_record = true

),
orders as (
    select *
    from {{ ref('silver_orders') }}
    where is_valid_record = true
      and ordered_at is not null

),
books as (

    select *
    from {{ ref('dim_books') }}
    where is_valid_record = true
      and cost_price is not null

),

customers as (

    select *
    from {{ ref('dim_customers') }}

),
stores as (
    select *
    from {{ ref('dim_stores') }}

),
staff as (
    select *
    from {{ ref('dim_staff') }}
),
promotions as (
    select *
    from {{ ref('dim_promotions') }}
),
joined as (
    select
        -- Fact grain: one row per order item
        oi.order_item_id,

        -- Degenerate dimension
        oi.order_id,

        -- Dates
        cast(o.ordered_at as date) as order_date,
        o.ordered_at,

        -- SCD2 surrogate keys
        b.book_key,
        c.customer_key,
        s.store_key,
        st.staff_key,
        p.promotion_key,

        -- Natural keys for traceability
        oi.book_id,
        o.customer_id,
        o.store_id,
        o.staff_id,
        oi.promotion_id,

        -- Order attributes
        o.sales_channel,
        o.payment_method,
        o.order_status,

        -- Measures
        oi.quantity,
        oi.unit_price,
        coalesce(oi.discount_amount, 0) as discount_amount,

        -- Historical cost from the matching book version
        b.cost_price as unit_cost

    from order_items oi

    inner join orders o
        on oi.order_id = o.order_id

    inner join books b
        on oi.book_id = b.book_id
        and o.ordered_at >= b.valid_from
        and o.ordered_at < coalesce(
            b.valid_to,
            '9999-12-31'::timestamp_ntz
        )

    inner join stores s
        on o.store_id = s.store_id
        and o.ordered_at >= s.valid_from
        and o.ordered_at < coalesce(
            s.valid_to,
            '9999-12-31'::timestamp_ntz
        )

    left join customers c
        on o.customer_id = c.customer_id
        and o.ordered_at >= c.valid_from
        and o.ordered_at < coalesce(
            c.valid_to,
            '9999-12-31'::timestamp_ntz
        )

    left join staff st
        on o.staff_id = st.staff_id
        and o.ordered_at >= st.valid_from
        and o.ordered_at < coalesce(
            st.valid_to,
            '9999-12-31'::timestamp_ntz
        )

    left join promotions p
        on oi.promotion_id = p.promotion_id
        and o.ordered_at >= p.valid_from
        and o.ordered_at < coalesce(
            p.valid_to,
            '9999-12-31'::timestamp_ntz
        )

),

calculated as (
    select
        *,
        quantity * unit_price as gross_sales,

        (quantity * unit_price) - discount_amount as net_sales,

        quantity * unit_cost as total_cost,

        ((quantity * unit_price) - discount_amount) - (quantity * unit_cost) as gross_profit,

        coalesce(
            order_status = 'Completed',
            false
        ) as is_completed

    from joined
)
select
    *,
    current_timestamp() as _loaded_at
from calculated
