select *
from {{ ref('silver_listings') }}
where total_area < 10
   or total_area > 1000