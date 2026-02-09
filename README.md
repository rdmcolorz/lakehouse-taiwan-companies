# Open Lakehouse Lab

A local data lakehouse stack using **Apache Iceberg**, **Nessie** (catalog), **MinIO** (S3-compatible storage), and **Dremio** for querying.

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

## Data Extraction

From `data_extraction/` you can run `pull_data.py` (with a Python env that has `minio`, `requests`) to ingest files listed in `data_links.csv` into the MinIO `datalake` bucket.

---

*Optional: set `AWS_*` and `NESSIE_URI` in `.env` to match this stack when using Spark or other clients.*
