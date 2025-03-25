# This resource is for docker containers
# Dependencies : data.coder_workspace,data.coder_workspace_owner,coder_agent
REPLACE_ME_AGENT_NAME

resource "docker_container" "workspace_REPLACE_ME_WORKSPACE_NUMBER" {
  count = data.coder_workspace.me.start_count
  # MAKE SURE TO USE THE RIGHT IMAGE
  image = "codercom/enterprise-base:ubuntu"
  # Uses lower() to avoid Docker restriction on container names.
  name = "coder-${data.coder_workspace_owner.me.name}-${lower(data.coder_workspace.me.name)}-REPLACE_ME_CONTAINER_NUMBER"
  # Hostname makes the shell more user friendly: coder@my-workspace:~$
  hostname = data.coder_workspace.me.name
  # Use the docker gateway if the access URL is 127.0.0.1
  entrypoint = ["sh", "-c", replace(coder_agent.REPLACE_ME_AGENT_NAME.init_script, "/localhost|127\\.0\\.0\\.1/", "host.docker.internal")]
  env        = ["CODER_AGENT_TOKEN=${coder_agent.REPLACE_ME_AGENT_NAME.token}"]
  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }
  # MAKE SURE TO USE THE CORRECT VOLUMES IF MAPPING MORE THAN ONE HOME VOLUME TO MORE THAN ONE CONTAINER
  volumes {
    container_path = "/home/coder"
    volume_name    = docker_volume.home_volume_REPLACE_ME_HOME_VOLUME_NUMBER.name
    read_only      = false
  }

  # Add labels in Docker to keep track of orphan resources.
  labels {
    label = "coder.owner"
    value = data.coder_workspace_owner.me.name
  }
  labels {
    label = "coder.owner_id"
    value = data.coder_workspace_owner.me.id
  }
  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }
  labels {
    label = "coder.workspace_name"
    value = data.coder_workspace.me.name
  }
}
