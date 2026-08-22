{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='publisher_id',
    on_schema_change='fail'
) }}
with source as (
    select * from {{ source('bronze', 'publishers') }}
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
            nullif(trim(publisher_id), '') as bigint
        ) as publisher_id,
        cast(
            nullif(trim(publisher_name), '') as varchar(255)
        ) as publisher_name,
        cast(
            {{ normalize_country('country') }} as varchar(100)
        ) as country,
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
        partition by publisher_id
        order by
            updated_at desc nulls last,
            _loaded_at desc,
            _source_row_number desc
    ) = 1

)

select * from deduplicated
