select *
from {{ ref('silver_listings') }}
where price_uah <= 0