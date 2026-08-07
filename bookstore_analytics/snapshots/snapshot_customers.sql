{% snapshot snapshot_customers %}

{{
    config(
        target_schema='snapshots',
        unique_key='customer_id',
        strategy='check',
        check_cols=[
            'first_name',
            'last_name',
            'customer_name',
            'email',
            'phone',
            'birth_date',
            'city',
            'country'
        ]
    )
}}

select
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
    updated_at
from {{ ref('silver_customers') }}

{% endsnapshot %}