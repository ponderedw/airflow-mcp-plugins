airflow:
  docker compose -f docker-compose.postgres.yml -f docker-compose.airflow.yml up --build

project:
  docker compose -f docker-compose.postgres.yml -f docker-compose.airflow.yml -f docker-compose.chat.yml -f docker-compose.ui.yml up --build

project_no_airflow:
  docker compose -f docker-compose.postgres.yml -f docker-compose.chat.yml -f docker-compose.ui.yml up --build

open_web_tabs:
  open -a "Google Chrome" "http://localhost:8501" "http://localhost:8088"

all:
  docker compose -f docker-compose.postgres.yml -f docker-compose.airflow.yml -f docker-compose.chat.yml -f docker-compose.ui.yml -f docker-compose.mcp.yml down
  docker compose -f docker-compose.postgres.yml -f docker-compose.airflow.yml -f docker-compose.chat.yml -f docker-compose.ui.yml -f docker-compose.mcp.yml up --build --pull always

prod:
  docker compose -f docker-compose.postgres.yml -f docker-compose.airflow.yml -f docker-compose.ui.yml -f docker-compose.prod.yml down
  docker compose -f docker-compose.postgres.yml -f docker-compose.airflow.yml -f docker-compose.ui.yml -f docker-compose.prod.yml up --build --pull always