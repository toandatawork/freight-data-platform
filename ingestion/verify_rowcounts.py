import logging
from pathlib import Path

import psycopg2

from ingestion.config import load_ghost_config
from ingestion.load_to_ghost import TABLES

logging.basicConfig(level=logging.INFO, format="%(message)s")
log = logging.getLogger("verify_rowcounts")

DATA_DIR = Path(__file__).resolve().parent.parent / "data" / "raw"


def csv_row_count(table: str) -> int:
    csv_path = DATA_DIR / f"{table}.csv"
    with csv_path.open(encoding="utf-8") as f:
        return sum(1 for _ in f) - 1  # excluding header


def pg_row_count(conn, table: str) -> int:
    with conn.cursor() as cur:
        cur.execute(f"SELECT COUNT(*) FROM oltp.{table}")
        return cur.fetchone()[0]


def main() -> None:
    cfg = load_ghost_config()
    conn = psycopg2.connect(cfg.dsn)

    log.info("%-30s %-10s %-10s %s", "table", "csv_rows", "pg_rows", "match")
    mismatches = []
    try:
        for table in TABLES:
            csv_rows = csv_row_count(table)
            pg_rows = pg_row_count(conn, table)
            match = "OK" if csv_rows == pg_rows else "MISMATCH"
            if match == "MISMATCH":
                mismatches.append(table)
            log.info("%-30s %-10d %-10d %s", table, csv_rows, pg_rows, match)
    finally:
        conn.close()

    if mismatches:
        raise SystemExit(f"Row count mismatch on: {', '.join(mismatches)}")
    log.info("All %d tables match.", len(TABLES))


if __name__ == "__main__":
    main()