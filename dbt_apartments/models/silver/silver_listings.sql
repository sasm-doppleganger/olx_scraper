with base as (
            select * 
            from {{ ref('bronze_listings')}}
              ),


clean_identity as (
    select *,
    
    concat(
        cast(id as text),
        '_',
        cast(scraped_at as text)
        ) as dedup_id,

    cast(id as text) as id_str,

    cast(created_time as timestamp) as created_time_ts,

    cast(valid_to_time as timestamp) as valid_to_time_ts,

    case
        when lower(status) = 'active' then true
        else false
    end as is_active,

    -- write down
    case
        when cooperate_key = '1' then true
        else false
    end as cooperate,

    --  write down
    case
        when joint_lease_key = '1' then true
        else false
    end as joint_lease,

    -- redo
    -- scraped_at as scraped_at_raw,
    cast(scraped_at as DATE) as _scraped_at
    -- cast(_scraped_at as date)


    from base
),

clean_price as (
    select *,

    case
        when commission_key = '1' then true
        else false
    end as no_commission

    from clean_identity
),

clean_building_info as(
    select *,

    property_type_appartments_sale_label as building_type,

    cast(year_of_commissioning_key as integer) as year_of_commissioning

    from clean_price
),


clean_apartment_details as(
    select *,

    cast(floor_key as integer) as floor,

    cast(total_floors_key as integer) as total_floors,

    cast(total_area_key as numeric) as total_area,

    cast(kitchen_area_key as numeric) as kitchen_area,

    cast(house_type_label as text) as house_type,

    -- consider regex there to get rid of non-digits
    cast(number_of_rooms_string_label as text) as number_of_rooms,

    cast(bathroom_label as text) as bathroom_type,

    cast(heating_label as text) as heating,

    cast(repair_label as text) as repair_type,
    
    case
        when furnish_key = 'yes' then true
        when furnish_key = 'no' then false
        else null
    end as furnish,

    cast(layout_label as text) as layout

    from clean_building_info
),


