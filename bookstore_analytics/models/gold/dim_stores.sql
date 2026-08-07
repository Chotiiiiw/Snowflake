with snapshot_versions as (

    select
        dbt_scd_id as store_key,
        store_id,
        store_name,
        store_type,
        city,
        opened_at,
        dbt_valid_from,
        dbt_valid_to,

        row_number() over (
            partition by store_id
            order by dbt_valid_from, dbt_scd_id
        ) as store_version_number

    from {{ ref('snapshot_stores') }}

),

final as (

    select
        store_key,
        store_id,
        store_version_number,
        store_name,
        store_type,
        city,
        opened_at,

        case
            when store_version_number = 1
                then '1900-01-01'::timestamp_ntz
            else dbt_valid_from
        end as valid_from,

        dbt_valid_to as valid_to,
        dbt_valid_to is null as is_current

    from snapshot_versions

)

select * from final