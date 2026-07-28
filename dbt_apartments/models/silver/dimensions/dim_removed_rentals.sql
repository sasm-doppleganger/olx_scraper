with main as (
    select *
    from {{ ref("dim_podil_rentals")}}
),


latest_ids as (
    select id_str
    from main
    where _scraped_at = (select max(_scraped_at) from main)
),

removed_rentals as (
    select id_str, url
    from main
    where id_str not in (select id_str
                         from main
                         where _scraped_at = (select max(_scraped_at) from main))
)

select * from removed_rentals