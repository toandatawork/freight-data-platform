import os

from databricks.sdk import WorkspaceClient
from dotenv import load_dotenv

load_dotenv()

CATALOGS = ["freight_dev", "freight_prod", "freight_ci"]


def main() -> None:
    w = WorkspaceClient(host=os.environ["DBX_HOST"], token=os.environ["DBX_TOKEN"])
    
    warehouse_id = os.environ["DBX_HTTP_PATH"].rstrip("/").split("/")[-1]

    for catalog in CATALOGS:
        w.statement_execution.execute_statement(
            warehouse_id=warehouse_id,
            statement=f"CREATE CATALOG IF NOT EXISTS {catalog}",
            wait_timeout="30s",
        )
        print(f"catalog={catalog} created")

        w.statement_execution.execute_statement(
            warehouse_id=warehouse_id,
            statement=f"CREATE SCHEMA IF NOT EXISTS {catalog}.bronze",
            wait_timeout="30s",
        )
        print(f"  schema={catalog}.bronze created")


if __name__ == "__main__":
    main()
