{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='promotion_id',
    on_schema_change='fail'
) }}

with source as (
    select * from {{ source('bronze', 'promotions') }} 
), cleaned as (
    select 
        try_cast(
            nullif(trim(promotion_id), '') 
            as bigint
        ) as promotion_id, 
        cast(
            trim(promotion_name) as varchar(255)
        ) as promotion_name, 
        cast(
            -- only percentage and fixed will be used. 
            case
            when lower(trim(discount_type)) in ('percentage', 'percent') then 'percentage'
            when lower(trim(discount_type)) = 'fixed_amount' then 'fixed_amount'
            else null end as varchar(50)
        ) as discount_type, 
        try_cast(
            case 
            when discount_value like '%\%%' then replace(discount_value,'%', '') 
            end as decimal(10,2)
        ) as discount_value,
        try_cast(
            nullif(trim(created_at), '') as timestamp_ntz
        ) as created_at,

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
    from 
        source
),
deduplicated as (
    select * from cleaned

    qualify row_number() over (
        partition by promotion_id
        order by
            updated_at desc nulls last,
            _loaded_at desc,
            _source_row_number desc
    ) = 1

)

select * from deduplicated