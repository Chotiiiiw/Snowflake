{% snapshot snapshot_stores %}

{{
    config(
        target_schema='snapshots',
        unique_key='store_id',
        strategy='check',
        check_cols=[
            'store_name',
            'store_type',
            'city',
            'opened_at'
        ]
    )
}}

select
    store_id,
    store_name,
    store_type,
    city,
    opened_at
from {{ ref('silver_stores') }}

{% endsnapshot %}