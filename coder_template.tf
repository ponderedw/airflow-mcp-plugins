terraform {
  required_providers {
    coder = {
      source = "coder/coder"
    }
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

locals {
  username = data.coder_workspace_owner.me.name
  repo_url = "https://github.com/ponderedw/airflow-mcp-plugins.git"
  repo_dir = "airflow-mcp-plugins"
}

variable "docker_socket" {
  default     = ""
  description = "(Optional) Docker socket URI"
  type        = string
}

data "coder_parameter" "git_name" {
  name         = "git_name"
  display_name = "Git Name"
  description  = "Your Git name for commits"
  type         = "string"
  mutable      = true
  default      = ""
  order        = 1
}

data "coder_parameter" "llm_model_id" {
  name         = "llm_model_id"
  display_name = "LLM Model ID"
  description  = "Model to use for the AI assistant (e.g. anthropic:claude-3-5-haiku-20241022, openai:gpt-4o, bedrock:...)"
  type         = "string"
  mutable      = true
  default      = "anthropic:claude-3-5-haiku-20241022"
  order        = 2
}

data "coder_parameter" "anthropic_api_key" {
  name         = "anthropic_api_key"
  display_name = "Anthropic API Key"
  description  = "Required if using an Anthropic model"
  type         = "string"
  mutable      = true
  default      = ""
  order        = 3
}

data "coder_parameter" "openai_api_key" {
  name         = "openai_api_key"
  display_name = "OpenAI API Key"
  description  = "Required if using an OpenAI model"
  type         = "string"
  mutable      = true
  default      = ""
  order        = 4
}

data "coder_parameter" "aws_access_key_id" {
  name         = "aws_access_key_id"
  display_name = "AWS Access Key ID"
  description  = "Required if using Amazon Bedrock"
  type         = "string"
  mutable      = true
  default      = ""
  order        = 5
}

data "coder_parameter" "aws_secret_access_key" {
  name         = "aws_secret_access_key"
  display_name = "AWS Secret Access Key"
  description  = "Required if using Amazon Bedrock"
  type         = "string"
  mutable      = true
  default      = ""
  order        = 6
}

provider "docker" {
  host = var.docker_socket != "" ? var.docker_socket : null
}

data "coder_provisioner" "me" {}
data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}

resource "coder_agent" "main" {
  arch = data.coder_provisioner.me.arch
  os   = "linux"

  startup_script = <<-EOT
    set -e

    if [ ! -f ~/.init_done ]; then
      cp -rT /etc/skel ~
      touch ~/.init_done
    fi

    # --- Base tools ---
    sudo apt-get update -q
    sudo apt-get install -y git curl wget software-properties-common just

    # --- Install Docker Engine (DinD) ---
    echo "Installing Docker Engine..."
    sudo apt-get install -y ca-certificates gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    sudo mkdir -p /etc/apt/sources.list.d
    VERSION_CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $VERSION_CODENAME stable" \
      | sudo tee /etc/apt/sources.list.d/docker.list
    sudo apt-get update -q
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo usermod -aG docker coder
    sudo service docker start

    # --- Clone repo ---
    cd $HOME
    REPO_DIR="${local.repo_dir}"
    REPO_URL="${local.repo_url}"

    git config --global user.name "${data.coder_parameter.git_name.value != "" ? data.coder_parameter.git_name.value : data.coder_workspace_owner.me.name}"
    git config --global user.email "${data.coder_workspace_owner.me.email}"

    if [ -d "$REPO_DIR/.git" ]; then
      echo "Repo exists, pulling latest..."
      cd "$REPO_DIR" && git pull || echo "Git pull failed, continuing..."
    elif [ -d "$REPO_DIR" ]; then
      rm -rf "$REPO_DIR"
      git clone "$REPO_URL" "$REPO_DIR"
    else
      git clone "$REPO_URL" "$REPO_DIR"
    fi

    cd $HOME/$REPO_DIR

    # --- Write airflow-plugin.env ---
    cp airflow-plugin-test.env airflow-plugin.env
    echo "" >> airflow-plugin.env 
    sed -i '/^LLM_MODEL_ID=/d' airflow-plugin.env
    echo "LLM_MODEL_ID=${data.coder_parameter.llm_model_id.value}" >> airflow-plugin.env

    sed -i '/^ANTHROPIC_API_KEY=/d' airflow-plugin.env
    echo "ANTHROPIC_API_KEY=${data.coder_parameter.anthropic_api_key.value}" >> airflow-plugin.env

    sed -i '/^OPENAI_API_KEY=/d' airflow-plugin.env
    echo "OPENAI_API_KEY=${data.coder_parameter.openai_api_key.value}" >> airflow-plugin.env

    sed -i '/^AWS_ACCESS_KEY_ID=/d' airflow-plugin.env
    echo "AWS_ACCESS_KEY_ID=${data.coder_parameter.aws_access_key_id.value}" >> airflow-plugin.env

    sed -i '/^AWS_SECRET_ACCESS_KEY=/d' airflow-plugin.env
    echo "AWS_SECRET_ACCESS_KEY=${data.coder_parameter.aws_secret_access_key.value}" >> airflow-plugin.env

    # --- Start Airflow ---
    echo "Starting Airflow via 'just airflow'..."
    exec sg docker "cd $HOME/$REPO_DIR && just airflow"

  EOT

  env = {
    GIT_AUTHOR_NAME     = data.coder_workspace_owner.me.name
    GIT_AUTHOR_EMAIL    = data.coder_workspace_owner.me.email
    GIT_COMMITTER_NAME  = data.coder_workspace_owner.me.name
    GIT_COMMITTER_EMAIL = data.coder_workspace_owner.me.email
  }

  metadata {
    display_name = "CPU Usage"
    key          = "0_cpu_usage"
    script       = "coder stat cpu"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "RAM Usage"
    key          = "1_ram_usage"
    script       = "coder stat mem"
    interval     = 10
    timeout      = 1
  }
}

module "code-server" {
  count   = data.coder_workspace.me.start_count
  source  = "registry.coder.com/modules/code-server/coder"
  version = "1.4.4"

  agent_id = coder_agent.main.id
  folder   = "/home/coder/${local.repo_dir}"
  order    = 1
}

resource "coder_app" "airflow" {
  agent_id     = coder_agent.main.id
  slug         = "airflow"
  display_name = "Airflow"
  icon         = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTFzCIuPsPokbP-V0RFFgCRJqcve5gpjJmTtg&s"
  url          = "http://localhost:8088"
  subdomain    = true
  share        = "owner"
  order        = 2
}

resource "docker_volume" "home_volume" {
  name = "coder-${data.coder_workspace.me.id}-home"
  lifecycle {
    ignore_changes = all
  }
  labels {
    label = "coder.owner"
    value = data.coder_workspace_owner.me.name
  }
  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }
}

