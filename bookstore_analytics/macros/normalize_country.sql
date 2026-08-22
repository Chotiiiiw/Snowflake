{% macro normalize_country(column_name) %}
    case
        when nullif(trim({{ column_name }}), '') is null
            then null

        when lower(trim({{ column_name }})) in (
            'th',
            'thai',
            'thailand',
            'ไทย'
        )
            then 'Thailand'

        when lower(trim({{ column_name }})) in (
            'us',
            'u.s.',
            'usa',
            'u.s.a.',
            'united states',
            'united states of america'
        )
            then 'United States'

        when lower(trim({{ column_name }})) in (
            'uk',
            'u.k.',
            'gb',
            'great britain',
            'united kingdom'
        )
            then 'United Kingdom'

        when lower(trim({{ column_name }})) in (
            'korea, south',
            'republic of korea',
            'south korea'
        )
            then 'South Korea'

        else initcap(lower(trim({{ column_name }})))
    end
{% endmacro %}
