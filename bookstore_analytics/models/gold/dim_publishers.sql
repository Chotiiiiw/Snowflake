with snapshot_versions as (

    select
        dbt_scd_id as publisher_key,
        publisher_id,
        publisher_name,
        country,
        created_at,
        updated_at,
        dbt_valid_from,
        dbt_valid_to,

        row_number() over (
            partition by publisher_id
            order by dbt_valid_from, dbt_scd_id
        ) as publisher_version_number

    from {{ ref('snapshot_publishers') }}

),

final as (

    select
        publisher_key,
        publisher_id,
        publisher_version_number,

        publisher_name,
        country,

        created_at,
        updated_at,

        case
            when publisher_version_number = 1
                then '1900-01-01'::timestamp_ntz
            else dbt_valid_from
        end as valid_from,

        dbt_valid_to as valid_to,
        dbt_valid_to is null as is_current

    from snapshot_versions

)

select * from final