clean_amenities_details as (
    select *,

    case
        when appliances_2_stove = 1 then true
        else false
    end as has_stove,

    case
        when appliances_2_fridge = 1 then true
        else false
    end as has_fridge,

    case
        when appliances_2_dishwasher = 1 then true
        else false
    end as has_dishwasher,

    case
        when appliances_2_washer = 1 then true
        else false
    end as has_washer,

    -- write down
    case
        when appliances_2_electric_kettle = 1 then true
        else false
    end as has_electric_kettle,

    -- write down
    case
        when appliances_2_hob = 1 then true
        else false
    end as has_hob,

    -- write down
    case
        when appliances_2_microwave = 1 then true
        else false
    end as has_microwave,

    -- write down
    case
        when appliances_2_oven = 1 then true
        else false
    end as has_oven,

    -- write down
    case
        when appliances_2_vacuum_cleaner = 1 then true
        else false
    end as has_vacuum_cleaner,

    -- write down
    case
        when appliances_2_iron = 1 then true
        else false
    end as has_iron,

    -- -- write down
    -- case
    --     when appliances_2_multi-cooking = 1 then true
    --     else false
    -- end as has_multi_cooking,

    -- write down
    case
        when appliances_2_hair_dryer = 1 then true
        else false
    end as has_hair_dryer,

    -- write down
    case
        when appliances_2_coffeemachine = 1 then true
        else false
    end as has_coffemachine,

    -- write down
    case
        when appliances_2_drying_machine = 1 then true
        else false
    end as has_drying_machine,

    -- write down
    -- 6/11/26 new column detected
    -- case
    --     when appliances_2_no_appliances = 0 then true
    --     else false
    -- end as has_appliances,

    case
        when multimedia_2_wifi = 1 then true
        else false
    end as has_wifi,

    case
        when multimedia_2_speed_internet = 1 then true
        else false
    end as has_speed_internet,

    case
        when multimedia_2_tv = 1 then true
        else false
    end as has_tv,

    -- write down
    case
        when multimedia_2_cable_digital = 1 then true
        else false
    end as has_cable_digital,

    -- write down
    case
        when multimedia_2_satellite = 1 then true
        else false
    end as has_satellite,

    case
        when comfort_air_conditioning = 1 then true
        else false
    end as has_air_conditioning,

    case
        when comfort_heated_floors = 1 then true
        else false
    end as has_heated_floors,

    case
        when comfort_bath = 1 then true
        else false
    end as has_bath,

    case
        when comfort_balcony_loggia = 1 then true
        else false
    end as has_balcony_loggia,

    case
        when comfort_parking_place = 1 then true
        else false
    end as has_parking_place,

    -- write down
    case
        when comfort_elevator = 1 then true
        else false
    end as has_elevator,

    -- write down
    case
        when comfort_kitchen_furniture = 1 then true
        else false
    end as has_kitchen_furniture,

    -- write down
    case
        when comfort_shower = 1 then true
        else false
    end as has_shower,

    -- write down
    case
        when comfort_wardrobe = 1 then true
        else false
    end as has_wardrobe,

    -- write down
    case
        when "comfort_CCTV" = 1 then true
        else false
    end as has_cctv,

    -- write down
    case
        when comfort_guest_parking = 1 then true
        else false
    end as has_guest_parking,

    -- write down
    case
        when comfort_panoramic_windows = 1 then true
        else false
    end as has_panoramic_windows,

    -- write down
    case
        when comfort_concierge = 1 then true
        else false
    end as has_concierge,

    -- write down
    case
        when comfort_fire_alarm = 1 then true
        else false
    end as has_fire_alarm,

    -- write down
    case
        when comfort_ground_parking = 1 then true
        else false
    end as has_ground_parking,

    -- write down
    case
        when comfort_service_lift = 1 then true
        else false
    end as has_service_lift,

    -- write down
    case
        when comfort_garage = 1 then true
        else false
    end as has_garage,

    -- write down
    case
        when comfort_protected_area = 1 then true
        else false
    end as has_protected_area,

    -- write down
    case
        when comfort_signaling = 1 then true
        else false
    end as has_signaling,

    -- -- write down
    -- case
    --     when comfort_stand-alone_power = 1 then true
    --     else false
    -- end as has_stand_alone_power,

    -- write down
    case
        when comfort_storage = 1 then true
        else false
    end as has_storage,

    -- write down
    case
        when comfort_tech_smart_house = 1 then true
        else false
    end as has_tech_smart_house,

    -- write down
    case
        when comfort_terrace = 1 then true
        else false
    end as has_terrace,

    -- write down
    case
        when comfort_windows_lattices = 1 then true
        else false
    end as has_windows_lattices,

    case
        when communications_gas = 1 then true
        else false
    end as has_gas,

    case
        when communications_central_sewerage_system = 1 then true
        else false
    end as has_central_sewerage_system,

    case
        when communications_garbage_removal = 1 then true
        else false
    end as has_garbage_removal,

    -- write down
    case
        when communications_asphalt_road = 1 then true
        else false
    end as has_asphalt_road,

    -- write down
    case
        when communications_electricity = 1 then true
        else false
    end as has_electricity,

    -- write down
    case
        when communications_water_central = 1 then true
        else false
    end as has_water_central,

    -- write down
    case
        when communications_sewerage_septic_tank = 1 then true
        else false
    end as has_sewerage_septic_tank,

    -- write down
    case
        when communications_well = 1 then true
        else false
    end as has_well,

    -- write down
    case
        when blackout_autonomy_elevator = 1 then true
        else false
    end as has_blackout_elevator,

    -- write down
    case
        when blackout_autonomy_internet = 1 then true
        else false
    end as has_blackout_internet,

    -- write down
    case
        when blackout_autonomy_water_supply = 1 then true
        else false
    end as has_blackout_water_supply,

    -- write down
    case
        when blackout_autonomy_heating = 1 then true
        else false
    end as has_blackout_heating,

    -- write down
    case
        when blackout_autonomy_backup_power_supply = 1 then true
        else false
    end as has_blackout_backup_power_supply              

    from clean_apartment_details
),


