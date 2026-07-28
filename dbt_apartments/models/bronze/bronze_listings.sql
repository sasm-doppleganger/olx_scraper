{{ config(
    materialized='incremental',
    unique_key=['id', 'scraped_at'],
    on_schema_change="append_new_columns"
) }}


select
    {{ dbt_utils.star(
        from=source('staging', 'landing'),
        except=['joint_lease_label']
    ) }},
    CAST(joint_lease_label AS text) AS joint_lease_label
FROM {{ source('staging', 'landing') }}
where scraped_at > (select max(scraped_at) from {{this}})