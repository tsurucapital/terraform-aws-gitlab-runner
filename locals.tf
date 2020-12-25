locals {

  // Ensure max builds is optional
  runners_max_builds_string = var.runners_max_builds == 0 ? "" : format("MaxBuilds = %d", var.runners_max_builds)

  // custom names for instances and security groups
  name_runner_agent_instance = var.overrides["name_runner_agent_instance"] == "" ? local.tags["Name"] : var.overrides["name_runner_agent_instance"]
  name_sg                    = var.overrides["name_sg"] == "" ? local.tags["Name"] : var.overrides["name_sg"]
  runners_additional_volumes = <<-EOT
  %{~for volume in var.runners_additional_volumes~},"${volume}"%{endfor~}
  EOT
}
