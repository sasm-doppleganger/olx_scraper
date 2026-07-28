select *
from {{ ref('silver_listings') }}
where floor > total_floors