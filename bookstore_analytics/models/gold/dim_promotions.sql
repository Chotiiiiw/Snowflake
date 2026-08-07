with snapshot_versions as (

    select
        dbt_scd_id as promotion_key,
        promotion_id,
        promotion_name,
        discount_type,
        discount_value,
        starts_at,
        ends_at,
        created_at,
        updated_at,
        dbt_valid_from,
        dbt_valid_to,

        row_number() over (
            partition by promotion_id
            order by dbt_valid_from, dbt_scd_id
        ) as promotion_version_number

    from {{ ref('snapshot_promotions') }}

),

final as (

    select
        promotion_key,
        promotion_id,
        promotion_version_number,

        promotion_name,
        discount_type,
        discount_value,
        starts_at,
        ends_at,

        created_at,
        updated_at,

        case
            when promotion_version_number = 1
                then '1900-01-01'::timestamp_ntz
            else dbt_valid_from
        end as valid_from,

        dbt_valid_to as valid_to,
        dbt_valid_to is null as is_current

    from snapshot_versions

)

select * from final