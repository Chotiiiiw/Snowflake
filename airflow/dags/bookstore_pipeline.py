import pendulum

from airflow.providers.standard.operators.bash import BashOperator
from airflow.sdk import DAG


with DAG(
    dag_id="bookstore_pipeline",
    start_date=pendulum.datetime(2026, 1, 1, tz="Asia/Bangkok"),
    schedule=None,
    catchup=False,
    tags=["bookstore", "snowflake", "dbt"],
) as dag:
    check_dbt = BashOperator(
        task_id="check_dbt",
        bash_command="dbt --version",
    )

    check_project_files = BashOperator(
        task_id="check_project_files",
        bash_command="""
            test -f /opt/airflow/bookstore_analytics/dbt_project.yml
            test -f /opt/airflow/snowflake/bronze/to_bronze.sql
            test -f /opt/airflow/snowflake/bronze/validate_bronze.sql
        """,
    )

    check_dbt >> check_project_files