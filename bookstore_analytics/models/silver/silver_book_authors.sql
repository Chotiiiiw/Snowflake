{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key=['book_id', 'author_id'],
    on_schema_change='fail'
) }}

with source as (

    select *
    from {{ source('bronze', 'book_authors') }}

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
            nullif(trim(author_id), '') as bigint
        ) as author_id,

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
    select * from cleaned

    qualify row_number() over (
        partition by book_id, author_id
        order by
            _loaded_at desc,
            _source_row_number desc
    ) = 1
)

select * from deduplicated