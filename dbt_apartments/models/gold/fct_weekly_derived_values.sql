with main as (
    select *
    from {{ref("dim_weekly_listings")}}
),

derived_values as (
    select
    max(price_uah) as max_price,
    (percentile_cont(0.25) within group (order by price_uah))::numeric as p25_price,    
    (percentile_cont(0.50) within group (order by price_uah))::numeric as p50_price,
    (percentile_cont(0.75) within group (order by price_uah))::numeric as p75_price,
    min(price_uah) as min_price,

    (percentile_cont(0.50)
    within group (order by price_uah / nullif(total_area, 0)))::numeric as med_price_per_m2,
    round(avg(total_area), 2) as avg_area_m2

    from main
    limit 1
)

select *
from derived_values