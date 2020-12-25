locals {
  tags = merge(
    {
      "Name" = format("%s", var.environment)
    },
    {
      "Environment" = format("%s", var.environment)
    },
    var.tags,
  )

  agent_tags = merge(
    {
      "Name" = format("%s", local.name_runner_agent_instance)
    },
    {
      "Environment" = format("%s", var.environment)
    },
    var.tags,
    var.agent_tags
  )
}

data "null_data_source" "tags" {
  count = length(local.tags)

  inputs = {
    key                 = element(keys(local.tags), count.index)
    value               = element(values(local.tags), count.index)
    propagate_at_launch = "true"
  }
}

data "null_data_source" "agent_tags" {
  count = length(local.agent_tags)

  inputs = {
    key                 = element(keys(local.agent_tags), count.index)
    value               = element(values(local.agent_tags), count.index)
    propagate_at_launch = "true"
  }
}
