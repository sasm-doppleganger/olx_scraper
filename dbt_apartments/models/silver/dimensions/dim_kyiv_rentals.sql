select *
from {{ ref('silver_listings') }}

where city = 'Київ'