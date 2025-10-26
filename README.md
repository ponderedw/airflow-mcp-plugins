# 🚀 airflow-chat: Conversational AI Built into Airflow

> Talk to your DAGs, inspect tasks, and operate pipelines—right from the interface.

## Introduction

Not long ago, we introduced our MCP for Airflow—designed to make operating DAGs and workflows as intuitive as chatting with a colleague. But there was a catch: it depended on Claude Desktop, which some organizations are unable or unwilling to adopt due to concerns around sharing data with Anthropic—or because of other operational, compliance, or policy-related reasons.

That got us thinking: **what if we brought the same conversational interface directly into the Airflow UI?**

That's how the airflow-chat plugin came to life.

## 🏗️ Architecture Overview

Under the hood, the plugin still leverages our existing MCP. You can run it fully embedded inside the Airflow webserver, or flexibly configure it in one of three ways:

### 1. **Embedded Plugin** (Simplest Setup)
As a plugin running inside the Airflow webserver
```
┌─────────────────────────────────────┐
│        Airflow Webserver            │
│  ┌─────────────┐  ┌─────────────┐   │
│  │  Chat UI    │  │     MCP     │   │
│  │   Plugin    │◄─┤   Service   │   │
│  └─────────────┘  └─────────────┘   │
└─────────────────────────────────────┘
```

### 2. **Plugin + External MCP**
Using the plugin alongside a separate MCP service
```
┌─────────────────┐    ┌─────────────────┐
│  Airflow Web    │    │   MCP Service   │
│  ┌───────────┐  │    │                 │
│  │  Chat UI  │◄─┼────┤  Airflow MCP    │
│  │  Plugin   │  │    │                 │
│  └───────────┘  │    │                 │
└─────────────────┘    └─────────────────┘
```

### 3. **Fully Decoupled Architecture**
Three-process architecture: Airflow webserver plugin → FastAPI server → MCP service
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Airflow    │    │   FastAPI   │    │     MCP     │
│  Webserver  │    │   Backend   │    │   Service   │
│ ┌─────────┐ │    │             │    │             │
│ │Chat UI  │◄┼────┤  Langchain  │◄───┤  Airflow    │
│ │Plugin   │ │    │   Logic     │    │    MCP      │
│ └─────────┘ │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘
```

## 🔧 LLM Backend Flexibility

You have full control over the LLM backend. MCP supports multiple providers, so you can choose to run it with:

- **Amazon Bedrock** (`bedrock:...`)
- **Anthropic** (`anthropic:...`)
- **OpenAI** (`openai:...`)

This makes it easier than ever to integrate natural language interfaces into your pipelines—entirely within your stack and control.

## 🚀 Quick Start

### Prerequisites
- Apache Airflow 2.0+
- Python 3.8+
- Valid API credentials for your chosen LLM provider

### Installation

```bash
pip install airflow-chat==0.1.0a8
```

> **Note**: Version 0.1.0a8 is the latest at the time of writing. Check our [PyPI repository](https://pypi.org/project/airflow-chat/) for updates before installing.

### 🛠️ Required Environment Variables

Add the following environment variables to your cluster configuration:

```bash
# LLM Configuration
LLM_MODEL_ID=anthropic:claude-3-5-haiku-20241022
ANTHROPIC_API_KEY=your_anthropic_key

# Airflow Connection
AIRFLOW_ASSISTENT_AI_CONN=airflow:airflow@http://localhost:8080
```

#### Understanding `AIRFLOW_ASSISTENT_AI_CONN`

This connection string is used by the AI Assistant plugin to communicate with your Airflow instance:

```
AIRFLOW_ASSISTENT_AI_CONN=<username>:<password>@http://localhost:8080
```

- Replace `<username>` and `<password>` with any valid Airflow credentials
- **Do not change** `localhost:8080`, as this address is required for internal routing within the containerized environment

### 🔄 Model Flexibility

You can switch `LLM_MODEL_ID` to use models from different providers:

**For Bedrock:**
```bash
LLM_MODEL_ID=bedrock:anthropic.claude-3-5-sonnet-20241022-v2:0
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
```

**For OpenAI:**
```bash
LLM_MODEL_ID=openai:gpt-4
OPENAI_API_KEY=your_openai_key
```

### ⚙️ Additional Configuration

Optional Airflow MCP environment variables:
- `AIRFLOW_INSIGHTS_MODE`
- `POST_MODE`

For detailed explanations of these options, see our [blog post](https://link-to-blog-post).

## 🎯 Getting Started

### Using Our Default Environment

If you're using our pre-configured environment:

```bash
cp airflow-plugin-test.env airflow-plugin.env
# Edit airflow-plugin.env with your values
just airflow
```

**Available Just Commands:**
- `just airflow` - Start basic Airflow with embedded plugin
- `just prod` - Deploy with external MCP service
- `just down` - Stop all services
- `just logs` - View service logs

### 🧭 Accessing the Assistant

1. Start your Airflow cluster
2. Open http://localhost:8080
3. Navigate to: **Tools → AI Chat Assistant**

Try asking:
- "What Airflow DAGs do we have, and which ones are paused?"
- "Show me failed task instances from the last 24 hours"
- "Trigger the sales_pipeline DAG"

🎉 Everything should work beautifully out of the box!

## 🔐 Access Control

Access to the AI plugin is restricted to:
- **Admins**, or
- Any user assigned the **AIRFLOW_AI** role

## 🏗️ Advanced Deployment Strategies

### Option 1: External MCP Server

To run MCP as a separate component:

**Step 1: Configure Environment Files**
```bash
# Copy and configure MCP environment
cp airflow-mcp-test.env airflow-mcp.env
# Edit airflow-mcp.env with your values

