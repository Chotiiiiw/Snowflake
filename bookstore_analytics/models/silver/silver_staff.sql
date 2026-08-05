{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='staff_id',
    on_schema_change='fail'
) }}

with source as (

    select *
    from {{ source('bronze', 'staff') }}

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
            nullif(trim(staff_id), '') as bigint
        ) as staff_id,

        try_cast(
            nullif(trim(store_id), '') as bigint
        ) as store_id,

        try_cast(
            nullif(trim(manager_staff_id), '') as bigint
        ) as manager_staff_id,

        cast(
            nullif(trim(staff_code), '') as varchar(50)
        ) as staff_code,

        cast(
            nullif(trim(first_name), '') as varchar(100)
        ) as first_name,

        cast(
            nullif(trim(last_name), '') as varchar(100)
        ) as last_name,
        cast(
            concat(first_name, last_name) as varchar(200)
        ) as full_name,
        cast(
            nullif(lower(trim(email)), '') as varchar(255)
        ) as email,

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
        
        cast(
            nullif(trim(job_title), '') as varchar(100)
        ) as job_title,

        cast(
            nullif(lower(trim(employment_status)), '') as varchar(50)
        ) as employment_status,

        try_cast(
            nullif(trim(hire_date), '') as date
        ) as hire_date,

        try_cast(
            nullif(trim(termination_date), '') as date
        ) as termination_date,

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
        partition by staff_id
        order by
            updated_at desc nulls last,
            _loaded_at desc,
            _source_row_number desc
    ) = 1
)
select * from deduplicated