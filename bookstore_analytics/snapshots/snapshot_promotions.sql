{% snapshot snapshot_promotions %}

{{
    config(
        target_schema='snapshots',
        unique_key='promotion_id',
        strategy='check',
        check_cols=[
            'promotion_name',
            'discount_type',
            'discount_value',
            'starts_at',
            'ends_at'
        ]
    )
}}

select
    promotion_id,
    promotion_name,
    discount_type,
    discount_value,
    starts_at,
    ends_at,
    created_at,
    updated_at
from {{ ref('silver_promotions') }}

{% endsnapshot %}