with snapshot_versions as (
    select
        dbt_scd_id as book_key,
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
        is_valid_record,
        dbt_valid_from,
        dbt_valid_to,

        row_number() over (
            partition by book_id
            order by dbt_valid_from, dbt_scd_id
        ) as book_version_number

    from {{ ref('snapshot_books') }}

),

final as (

    select
        book_key,
        book_id,
        book_version_number,
        publisher_id,
        isbn,
        title,
        language,
        publication_year,
        list_price,
        cost_price,
        created_at,
        updated_at,
        is_valid_record,

        case
            when book_version_number = 1
                then '1900-01-01'::timestamp_ntz
            else dbt_valid_from
        end as valid_from,

        dbt_valid_to as valid_to,
        dbt_valid_to is null as is_current

    from snapshot_versions

)
select * from final