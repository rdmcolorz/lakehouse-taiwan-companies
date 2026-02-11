{{
  config(
    materialized='table',
    tags=['intermediate']
  )
}}

    select
        serial_number,
        company_name,
        company_address,
        capital_total,
        paid_in_capital,
        operating_capital,
        approval_date,
        business_address,
        fiscal_information_center_import_date,
        stock_code,
        industry_type,
        financial_supervisory_commission_import_date,
        trademark_data,
        intellectual_property_administration_import_date,
        import_file_name,
        loaded_at,
        case
            when import_file_name like '六都%' then 'direct_controlled'
            when import_file_name like '(北%' then 'north'
            when import_file_name like '(南%' then 'south'
            when import_file_name like '(中%' then 'central'
            when import_file_name like '(東%' then 'east'
        end as area,
        industry_code,
        pg_regexp_split_to_array(industry_code, ',') as industry_codes
    from {{ ref('raw_company') }}