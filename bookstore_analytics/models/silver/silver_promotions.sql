{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='promotion_id',
    on_schema_change='fail'
) }}
with source as (
    select * from {{ source('bronze', 'promotions') }}
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
            nullif(trim(promotion_id), '') as bigint
        ) as promotion_id,
        cast(
            nullif(trim(promotion_name), '') as varchar(255)
        ) as promotion_name,
        cast(
            case
                when nullif(trim(discount_type), '') is null
                    then null

                when lower(trim(discount_type))
                    in ('percentage', 'percent')
                    then 'percentage'

                when lower(trim(discount_type))
                    in ('fixed_amount', 'fixed amount', 'fixed')
                    then 'fixed_amount'

                else lower(trim(discount_type))
            end as varchar(50)
        ) as discount_type,

        try_cast(
            nullif(
                trim(replace(discount_value, '%', '')),
                ''
            ) as decimal(12, 2)
        ) as discount_value,

        try_cast(
            nullif(trim(starts_at), '') as timestamp_ntz
        ) as starts_at,

        try_cast(
            nullif(trim(ends_at), '') as timestamp_ntz
        ) as ends_at,

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

    from source
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