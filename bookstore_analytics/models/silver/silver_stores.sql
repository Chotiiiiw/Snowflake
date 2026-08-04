{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='store_id',
    on_schema_change='fail'
) }}

with source as (

    select *
    from {{ source('bronze', 'stores') }}

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
            nullif(trim(store_id), '') as bigint
        ) as store_id,

        cast(
            nullif(trim(store_name), '') as varchar(255)
        ) as store_name,

        cast(
            case 
                when nullif(trim(store_type), '') is null
                    then null
                
                when lower(trim(store_type)) = 'physical' or lower(trim(store_type)) = 'physical_store' then 'Physical'
                else initcap(lower(store_type))
            end as varchar(50)
        ) as store_type,

        cast(
            case
                when nullif(trim(city), '') is null
                    then null

                when lower(trim(city)) = 'bangkok'
                     or trim(city) in (
                         'กรุงเทพ',
                         'กรุงเทพฯ',
                         'กรุงเทพมหานคร'
                     )
                    then 'Bangkok'

                when lower(trim(city)) = 'chiang mai' or trim(city) = 'เชียงใหม่' then 'Chiang Mai'

                else initcap(lower(trim(city)))
            end
            as varchar(100)
        ) as city,

        try_cast(
            nullif(trim(opened_at), '') as timestamp_ntz
        ) as opened_at,

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
        partition by store_id
        order by
            _loaded_at desc,
            _source_row_number desc
    ) = 1

)

select *
from deduplicated