clean_infrastructure_details as (
    select *,

    case
        when infrastructure_500_m_kindergarten = 1 then true
        else false
    end as has_kindergarten,

    case
        when infrastructure_500_m_school = 1 then true
        else false
    end as has_school,

    case
        when infrastructure_500_m_pump = 1 then true
        else false
    end as has_pump,

    case
        when infrastructure_500_m_transport_stop = 1 then true
        else false
    end as has_transport_stop,

    case
        when infrastructure_500_m_metro = 1 then true
        else false
    end as has_metro,

    case
        when infrastructure_500_m_market = 1 then true
        else false
    end as has_market,

    case
        when infrastructure_500_m_shop_kiosk = 1 then true
        else false
    end as has_shop_kiosk,

    case
        when infrastructure_500_m_supermarket_mall = 1 then true
        else false
    end as has_supermarket_mall,

    case
        when infrastructure_500_m_park = 1 then true
        else false
    end as has_park,

    -- write down
    case
        when infrastructure_500_m_farmacy = 1 then true
        else false
    end as has_farmacy,

    -- write down
    case
        when infrastructure_500_m_playground = 1 then true
        else false
    end as has_playground,

    -- write down
    case
        when infrastructure_500_m_post_office = 1 then true
        else false
    end as has_post_office,

    -- write down
    case
        when "infrastructure_500_m_bank_ATM" = 1 then true
        else false
    end as has_bank_atm,

    -- write down
    case
        when infrastructure_500_m_hospital = 1 then true
        else false
    end as has_hospital,

    -- write down
    case
        when infrastructure_500_m_restaurant_cafe = 1 then true
        else false
    end as has_restaurant_cafe,

    -- write down
    case
        when infrastructure_500_m_railway_station = 1 then true
        else false
    end as has_railway_station,

    -- write down
    case
        when infrastructure_500_m_cinema_theater = 1 then true
        else false
    end as has_cinema_theater,

    -- write down
    case
        when infrastructure_500_m_bus_station = 1 then true
        else false
    end as has_bus_station,

    -- write down
    case
        when infrastructure_500_m_city_center = 1 then true
        else false
    end as has_city_center_near,

    -- write down
    case
        when ecosystem_1_km_river = 1 then true
        else false
    end as has_river,

    -- write down
    case
        when ecosystem_1_km_lake = 1 then true
        else false
    end as has_lake,

    -- write down
    case
        when ecosystem_1_km_park = 1 then true
        else false
    end as has_1km_park,

    -- write down
    case
        when ecosystem_1_km_hills = 1 then true
        else false
    end as has_1km_hills,

    -- write down
    case
        when ecosystem_1_km_forest = 1 then true
        else false
    end as has_1km_forest                   

    from clean_amenities_details
),

-- write down
clean_pets_details as (
    select *,

    case
        when pets_yes_cat = 1 then true
        else false
    end as cat_allowed,

    case
        when pets_yes_small_dog = 1 then true
        else false
    end as small_dog_allowed,

    case
        when pets_no = 1 then true
        else false
    end as pets_disallowed,

    case
        when pets_yes_other = 1 then true
        else false
    end as other_pets_allowed, 

    case
        when pets_yes_big_dog = 1 then true
        else false
    end as big_dog_allowed,

    case
        when pets_yes_medium_dog = 1 then true
        else false
    end as medium_dog_allowed                   



    from clean_infrastructure_details
),


final as (
    select
    -- identity
    id_str, dedup_id, created_time_ts, valid_to_time_ts, is_active,

    -- listing info
    title, url, description,

    -- location
    city, district, region,

    -- price
    price_org::numeric, currency_org, price_uah::numeric, no_commission,

    -- extra
    cooperate, joint_lease,

    -- building info
    building_type, year_of_commissioning, house_type,

    -- apartment info
    floor, total_floors, total_area, kitchen_area,
    number_of_rooms, bathroom_type, heating, repair_type,
    furnish, layout,

    -- ammenities
    has_stove, has_fridge, has_dishwasher, has_washer, has_electric_kettle, has_hob, has_microwave,
    has_oven, has_vacuum_cleaner, has_iron, has_hair_dryer, has_coffemachine, has_drying_machine,
    has_wifi, has_speed_internet, has_tv, has_cable_digital, has_satellite, has_air_conditioning,
    has_heated_floors, has_bath, has_balcony_loggia, has_parking_place, has_elevator, has_kitchen_furniture,
    has_shower, has_wardrobe, has_CCTV, has_guest_parking, has_panoramic_windows, has_concierge,
    has_fire_alarm, has_ground_parking, has_service_lift, has_garage, has_protected_area, has_signaling,
    has_storage, has_tech_smart_house, has_terrace, has_windows_lattices,

    --  communications
    has_gas, has_central_sewerage_system, has_garbage_removal, has_asphalt_road, has_electricity, has_water_central,
    has_sewerage_septic_tank, has_well,
    has_blackout_elevator, has_blackout_internet, has_blackout_water_supply, has_blackout_heating, has_blackout_backup_power_supply,

    -- infrastructure
    has_kindergarten, has_school, has_pump, has_transport_stop, has_metro, has_market, has_shop_kiosk, has_supermarket_mall,
    has_park, has_farmacy, has_playground, has_post_office, has_bank_ATM, has_hospital, has_restaurant_cafe,
    has_railway_station, has_cinema_theater, has_bus_station, has_city_center_near, has_river, has_lake,
    has_1km_park, has_1km_hills, has_1km_forest,

    -- pets
    pets_disallowed, cat_allowed, small_dog_allowed, medium_dog_allowed, big_dog_allowed,
    other_pets_allowed,



    -- metadata
    _scraped_at,
    _scraped_at::date - created_time_ts::date as _lifetime

    from clean_pets_details
)

select * 
from final