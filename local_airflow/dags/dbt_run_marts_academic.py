from airflow.decorators import dag, task
from pendulum import datetime
from airflow.datasets import Dataset
import time


@dag(
    dag_id="dbt_run_marts_academic",
    max_active_runs=1,
    start_date=datetime(2023, 1, 1),
    is_paused_upon_creation=False,
    catchup=False,
    schedule_interval=Dataset("dbt_run_intermediate"),
)
def dag_test():
    @task(outlets=[Dataset("dbt_run_marts_academic")])
    def student_retention_analysis():
        time.sleep(15)

    @task(outlets=[Dataset("dbt_run_marts_academic")])
    def course_difficulty_calibration():
        time.sleep(15)

    @task(outlets=[Dataset("dbt_run_marts_academic")])
    def instructor_effectiveness_scorecard():
        time.sleep(15)

    @task(outlets=[Dataset("dbt_run_marts_academic")])
    def learning_outcome_assessment():
        time.sleep(15)

    student_retention_analysis()
    course_difficulty_calibration()
    instructor_effectiveness_scorecard()
    learning_outcome_assessment()


dag_test()
