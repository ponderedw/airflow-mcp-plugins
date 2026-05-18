from airflow.decorators import dag, task
from pendulum import datetime
from airflow.datasets import Dataset
import time


@dag(
    dag_id="dbt_run_marts_core",
    max_active_runs=1,
    start_date=datetime(2023, 1, 1),
    is_paused_upon_creation=False,
    catchup=False,
    schedule_interval=Dataset("dbt_run_intermediate"),
)
def dag_test():
    @task(outlets=[Dataset("dbt_run_marts_core")])
    def student_academic_summary():
        time.sleep(15)

    @task(outlets=[Dataset("dbt_run_marts_core")])
    def academic_early_warning_system():
        time.sleep(15)

    @task(outlets=[Dataset("dbt_run_marts_core")])
    def graduation_pathway_analysis():
        time.sleep(15)

    @task(outlets=[Dataset("dbt_run_marts_core")])
    def institutional_kpi_dashboard():
        time.sleep(15)

    student_academic_summary()
    academic_early_warning_system()
    graduation_pathway_analysis()
    institutional_kpi_dashboard()


dag_test()
