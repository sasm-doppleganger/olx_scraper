with base as (

    select *
    from {{ ref('fct_market_daily') }}

),

last_date as (
    select max(scrape_date) as ld
    from base
),

today as (
    select 
    'today' as period,
    *
    from base
    where scrape_date = (select ld from last_date)
),

yesterday as (
    select 
    'today' as period,
    *
    from base
    where scrape_date = (
                    select ld - interval '18 days'
                    from last_date
                    )
)

select 
    t.median_price_uah as today_median,
    y.median_price_uah as yesterday_median,

    round(t.median_price_uah - y.median_price_uah, 2)  as median_diff,
    round((t.median_price_uah - y.median_price_uah) / nullif(y.median_price_uah, 0), 2) * 100 as med_pct_change,


    t.p25_price_uah as today_p25,
    y.p25_price_uah as yesterday_p25,

    round(t.p25_price_uah - y.p25_price_uah, 2)  as p25_diff,
    round((t.p25_price_uah - y.p25_price_uah) / nullif(y.p25_price_uah, 0), 2) * 100 as p25_pct_change,


    t.p75_price_uah as today_p75,
    y.p75_price_uah as yesterday_p75,

    round(t.p75_price_uah - y.p75_price_uah, 2)  as p75_diff,
    round((t.p75_price_uah - y.p75_price_uah) / nullif(y.p75_price_uah, 0), 2) * 100 as p75_pct_change,


    t.max_price_uah as today_max,
    y.max_price_uah as yesterday_max,

    round(t.max_price_uah - y.max_price_uah, 2)  as max_diff,
    round((t.max_price_uah - y.max_price_uah) / nullif(y.max_price_uah, 0), 2) * 100 as max_pct_change,


    t.min_price_uah as today_min,
    y.min_price_uah as yesterday_min,

    round(t.min_price_uah - y.min_price_uah, 2)  as min_diff,
    round((t.min_price_uah - y.min_price_uah) / nullif(y.min_price_uah, 0), 2) * 100 as min_pct_change,


    t.avg_price_per_m2 as today_avg_m2_price,
    y.avg_price_per_m2 as yesterday_avg_m2_price,

    round(t.avg_price_per_m2 - y.avg_price_per_m2, 2)  as avg_m2_price_diff,
    round((t.avg_price_per_m2 - y.avg_price_per_m2) / nullif(y.avg_price_per_m2, 0), 2) * 100 as avg_m2_price_pct_change
from today t
join yesterday y
on t.period = y.period
