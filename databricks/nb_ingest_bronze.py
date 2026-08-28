# Databricks notebook source
# Runs as a Databricks Job task — DO NOT run locally using `python nb_ingest_bronze.py`.
# `spark` and `dbutils` are provided by the Databricks runtime; do not import manually.

from pyspark.sql import functions as F

target_catalog = dbutils.widgets.get("target_catalog")
ghost_host = dbutils.widgets.get("ghost_host")
ghost_port = dbutils.widgets.get("ghost_port")
ghost_database = dbutils.widgets.get("ghost_database")
ghost_user = dbutils.widgets.get("ghost_user")
ghost_password = dbutils.widgets.get("ghost_password")
ghost_sslmode = dbutils.widgets.get("ghost_sslmode")

FULL_REFRESH_TABLES = ["customers", "trucks", "trailers", "facilities", "routes", "drivers"]

WATERMARK_COLUMN = {
    "loads": "load_date",
    "trips": "dispatch_date",
    "delivery_events": "actual_datetime",
    "fuel_purchases": "purchase_date",
    "maintenance_records": "maintenance_date",
    "safety_incidents": "incident_date",
    "driver_monthly_metrics": "month",
    "truck_utilization_metrics": "month",
}

ALL_TABLES = FULL_REFRESH_TABLES + list(WATERMARK_COLUMN.keys())

# Constructs the JDBC connection URL for PostgreSQL with SSL mode
def jdbc_url() -> str:
    return f"jdbc:postgresql://{ghost_host}:{ghost_port}/{ghost_database}?sslmode={ghost_sslmode}"

# Reads source data via Spark JDBC with pushdown predicate filtering
def read_source_table(table: str, where_clause: str | None):
    query = f"(SELECT * FROM oltp.{table}"
    if where_clause:
        query += f" WHERE {where_clause}"
    query += f") AS {table}"

    return (
        spark.read.format("jdbc")
        .option("url", jdbc_url())
        .option("dbtable", query)
        .option("user", ghost_user)
        .option("password", ghost_password)
        .option("driver", "org.postgresql.Driver")
        .load()
    )

# Retrieves the current maximum watermark value from the target Delta table
def get_existing_max(table: str, column: str):
    target = f"{target_catalog}.bronze.{table}"
    if not spark.catalog.tableExists(target):
        return None
    row = spark.sql(f"SELECT MAX({column}) AS max_value FROM {target}").collect()[0]
    return row["max_value"]

# Orchestrates full-refresh or incremental ingestion into the target Delta Bronze table
def ingest_table(table: str) -> None:
    is_incremental = table in WATERMARK_COLUMN
    where_clause = None
    write_mode = "overwrite"

    if is_incremental:
        watermark_col = WATERMARK_COLUMN[table]
        max_existing = get_existing_max(table, watermark_col)
        if max_existing is not None:
            where_clause = f"{watermark_col} > '{max_existing}'"
            write_mode = "append"

    df = read_source_table(table, where_clause)
    rows_read = df.count()

    df = (
        df.withColumn("_ingested_at", F.current_timestamp())
        .withColumn("_source_file", F.lit(f"ghost_postgres.oltp.{table}"))
    )

    target = f"{target_catalog}.bronze.{table}"
    df.write.format("delta").mode(write_mode).option("mergeSchema", "true").saveAsTable(target)

    print(f"table={table} mode={write_mode} rows_read={rows_read}")


for t in ALL_TABLES:
    ingest_table(t)