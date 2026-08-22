{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='customer_id',
    on_schema_change='fail'
) }}

with source as (
    select *
    from {{ source('bronze', 'customers') }}

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
            nullif(trim(customer_id), '') as bigint
        ) as customer_id,
        cast(
            REGEXP_SUBSTR(
                TRIM(customer_name),
                '^[^[:space:]]+'
            )
            AS VARCHAR(100)
        ) AS first_name,

        cast(
            NULLIF(
                TRIM(
                    REGEXP_REPLACE(
                        TRIM(customer_name),
                        '^[^[:space:]]+[[:space:]]*',
                        ''
                    )
                ),
                ''
            )
            AS VARCHAR(100)
        ) AS last_name,
        cast(
            nullif(trim(customer_name), '') as varchar(255)
        ) as customer_name,

        cast(
            nullif(lower(trim(email)), '') as varchar(255)
        ) as email,
        -- +66 -> 0 for phone number. 
        cast(
            case
                when regexp_like(
                    regexp_replace(trim(phone), '[^0-9]', ''),
                    '^0[0-9]{9}$'
                )
                then regexp_replace(trim(phone), '[^0-9]', '')

                when regexp_like(
                    regexp_replace(trim(phone), '[^0-9]', ''),
                    '^66[0-9]{9}$'
                )
                then '0' || substr(
                    regexp_replace(trim(phone), '[^0-9]', ''),
                    3
                )
                else null end
                as varchar(10)
        ) as phone,

        try_cast(
            nullif(trim(birth_date), '') as date
        ) as birth_date,

        cast(
        case
            when nullif(trim(city), '') is null
                then null

            when lower(trim(city)) = 'bangkok'
                or trim(city) = 'กรุงเทพฯ'
                then 'Bangkok'

            when lower(trim(city)) = 'chiang mai'
                or trim(city) = 'เชียงใหม่'
                then 'Chiang Mai'

            else initcap(lower(trim(city)))
            end
        as varchar(100) 
        ) as city,

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
    select *
    from cleaned

    qualify row_number() over (
        partition by customer_id
        order by
            updated_at desc nulls last,
            _loaded_at desc,
            _source_row_number desc
    ) = 1

)

select * from deduplicated
