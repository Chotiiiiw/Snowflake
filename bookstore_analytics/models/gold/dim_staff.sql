with snapshot_versions as (

    select
        dbt_scd_id as staff_key,
        staff_id,
        store_id,
        manager_staff_id,
        staff_code,
        first_name,
        last_name,
        full_name,
        email,
        phone,
        job_title,
        employment_status,
        hire_date,
        termination_date,
        created_at,
        updated_at,
        is_valid_store_id,
        is_valid_manager_staff_id,
        is_valid_record,
        dbt_valid_from,
        dbt_valid_to,

        row_number() over (
            partition by staff_id
            order by dbt_valid_from, dbt_scd_id
        ) as staff_version_number

    from {{ ref('snapshot_staff') }}

),

final as (

    select
        staff_key,
        staff_id,
        staff_version_number,

        store_id,
        manager_staff_id,
        staff_code,
        first_name,
        last_name,
        full_name,
        email,
        phone,
        job_title,
        employment_status,
        hire_date,
        termination_date,

        created_at,
        updated_at,

        is_valid_store_id,
        is_valid_manager_staff_id,
        is_valid_record,

        case
            when staff_version_number = 1
                then '1900-01-01'::timestamp_ntz
            else dbt_valid_from
        end as valid_from,

        dbt_valid_to as valid_to,
        dbt_valid_to is null as is_current

    from snapshot_versions

)

select *
from final