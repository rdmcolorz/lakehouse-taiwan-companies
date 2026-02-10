{{
  config(
    materialized='incremental',
    unique_key='統一編號',
    merge_update_columns=[
      '公司名稱', '公司地址', '資本總額', '實收資本額', '在境內營運資金',
      '核准設立日期', '營業地址（財政資訊中心匯入）', '行業代號（財政資訊中心匯入）',
      '財政資訊中心匯入日期', '股票代號（金融監督管理委員會匯入）',
      '產業別（金融監督管理委員會匯入）', '金融監督管理委員會匯入日期',
      '商標資料（智慧財產局匯入）', '智慧財產局匯入日期', 'loaded_at'
    ],
    tags=['raw', 'incremental']
  )
}}
-- Persisted raw company table: only new records are merged in on each run.
-- Uses 統一編號 (Unified Business Number) as the unique key; existing rows are updated
-- when the source has newer data for the same company.
select
  "統一編號",
  "公司名稱",
  "公司地址",
  "資本總額",
  "實收資本額",
  "在境內營運資金",
  "核准設立日期",
  "營業地址（財政資訊中心匯入）",
  "行業代號（財政資訊中心匯入）",
  "財政資訊中心匯入日期",
  "股票代號（金融監督管理委員會匯入）",
  "產業別（金融監督管理委員會匯入）",
  "金融監督管理委員會匯入日期",
  "商標資料（智慧財產局匯入）",
  "智慧財產局匯入日期",
  current_timestamp as loaded_at
from {{ ref('stg_company_landing') }}
