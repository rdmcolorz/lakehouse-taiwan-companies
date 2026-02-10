{{
  config(
    materialized='view',
    tags=['raw', 'staging']
  )
}}
-- Staging view over the union of all company CSV datasets in the datalake.
-- Source: company_data_landing (create this VDS in Dremio to union s3_datalake.company_data.*)
select * from {{ source('lakehouse', 'company_data_landing') }}
