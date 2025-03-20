# Add this for a file browser
# DEPENDENCIES : data,coder_agent
# Change the slug if using for multiple containers
module "filebrowser" {
  count      = data.coder_workspace.me.start_count
  source     = "registry.coder.com/modules/filebrowser/coder"
  version = ">= 1.0.0"
  agent_id   = coder_agent.REPLACE_ME_AGENT_NAME.id
  agent_name = "REPLACE_ME_AGENT_NAME"
}
