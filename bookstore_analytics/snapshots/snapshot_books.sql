{% snapshot snapshot_books %}

{{
    config(
        target_schema='snapshots',
        unique_key='book_id',
        strategy='check',
        check_cols=[
            'publisher_id',
            'isbn',
            'title',
            'language',
            'publication_year',
            'list_price',
            'cost_price',
            'is_valid_record'
        ]
    )
}}

select
    book_id,
    publisher_id,
    isbn,
    title,
    language,
    publication_year,
    list_price,
    cost_price,
    created_at,
    updated_at,
    is_valid_record
from {{ ref('silver_books') }}

{% endsnapshot %}