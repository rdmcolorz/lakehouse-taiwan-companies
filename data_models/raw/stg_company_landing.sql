{{
  config(
    materialized='view',
    tags=['raw', 'staging']
  )
}}
-- Staging view over the union of all company CSV datasets in the datalake.
-- Source: company_data_landing (create this VDS in Dremio to union s3_datalake.company_data.*)
select
  "統一編號" as serial_number,
  "公司名稱" as company_name,
  "公司地址" as company_address,
  "資本總額" as capital_total,
  "實收資本額" as paid_in_capital,
  "在境內營運資金" as operating_capital,
  "核准設立日期" as approval_date,
  "營業地址（財政資訊中心匯入）" as business_address,
  "行業代號（財政資訊中心匯入）" as industry_code,
  "財政資訊中心匯入日期" as fiscal_information_center_import_date,
  "股票代號（金融監督管理委員會匯入）" as stock_code,
  "產業別（金融監督管理委員會匯入）" as industry_type,
  "金融監督管理委員會匯入日期" as financial_supervisory_commission_import_date,
  "商標資料（智慧財產局匯入）" as trademark_data,
  "智慧財產局匯入日期" as intellectual_property_administration_import_date,
  dir0 as import_file_name,
  current_timestamp as loaded_at
from {{ source('lakehouse', 'company_data_landing') }}
