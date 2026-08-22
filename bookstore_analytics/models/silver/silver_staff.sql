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
            concat_ws(
                    ' ',
                    nullif(trim(first_name), ''),
                    nullif(trim(last_name), '')
            ) as varchar(200)
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

                -- Repair legacy values formatted with a four-digit mobile prefix,
                -- for example 0864-309-2846 -> 0863092846.
                when regexp_like(
                    regexp_replace(trim(phone), '[^0-9]', ''),
                    '^0[0-9]{10}$'
                )
                then substr(
                    regexp_replace(trim(phone), '[^0-9]', ''),
                    1,
                    3
                ) || substr(
                    regexp_replace(trim(phone), '[^0-9]', ''),
                    5
                )

                else null end
                as varchar(10)
        ) as phone,
        
        cast(
            case
                when nullif(trim(job_title), '') is null
                    then null
                when lower(trim(job_title)) in (
                    'sales associate',
                    'sales_associate'
                )
                    then 'Sales Associate'
                when lower(trim(job_title)) in (
                    'inventory clerk',
                    'inventory_clerk'
                )
                    then 'Inventory Clerk'
                when lower(trim(job_title)) in (
                    'store manager',
                    'store_manager'
                )
                    then 'Store Manager'
                when lower(trim(job_title)) in (
                    'customer service lead',
                    'customer_service_lead'
                )
                    then 'Customer Service Lead'
                when lower(trim(job_title)) in (
                    'store supervisor',
                    'store_supervisor'
                )
                    then 'Store Supervisor'
                when lower(trim(job_title)) in (
                    'operations specialist',
                    'operations_specialist'
                )
                    then 'Operations Specialist'
                when lower(trim(job_title)) in (
                    'merchandising associate',
                    'merchandising_associate'
                )
                    then 'Merchandising Associate'
                when lower(trim(job_title)) in (
                    'part-time',
                    'part time',
                    'part_time'
                )
                    then 'Part-time'
                when lower(trim(job_title)) = 'cashier'
                    then 'Cashier'
                else initcap(lower(trim(job_title)))
            end as varchar(100)
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
),

staff_parent_keys as (
    select staff_id
    from deduplicated

    {% if is_incremental() %}

        union

        select staff_id
        from {{ this }}

    {% endif %}
),

validated as (
    select
        d.*,

        case
            when d.store_id is null then false
            when s.store_id is not null then true
            else false
        end as is_valid_store_id,

        case
            when d.manager_staff_id is null then true
            when m.staff_id is not null then true
            else false
        end as is_valid_manager_staff_id

    from deduplicated d

    left join {{ ref('silver_stores') }} s
        on d.store_id = s.store_id

    left join staff_parent_keys m
        on d.manager_staff_id = m.staff_id
)

select
    *,
    (
        is_valid_store_id
        and is_valid_manager_staff_id
    ) as is_valid_record
from validated
