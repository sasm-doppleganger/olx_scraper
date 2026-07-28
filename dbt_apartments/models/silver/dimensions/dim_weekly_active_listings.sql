with main as (
    select *
    from {{ ref("dim_weekly_listings")}}
),

define_new_listings as (
    select *, EXISTS (
            SELECT 1
            FROM {{ref("dim_weekly_new_listings")}} b
            WHERE main.id_str = b.id_str
        ) AS is_new
    from main
),

ranked as (
    select
        *,
        row_number() over (
            partition by id_str
            order by _scraped_at desc
        ) as rn
    from define_new_listings
    where id_str not in (
        select id_str
        from {{ ref("dim_removed_rentals") }}
    )
)

select *
from ranked
where rn = 1