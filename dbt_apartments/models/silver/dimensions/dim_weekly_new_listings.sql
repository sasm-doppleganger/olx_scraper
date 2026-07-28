with main as (
    select *
    from {{ref("dim_weekly_listings")}}
),


filtered as (
    select *
    from main
    where id_str not in (
        select id_str
        from {{ ref("dim_podil_rentals") }}
        where _scraped_at = (
            current_date - ((extract(isodow from current_date)::int) - 1) - 1
        )::date
    )
),


ranked as (
    select
        *,
        row_number() over (
            partition by id_str
            order by _scraped_at desc
        ) as rn
    from filtered
)

select *
from ranked
where rn = 1