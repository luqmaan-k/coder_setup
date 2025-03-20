# This is a docker volumes that has limited storage using the docker plugin docker-volume-loopback 
# Dependecies : data.coder_workspace,data.coder_workspace_owner

resource "docker_volume" "home_volume" {
  name = "coder-${data.coder_workspace.me.id}-home"

  # Use the docker-volume-loopback plugin to limit storage
  driver = "docker-volume-loopback"
  driver_opts = {
    sparse = "true"
    fs     = "ext4"
    size   = "20G"
    uid    = "1000"
    gid    = "1000"
    mode   = "755"
  }

  # Protect the volume from being deleted due to changes in attributes.
  lifecycle {
    ignore_changes = all
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
  # This field becomes outdated if the workspace is renamed but can
  # be useful for debugging or cleaning out dangling volumes.
  labels {
    label = "coder.workspace_name_at_creation"
    value = data.coder_workspace.me.name
  }
}
