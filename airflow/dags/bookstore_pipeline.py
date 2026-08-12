import pendulum

from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.providers.snowflake.operators.snowflake import SnowflakeCheckOperator
from airflow.providers.standard.operators.bash import BashOperator
from airflow.sdk import DAG


with DAG(
    dag_id="bookstore_pipeline",
    start_date=pendulum.datetime(2026, 1, 1, tz="Asia/Bangkok"),
    schedule="@daily",
    catchup=False,
    template_searchpath="/opt/airflow/snowflake/bronze",
    tags=["bookstore", "snowflake", "dbt"],
) as dag:
    load_bronze = SQLExecuteQueryOperator(
        task_id="load_bronze",
        conn_id="snowflake_bookstore",
        sql="to_bronze.sql",
        split_statements=True,
        autocommit=True,
    )

    validate_bronze = SnowflakeCheckOperator(
        task_id="validate_bronze",
        snowflake_conn_id="snowflake_bookstore",
        sql="validate_bronze.sql",
    )

    build_silver = BashOperator(
        task_id="build_silver",
        bash_command="""
            dbt build \
              --project-dir /opt/airflow/bookstore_analytics \
              --profiles-dir /home/airflow/.dbt \
              --select path:models/silver \
              --log-path /tmp/dbt-logs/build-silver \
              --target-path /tmp/dbt-target/build-silver
        """,
    )

    run_snapshots = BashOperator(
        task_id="run_snapshots",
        bash_command="""
            dbt snapshot \
              --project-dir /opt/airflow/bookstore_analytics \
              --profiles-dir /home/airflow/.dbt \
              --log-path /tmp/dbt-logs/run-snapshots \
              --target-path /tmp/dbt-target/run-snapshots
        """,
    )

    build_gold = BashOperator(
        task_id="build_gold",
        bash_command="""
            dbt build \
              --project-dir /opt/airflow/bookstore_analytics \
              --profiles-dir /home/airflow/.dbt \
              --select path:models/gold \
              --log-path /tmp/dbt-logs/build-gold \
              --target-path /tmp/dbt-target/build-gold
        """,
    )

    (
        load_bronze >> validate_bronze >> build_silver >> run_snapshots >> build_gold
    )