{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='book_id',
    on_schema_change='fail'
) }}

with source as (

    select *
    from {{ source('bronze', 'books') }}

    {% if is_incremental() %}

        where _loaded_at > (
            select coalesce(
                max(_loaded_at),
                '1900-01-01'::timestamp_ltz
            )
            from {{ this }}
        )

    {% endif %}

),

cleaned as (
    select
        try_cast(
            nullif(trim(book_id), '') as bigint
        ) as book_id,
        try_cast(
            nullif(trim(publisher_id), '') as bigint
        ) as publisher_id,
        cast(
            nullif(trim(isbn), '') as varchar(20)
        ) as isbn,
        cast(
            nullif(trim(title), '') as varchar(500)
        ) as title,

        cast(
            nullif(initcap(lower(trim(language))), '') as varchar(50)
        ) as language,

        try_cast(
            nullif(trim(publication_year), '') as integer
        ) as publication_year,

        try_cast(
            nullif(trim(list_price), '') as decimal(12, 2)
        ) as list_price,

        try_cast(
            nullif(trim(cost_price), '') as decimal(12, 2)
        ) as cost_price,

        try_cast(
            nullif(trim(created_at), '') as timestamp_ntz
        ) as created_at,

        try_cast(
            nullif(trim(updated_at), '') as timestamp_ntz
        ) as updated_at,

        cast(_source_filename as varchar(500))
            as _source_filename,

        cast(_source_row_number as number(38, 0))
            as _source_row_number,

        cast(_batch_id as varchar(100))
            as _batch_id,

        cast(_loaded_at as timestamp_ltz)
            as _loaded_at

    from source

),

deduplicated as (

    select *
    from cleaned

    qualify row_number() over (
        partition by book_id
        order by
            updated_at desc nulls last,
            _loaded_at desc,
            _source_row_number desc
    ) = 1
),

validated as (
    select
        d.*,

        case
            when d.publisher_id is null then true
            when p.publisher_id is not null then true
            else false
        end as is_valid_publisher_id

    from deduplicated d

    left join {{ ref('silver_publishers') }} p
        on d.publisher_id = p.publisher_id
)

select
    *,
    is_valid_publisher_id as is_valid_record
from validated
