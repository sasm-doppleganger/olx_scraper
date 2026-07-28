select *
from {{ ref('dim_kyiv_rentals') }}

where district = 'Подільський'