# Configure plugin environment  
cp airflow-plugin-test.env airflow-plugin.env
# Edit airflow-plugin.env to remove AIRFLOW_ASSISTENT_AI_CONN
```

**Step 2: Update Airflow Environment Variables**
```bash
# Add to airflow-plugin.env
TRANSPORT_TYPE=sse
mcp_host=host.docker.internal:8001
MCP_TOKEN=test_token
```

**Step 3: Configure MCP Service Environment**
```bash
# In airflow-mcp.env
LLM_MODEL_ID=anthropic:claude-3-5-haiku-20241022
AIRFLOW_ASSISTENT_AI_CONN=airflow:airflow@http://airflow-webserver:8080
TOKEN=test_token
TRANSPORT_TYPE=sse
```

✅ **Important**: Ensure that `TOKEN` and `MCP_TOKEN` have the same value to establish a secure connection.

**Step 4: Deploy**
```bash
# Using our repo
just prod

# Or with Docker directly
docker run pondered/airflow-mcp:latest
```

📌 **Note**: Update `mcp_host` if you're deploying the MCP server on your own infrastructure.

### Option 2: Plugin as UI Only

For fully decoupled Langchain logic:

**Step 1: Configure Environment Files**
```bash
# Copy and configure all environment files
cp airflow-plugin-test.env airflow-plugin.env
cp langchain-fastapi-test.env langchain-fastapi.env
cp airflow-mcp-test.env airflow-mcp.env
```

**Step 2: Update Airflow Plugin Configuration**
```bash
# In airflow-plugin.env
INTERNAL_AI_ASSISTANT_SERVER=false
FAST_API_ACCESS_SECRET_TOKEN='ThisIsATempAccessTokenForLocalEnvs.ReplaceInProd'
BACKEND_URL=http://chat_fastapi:8080
```

**Step 3: Configure FastAPI Service**
```bash
# In langchain-fastapi.env
LLM_MODEL_ID=anthropic:claude-3-5-haiku-20241022
SECRET_KEY='ThisIsATempSecretForLocalEnvs.ReplaceInProd.'
FAST_API_ACCESS_SECRET_TOKEN='ThisIsATempAccessTokenForLocalEnvs.ReplaceInProd'

TRANSPORT_TYPE=sse
MCP_TOKEN=test_token
mcp_host=mcp_sse_server:8000

POSTGRES_USER='airflow'
POSTGRES_PASSWORD='airflow'
POSTGRES_DB='postgres'
```

**Step 4: Deploy**
```bash
just prod
```

**Available Images:**
- `pondered/airflow-mcp:latest` - MCP service
- `pondered/airflow-mcp-fastapi:latest` - FastAPI backend

See `docker-compose.prod.yml` for complete configuration example.

### Option 3: Shared MCP Backend

Want to offload backend logic from your Airflow Webserver without introducing a separate MCP service?

**Step 1: Configure Environment Files**
```bash
# Copy environment files
cp langchain-fastapi-test.env langchain-fastapi.env
cp airflow-plugin-test.env airflow-plugin.env
```

**Step 2: Modify Backend Configuration**
```bash
# In langchain-fastapi.env, remove this line:
# TRANSPORT_TYPE=sse

# Copy all environment variables from your MCP service configuration
# directly into langchain-fastapi.env
```

**Step 3: Deploy**
```bash
just prod
```

This option gives you better performance isolation without significantly increasing deployment complexity.

## 🎛️ Available Just Commands

Our repository includes several convenient commands:

```bash
# Basic deployment commands
just airflow          # Start Airflow with embedded plugin
just prod             # Deploy production setup with external services
```

## 📁 Environment File Reference

Here's a complete list of environment files you can copy and customize:

```bash
# Basic plugin setup
cp airflow-plugin-test.env airflow-plugin.env

# External MCP setup
cp airflow-mcp-test.env airflow-mcp.env

# FastAPI backend setup
cp langchain-fastapi-test.env langchain-fastapi.env

# Docker compose configurations
# - docker-compose.yml (basic setup)
# - docker-compose.prod.yml (production setup)
```

## 📊 What You Can Do

The airflow-chat plugin enables natural language interactions with your Airflow instance:

### DAG Operations
- "List all DAGs and their status"
- "Pause the data_pipeline DAG"
- "Show me the last 5 runs of customer_etl"

### Task Monitoring
- "Which tasks failed in the last hour?"
- "Show me the logs for task_id in dag_id"
- "What's the current status of my running DAGs?"

### Pipeline Management
- "Trigger the monthly_report DAG"
- "When will the sales_pipeline DAG run next?"
- "Show me all paused DAGs"

