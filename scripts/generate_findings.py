import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path

DBT_DIR = Path(__file__).resolve().parent.parent / "dbt"
OUTPUT = Path(__file__).resolve().parent.parent / "docs" / "data_quality_findings.md"


def dbt_show(select: str) -> list[dict]:
    result = subprocess.run(
        ["uv", "run", "dbt", "--quiet", "show", "--select", select, "--profiles-dir", ".",
         "--output", "json", "--limit", "-1"],
        cwd=DBT_DIR, capture_output=True, text=True, check=True,
    )
    payload = json.loads(result.stdout)
    return payload["show"]

def dbt_show_count(select: str) -> int:
    return len(dbt_show(select))

def render_markdown(
    profile_rows: list[dict],
    time_anomaly_count: int,
    flag_mismatch_count: int,
    orphan_driver_count: int,
    orphan_truck_count: int,
    total_loads: int,
) -> str:
    lines = [
        "# Data Quality Findings",
        "",
        f"> Auto-generated {datetime.now(timezone.utc).isoformat()}Z — "
        "reproduce with `uv run python scripts/generate_findings.py`. Do not edit by hand.",
        "",
        "## Bronze column profile",
        "",
        "| table | column | row_count | null_pct | distinct_count |",
        "|---|---|---:|---:|---:|",
    ]
    for row in profile_rows:
        lines.append(
            f"| {row['table_name']} | {row['column_name']} | {row['row_count']} | "
            f"{row['null_pct']} | {row['distinct_count']} |"
        )

    total_orphan = orphan_driver_count + orphan_truck_count
    flag_mismatch_pct = round(100 * flag_mismatch_count / total_loads, 1)

    lines += [
        "",
        "## Known data defects (verified, not descriptions from the dataset source)",
        "",
        f"- **{time_anomaly_count} loads** have `delivery.actual_datetime < pickup.actual_datetime`",
        f"- **{flag_mismatch_count} records ({flag_mismatch_pct}%)** have `on_time_flag = true` "
        "but `actual > scheduled`",
        f"- **{orphan_driver_count} trips** reference a non-existent `driver_id`; "
        f"**{orphan_truck_count}** reference a non-existent `truck_id` ({total_orphan} total)",
        "- `price_per_gallon` is flat across months — this dataset cannot support forecasting",
        "",
        "**Note:** this dataset is synthetic. The defects above are material for demonstrating "
        "a quality-control pipeline, not findings about the freight industry.",
    ]
    return "\n".join(lines)

def main() -> None:
    profile_rows = dbt_show("profile_bronze_columns")

    time_anomaly_count = dbt_show_count("qtn_time_anomaly")
    flag_mismatch_count = dbt_show_count("qtn_flag_mismatch")
    total_loads = dbt_show_count("stg_freight__loads")

    orphan_rows = dbt_show("qtn_orphan_fk")
    orphan_driver_count = sum(1 for r in orphan_rows if r["quarantine_reason"] == "orphan_driver")
    orphan_truck_count = sum(1 for r in orphan_rows if r["quarantine_reason"] == "orphan_truck")

    markdown = render_markdown(
        profile_rows, time_anomaly_count, flag_mismatch_count,
        orphan_driver_count, orphan_truck_count, total_loads,
    )
    OUTPUT.write_text(markdown)
    print(f"wrote {OUTPUT} ({len(profile_rows)} profiled columns)")


if __name__ == "__main__":
    main()