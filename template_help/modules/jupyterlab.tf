module "jupyterlab" {
  count    = data.coder_workspace.me.start_count
  source   = "registry.coder.com/modules/jupyterlab/coder"
# This ensures that the latest version of the module gets downloaded, you can also pin the module version to prevent breaking changes in production.
  version = ">= 1.0.0"
  agent_id = coder_agent.REPLACE_ME_AGENT_NAME.id
}
