import csv
import logging
import time
from pathlib import Path

import psycopg2

from ingestion.config import load_ghost_config

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("load_to_ghost")

DATA_DIR = Path(__file__).resolve().parent.parent / "data" / "raw"
DDL_PATH = Path(__file__).resolve().parent / "ddl.sql"

TABLES = [
    "customers", "trucks", "trailers", "facilities", "routes", "drivers",
    "loads", "trips", "fuel_purchases", "maintenance_records",
    "delivery_events", "safety_incidents",
    "driver_monthly_metrics", "truck_utilization_metrics",
]


def apply_ddl(conn) -> None:
    with conn.cursor() as cur:
        cur.execute(DDL_PATH.read_text())
    conn.commit()
    log.info("DDL applied: schema oltp, %d tables", len(TABLES))


def copy_table(conn, table: str) -> int:
    csv_path = DATA_DIR / f"{table}.csv"
    start = time.monotonic()

    with csv_path.open(newline="", encoding="utf-8") as f:
        rows_read = sum(1 for _ in csv.reader(f)) - 1  # excluding header

    with conn.cursor() as cur:
        with csv_path.open("r", encoding="utf-8") as f:
            cur.copy_expert(
                f"COPY oltp.{table} FROM STDIN WITH (FORMAT csv, HEADER true)", f
            )
        rows_written = cur.rowcount
    conn.commit()

    duration = time.monotonic() - start
    log.info(
        "table=%-28s rows_read=%-8d rows_written=%-8d duration=%.2fs",
        table, rows_read, rows_written, duration,
    )
    if rows_read != rows_written:
        log.warning("MISMATCH on %s: read %d but wrote %d", table, rows_read, rows_written)
    return rows_written


def main() -> None:
    cfg = load_ghost_config()
    conn = psycopg2.connect(cfg.dsn)
    try:
        apply_ddl(conn)
        total = 0
        for table in TABLES:
            total += copy_table(conn, table)
        log.info("Done. Total rows written: %d", total)
    finally:
        conn.close()


if __name__ == "__main__":
    main()