resource "docker_volume" "docker_data_volume" {
  name = "coder-${data.coder_workspace.me.id}-docker-data"
  lifecycle {
    ignore_changes = all
  }
  labels {
    label = "coder.owner"
    value = data.coder_workspace_owner.me.name
  }
  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }
}

resource "docker_container" "workspace" {
  count    = data.coder_workspace.me.start_count
  image    = "codercom/enterprise-base:ubuntu"
  name     = "coder-${data.coder_workspace_owner.me.name}-${lower(data.coder_workspace.me.name)}"
  hostname = data.coder_workspace.me.name

  privileged = true

  entrypoint = [
    "sh", "-c",
    "mkdir -p /home/coder/${local.repo_dir} && chown -R coder:coder /home/coder/${local.repo_dir} && ${replace(coder_agent.main.init_script, "/localhost|127\\.0\\.0\\.1/", "host.docker.internal")}"
  ]

  env = ["CODER_AGENT_TOKEN=${coder_agent.main.token}"]

  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }

  volumes {
    container_path = "/home/coder"
    volume_name    = docker_volume.home_volume.name
    read_only      = false
  }

  volumes {
    container_path = "/var/lib/docker"
    volume_name    = docker_volume.docker_data_volume.name
    read_only      = false
  }

  labels {
    label = "coder.owner"
    value = data.coder_workspace_owner.me.name
  }
  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }
}