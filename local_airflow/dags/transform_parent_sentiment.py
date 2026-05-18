from airflow.decorators import dag, task
from pendulum import datetime
from airflow.datasets import Dataset
import time


@dag(
    dag_id="transform_parent_sentiment",
    max_active_runs=1,
    start_date=datetime(2023, 1, 1),
    is_paused_upon_creation=False,
    catchup=False,
    schedule_interval=(
        (Dataset("transform_grades_aggregator") & Dataset("load_parent_teacher_feedback"))
        | Dataset("load_attendance_records")
    ),
)
def dag_test():
    @task(outlets=[Dataset("transform_parent_sentiment")])
    def end_task():
        time.sleep(60)

    end_task()


dag_test()
