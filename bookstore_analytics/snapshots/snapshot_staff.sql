{% snapshot snapshot_staff %}

{{
    config(
        target_schema='snapshots',
        unique_key='staff_id',
        strategy='check',
        check_cols=[
            'store_id',
            'manager_staff_id',
            'staff_code',
            'first_name',
            'last_name',
            'full_name',
            'email',
            'phone',
            'job_title',
            'employment_status',
            'hire_date',
            'termination_date',
            'is_valid_store_id',
            'is_valid_manager_staff_id',
            'is_valid_record'
        ]
    )
}}

select
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
    is_valid_record
from {{ ref('silver_staff') }}

{% endsnapshot %}