with main as (
    select *
    from {{ ref("dim_weekly_active_listings")}}
),

predicted_price_cte as (
    select *,
    round(
        (total_area * (select max(med_price_per_m2) 
                        from {{ref("fct_weekly_derived_values")}}
                      )
        )
        , 2) as predicted_price
    from main
),

price_consistency as (
    select *,
    round((price_uah - predicted_price)
         , 2) as price_diff,
    round(
        (
            (price_uah - predicted_price) / predicted_price
        ) * 100
    , 2) as market_deviation
    from predicted_price_cte
),

deviation_flags as (
    select *,
    case
        when abs(market_deviation) > 30 then true 
        else false
    end as is_extreme_deviation,

    case 
        when abs(market_deviation) between 20 and 30 then true
        else false
    end as is_high_diviation,

    case 
        when abs(market_deviation) between 10 and 20 then true
        else false
    end as is_low_deviation,

    case 
        when market_deviation >= 10 then true
        else false
    end as is_positive_deviation,

    case 
        when market_deviation <= -10 then true
        else false
    end as is_negative_deviation

    from price_consistency

),


derived_values as (
    select p25_price, p50_price, p75_price
    from {{ref("fct_weekly_derived_values")}}
),

percentile_groups as (
    select m.*,
    case
        when m.price_uah < d.p25_price then '0-25%'
        when m.price_uah < d.p50_price then '25-50%'
        when m.price_uah < d.p75_price then '50-75%'
        else '75-100%'
    end as percentile_group
    from deviation_flags m
    cross join derived_values d
)


select * from percentile_groups

