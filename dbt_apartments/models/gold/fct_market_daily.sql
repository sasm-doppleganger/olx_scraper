with base as (

    select *
    from {{ ref('dim_podil_rentals') }}

)

select

    _scraped_at as scrape_date,

    count(*) as listing_count,

    count(distinct id_str) as unique_listing_count,

    round(avg(price_uah), 0) as avg_price_uah,

    min(price_uah) as min_price_uah,

    max(price_uah) as max_price_uah,

    percentile_cont(0.25) within group (order by price_uah)::numeric as p25_price_uah,

    percentile_cont(0.50) within group (order by price_uah)::numeric as median_price_uah,

    percentile_cont(0.75) within group (order by price_uah)::numeric as p75_price_uah,

    round(avg(total_area), 2) as avg_area_m2,

    round(
        avg(
            price_uah / NULLIF(total_area, 0)
            )
        , 2) as avg_price_per_m2

from base

group by 1
order by scrape_date desc