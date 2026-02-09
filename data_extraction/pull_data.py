import csv
import io
import requests
from minio import Minio
from minio.error import S3Error

BUCKET_NAME = "datalake"
CSV_OBJECT_NAME = "data_links.csv"


def get_minio_client():
    return Minio(
        "localhost:9000",
        access_key="minioadmin",
        secret_key="minioadmin",
        secure=False,
    )


def get_links_from_csv(client):
    """Fetch data_links.csv from MinIO and return rows as list of dicts."""
    response = client.get_object(BUCKET_NAME, CSV_OBJECT_NAME)
    try:
        content = response.read().decode("utf-8")
        return list(csv.DictReader(io.StringIO(content)))
    finally:
        response.close()
        response.release_conn()


def download_and_upload(client, row):
    """Download file from URL and upload to datalake bucket in MinIO."""
    url = row.get("資料下載網址", "").strip()
    if not url:
        return False

    dataset_id = row.get("資料集識別碼", "unknown").strip()
    dataset_name = row.get("資料集名稱", "unknown").strip()
    file_format = row.get("檔案格式", "bin").strip().lower()
    ext = f".{file_format}" if file_format else ".bin"
    object_name = f"company_data/{dataset_name}/{dataset_id}_{ext}"

    try:
        resp = requests.get(url, timeout=60, stream=True)
        resp.raise_for_status()
        data = resp.content
    except requests.RequestException as e:
        print(f"  Skip {dataset_id}: download failed - {e}")
        return False

    try:
        client.put_object(
            BUCKET_NAME,
            object_name,
            io.BytesIO(data),
            length=len(data),
            content_type=resp.headers.get("Content-Type", "application/octet-stream"),
        )
        print(f"  Uploaded {object_name}")
        return True
    except S3Error as e:
        print(f"  Skip {dataset_id}: upload failed - {e}")
        return False


def pull_and_sync():
    client = get_minio_client()
    rows = get_links_from_csv(client)
    print(f"Found {len(rows)} links in {CSV_OBJECT_NAME}")
    ok = sum(1 for row in rows if download_and_upload(client, row))
    print(f"Done: {ok}/{len(rows)} files uploaded to {BUCKET_NAME}")


if __name__ == "__main__":
    pull_and_sync()