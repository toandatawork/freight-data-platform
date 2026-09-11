from datetime import datetime

from airflow.decorators import dag
from cosmos import DbtTaskGroup, ExecutionConfig, ProfileConfig, ProjectConfig, RenderConfig

DBT_PROJECT_DIR = "/opt/airflow/dbt"

profile_config = ProfileConfig(
    profile_name="freight",
    target_name="prod",
    profiles_yml_filepath=f"{DBT_PROJECT_DIR}/profiles.yml",
)
project_config = ProjectConfig(DBT_PROJECT_DIR)
execution_config = ExecutionConfig(dbt_executable_path="/home/airflow/dbt_venv/bin/dbt")


@dag(
    dag_id="freight_backfill",
    schedule=None,  # Manual trigger for backfill execution
    start_date=datetime(2026, 1, 1),
    catchup=False,
    tags=["freight", "backfill"],
)
def freight_backfill():
    DbtTaskGroup(
        group_id="dbt_backfill_delivery_events",
        project_config=project_config,
        profile_config=profile_config,
        execution_config=execution_config,
        render_config=RenderConfig(select=["fct_delivery_event"]),
    )


freight_backfill()
