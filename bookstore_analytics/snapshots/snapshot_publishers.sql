{% snapshot snapshot_publishers %}

{{
    config(
        target_schema='snapshots',
        unique_key='publisher_id',
        strategy='check',
        check_cols=[
            'publisher_name',
            'country'
        ]
    )
}}

select
    publisher_id,
    publisher_name,
    country,
    created_at,
    updated_at
from {{ ref('silver_publishers') }}

{% endsnapshot %}