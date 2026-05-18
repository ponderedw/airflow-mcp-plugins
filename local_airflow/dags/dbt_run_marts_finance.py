from airflow.decorators import dag, task
from pendulum import datetime
from airflow.datasets import Dataset
import time


@dag(
    dag_id="dbt_run_marts_finance",
    max_active_runs=1,
    start_date=datetime(2023, 1, 1),
    is_paused_upon_creation=False,
    catchup=False,
    schedule_interval=Dataset("dbt_run_intermediate"),
)
def dag_test():
    @task(outlets=[Dataset("dbt_run_marts_finance")])
    def student_financial_profile():
        time.sleep(15)

    @task(outlets=[Dataset("dbt_run_marts_finance")])
    def financial_aid_impact_analysis():
        time.sleep(15)

    @task(outlets=[Dataset("dbt_run_marts_finance")])
    def tuition_revenue_analysis():
        time.sleep(15)

    student_financial_profile()
    financial_aid_impact_analysis()
    tuition_revenue_analysis()


dag_test()
