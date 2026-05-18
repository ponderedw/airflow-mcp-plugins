from airflow.decorators import dag, task
from pendulum import datetime
from airflow.datasets import Dataset
import time


@dag(
    dag_id="dbt_run_staging",
    max_active_runs=1,
    start_date=datetime(2023, 1, 1),
    is_paused_upon_creation=False,
    catchup=False,
    schedule_interval="0 6 * * *",
)
def dag_test():
    @task(outlets=[Dataset("dbt_run_staging")])
    def stg_students():
        time.sleep(5)

    @task(outlets=[Dataset("dbt_run_staging")])
    def stg_courses():
        time.sleep(5)

    @task(outlets=[Dataset("dbt_run_staging")])
    def stg_enrollments():
        time.sleep(5)

    @task(outlets=[Dataset("dbt_run_staging")])
    def stg_faculty():
        time.sleep(5)

    @task(outlets=[Dataset("dbt_run_staging")])
    def stg_financial_aid():
        time.sleep(5)

    stg_students()
    stg_courses()
    stg_enrollments()
    stg_faculty()
    stg_financial_aid()


dag_test()
