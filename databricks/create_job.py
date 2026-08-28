import os
from pathlib import Path

from databricks.sdk import WorkspaceClient
from databricks.sdk.service.workspace import ImportFormat, Language
from dotenv import load_dotenv

load_dotenv()

NOTEBOOK_PATH = "/Shared/freight/nb_ingest_bronze"

w = WorkspaceClient(host=os.environ["DBX_HOST"], token=os.environ["DBX_TOKEN"])
w.workspace.upload(
    path=NOTEBOOK_PATH,
    format=ImportFormat.SOURCE,
    language=Language.PYTHON,
    content=Path("databricks/nb_ingest_bronze.py").read_bytes(),
    overwrite=True,
)
print(f"uploaded to {NOTEBOOK_PATH}")

##########################################################################################################################################

from databricks.sdk.service import jobs

created = w.jobs.create(
    name="freight_bronze_ingest",
    tasks=[
        jobs.Task(
            task_key="ingest_bronze",
            notebook_task=jobs.NotebookTask(
                notebook_path=NOTEBOOK_PATH,
                base_parameters={
                    "target_catalog": "freight_dev",
                    "ghost_host": os.environ["GHOST_HOST"],
                    "ghost_port": os.environ["GHOST_PORT"],
                    "ghost_database": os.environ["GHOST_DATABASE"],
                    "ghost_user": os.environ["GHOST_USER"],
                    "ghost_password": os.environ["GHOST_PASSWORD"],
                    "ghost_sslmode": os.environ["GHOST_SSLMODE"],
                },
            ),
        )
    ],
)
print(f"job_id={created.job_id}")