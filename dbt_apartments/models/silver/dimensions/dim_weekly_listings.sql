with main as (
    select *
    from {{ ref("dim_podil_rentals")}}
),

current_week_scrape as (
    select *
        from main 
    where _scraped_at >= (current_date - ((extract(isodow from current_date)::int) - 1) - 1)::date
)

select *
from current_week_scrape