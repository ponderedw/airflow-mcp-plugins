from airflow.decorators import dag, task
from pendulum import datetime
from airflow.datasets import Dataset
import time


@dag(
    dag_id="dbt_run_intermediate",
    max_active_runs=1,
    start_date=datetime(2023, 1, 1),
    is_paused_upon_creation=False,
    catchup=False,
    schedule_interval=Dataset("dbt_run_staging"),
)
def dag_test():
    @task(outlets=[Dataset("dbt_run_intermediate")])
    def int_student_enrollment_history():
        time.sleep(10)

    @task(outlets=[Dataset("dbt_run_intermediate")])
    def int_course_performance_metrics():
        time.sleep(10)

    @task(outlets=[Dataset("dbt_run_intermediate")])
    def int_student_at_risk_indicators():
        time.sleep(10)

    @task(outlets=[Dataset("dbt_run_intermediate")])
    def int_faculty_teaching_load():
        time.sleep(10)

    @task(outlets=[Dataset("dbt_run_intermediate")])
    def int_grade_inflation_analysis():
        time.sleep(10)

    int_student_enrollment_history()
    int_course_performance_metrics()
    int_student_at_risk_indicators()
    int_faculty_teaching_load()
    int_grade_inflation_analysis()


dag_test()
