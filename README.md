# Open Lakehouse Lab

A local data lakehouse stack using **Apache Iceberg**, **Nessie** (catalog), **MinIO** (S3-compatible storage), and **Dremio** for querying.
*This is a project mainly for learning purposes, but I'm also interested in Taiwan's startup landscape and what companies are being created in recent years.
This data has potential to guide entrepreneurs make better decisions based on public data.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and Docker Compose

## Quick Start

1. **Environment**  
   Ensure a `.env` file exists with `MINIO_ROOT_USER` and `MINIO_ROOT_PASSWORD` (used by Docker Compose for MinIO).

2. **Start services**
   ```bash
   docker compose up -d
   ```

3. **Services**
   - **MinIO** — object storage: http://localhost:9000 (API), http://localhost:9001 (console)
      - This uses an older version of minIO to make admin tools accessible. 
   - **Nessie** — catalog API: http://localhost:19120
   - **Dremio** — query engine: http://localhost:9047

4. **Notebooks**  
   Use the Jupyter notebooks under `notebooks/` with a PySpark kernel configured for Iceberg + Nessie + MinIO (see `lakehouse.ipynb` for session config).

## Project Layout

| Path | Description |
|------|-------------|
| `docker-compose.yml` | MinIO, Nessie, Dremio on network `iceberg_env` |
| `notebooks/` | PySpark + Iceberg + Nessie examples |
| `data_extraction/` | Scripts to pull data (e.g. from URLs in CSV) into MinIO |
| `data_models/` | dbt project (Dremio); raw + incremental `raw_company` model |

## Data Extraction

The csv containing links to company registry data comes from: [data.gov.tw](https://data.gov.tw/datasets/search?p=1&size=10&s=_score_desc&rft=%E5%85%AC%E5%8F%B8%E7%99%BB%E8%A8%98%E8%B3%87%E6%96%99).
Download the csv and include it in `data_extraction/` to pull all associated csvs into object storage.

From `data_extraction/` you can run `pull_data.py` (with a Python env that has `minio`, `requests`) to ingest files listed in `data_links.csv` into the MinIO `datalake` bucket.

## Incremental load into `raw_company`

The registry CSVs are updated periodically. To persist data and only add new or changed records:

1. **Extract**  
   Run `pull_data.py` as above. It overwrites the latest CSV per dataset in MinIO under `company_data/{dataset_name}/`.

2. **Dremio**
   - **Promote the folder to a dataset:** In Datasets, open your object-storage source (e.g. `datalake`), go to the `company_data` folder, hover and click **Format** (format folder). Set format to **Text (delimited)**, enable **Extract Field Names**, then Save.
   - **Create the VDS** used by dbt at **`datalake.datalake.company_data`**: either run a query like `SELECT "統一編號", "公司名稱", ... FROM "datalake"."datalake"."company_data"` and save as a VDS named `company_data` under `datalake.datalake`, or create a VDS that points at that promoted dataset. The dbt source in `data_models/raw/sources.yml` is configured to read from `datalake.datalake.company_data`.

3. **dbt**  
   Set env vars (or use `data_models/.env`): `DREMIO_HOST`, `DREMIO_USER`, `DREMIO_PASSWORD`. From the repo root (with `dbt-dremio` installed):
   ```bash
   dbt run --project-dir data_models --profiles-dir data_models
   ```
   The `raw_company` model is incremental: it merges by **統一編號** (Unified Business Number). New companies are inserted; existing ones are updated when the source has newer data. The profile uses `object_storage_path: "datalake"` so dbt writes (and drops) temp tables under the correct bucket and avoids “find bucket” errors.

---

*Optional: set `AWS_*` and `NESSIE_URI` in `.env` to match this stack when using Spark or other clients.*
