with snapshot_versions as (

    select
        dbt_scd_id as customer_key,
        customer_id,
        first_name,
        last_name,
        customer_name,
        email,
        phone,
        birth_date,
        city,
        country,
        created_at,
        updated_at,
        dbt_valid_from,
        dbt_valid_to,

        row_number() over (
            partition by customer_id
            order by dbt_valid_from, dbt_scd_id
        ) as customer_version_number

    from {{ ref('snapshot_customers') }}

),

final as (

    select
        customer_key,
        customer_id,
        customer_version_number,

        first_name,
        last_name,
        customer_name,
        email,
        phone,
        birth_date,
        city,
        country,

        created_at,
        updated_at,

        case
            when customer_version_number = 1
                then '1900-01-01'::timestamp_ntz
            else dbt_valid_from
        end as valid_from,

        dbt_valid_to as valid_to,
        dbt_valid_to is null as is_current

    from snapshot_versions

)

select * from final