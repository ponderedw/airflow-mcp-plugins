# Airflow Chat — Sample Questions

## Part 1 — Query & Monitor
*Based on [Airflow MCP](https://newsletter.ponder.co/p/airflow-mcp)*

- Which DAGs failed in the last 24 hours and what was the error?
- Show me all DAGs that are currently running and how long they've been executing.
- What operators does the `dbt_run_staging` DAG use?
- Which DAGs have never successfully completed a run?
- Give me a summary of today's pipeline health — what succeeded, what failed, what's still running.
- What's the full execution history of `transform_grades_aggregator` for the past week?
- Which DAGs are triggered by `load_attendance_records`?

---

## Part 2 — Control & Predict
*Based on [Next-Level Airflow MCP](https://newsletter.ponder.co/p/next-level-airflow-mcp)*

- Pause all currently active DAGs and tell me which ones were already paused before.
- Which of our DAGs was paused before our last maintenance window? Unpause only those.
- When will `dbt_run_intermediate` run next, and how long is it expected to take?
- What upstream dataset needs to be updated to trigger `transform_parent_sentiment`?
- Predict the next run time for all DAGs that depend on `dbt_run_staging`.
- If `load_attendance_records` fails right now, which downstream DAGs will be blocked?
- Which event-driven DAGs have been waiting the longest for their trigger condition?

---

## Part 3 — Conversational Pipeline Operations
*Based on [Airflow Chat](https://newsletter.ponder.co/p/airflow-chat-conversational-ai-built)*

- I'm new to this Airflow instance — give me a tour of our most important pipelines.
- Walk me through what happens end-to-end when `load_parent_teacher_feedback` starts.
- Which DAGs are safe to re-trigger manually right now without causing duplicates?
- We had a data incident yesterday at 3pm — which DAGs were running at that time?
- What's the difference between `transform_resource_optimization` and `transform_grade_performance` in terms of dependencies?
- Explain the `dbt_run_marts_finance` DAG to someone who doesn't know Airflow.
- Which pipelines should I be watching if I want to know when today's grade reports are ready?
