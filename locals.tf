locals {
  // Convert list to a string separated and prepend by a comma if docker_machine_options are not empty
  docker_machine_options_string = format("      %s", join(",\n      ", formatlist("%q", var.docker_machine_options)))

  // Ensure off peak is optional
  runners_off_peak_periods_string = var.runners_off_peak_periods == "" ? "" : format("OffPeakPeriods = %s", var.runners_off_peak_periods)

  // Ensure max builds is optional
  runners_max_builds_string = var.runners_max_builds == 0 ? "" : format("MaxBuilds = %d", var.runners_max_builds)

  // custom names for instances and security groups
  name_runner_agent_instance = var.overrides["name_runner_agent_instance"] == "" ? local.tags["Name"] : var.overrides["name_runner_agent_instance"]
  name_sg                    = var.overrides["name_sg"] == "" ? local.tags["Name"] : var.overrides["name_sg"]
  runners_additional_volumes = <<-EOT
  %{~for volume in var.runners_additional_volumes~},"${volume}"%{endfor~}
  EOT
}
