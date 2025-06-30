FROM apache/airflow:2.10.2-python3.10
USER airflow
RUN pip install airflow-chat==0.1.0a4 airflow-schedule-insights==0.1.2 --no-cache-dir
# RUN pip install airflow-schedule-insights==0.1.2 --no-cache-dir
# COPY dist/airflow_chat-0.1.0a4-py3-none-any.whl /tmp/
# RUN pip install /tmp/airflow_chat-0.1.0a4-py3-none-any.whl
COPY local_airflow/ $AIRFLOW_HOME
# COPY requirements-dev.txt ./requirements-dev.txt
# RUN pip install -r requirements-dev.txt
