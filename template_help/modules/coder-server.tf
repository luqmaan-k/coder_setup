# Add this for coder-server browser
# DEPENDENCIES : data,coder_agent
# Change the slug if using for multiple containers
# See https://registry.coder.com/modules/code-server
module "code-server" {
  count  = data.coder_workspace.me.start_count
  source = "registry.coder.com/modules/code-server/coder"

  # This ensures that the latest version of the module gets downloaded, you can also pin the module version to prevent breaking changes in production.
  version = ">= 1.0.0"

  agent_id = coder_agent.REPLACE_ME_AGENT_NAME.id
  order    = 2
  
  use_cached = true
  install_prefix = "/home/coder/.code_server_cache"
}

