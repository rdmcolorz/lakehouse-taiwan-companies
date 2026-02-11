{{
  config(
    materialized='incremental',
    unique_key='serial_number',
    merge_update_columns=[
        'company_name',
        'company_address',
        'capital_total',
        'paid_in_capital',
        'operating_capital',
        'approval_date',
        'business_address',
        'industry_code',
        'fiscal_information_center_import_date',
    ],
    tags=['raw', 'incremental']
  )
}}
-- Persisted raw company table: only new records are merged in on each run.
-- Uses 統一編號 (Unified Business Number) as the unique key; existing rows are updated
-- when the source has newer data for the same company.
select * from {{ ref('stg_company_landing') }}
