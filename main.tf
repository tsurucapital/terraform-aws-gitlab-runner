data "aws_caller_identity" "current" {}

locals {
  docker_machine_autoscaling_defaults = merge(
    var.runners_machine_autoscaling_periods != null ? { Periods = var.runners_machine_autoscaling_periods } : {},
    var.runners_machine_autoscaling_idle_count != null ? { IdleCount = var.runners_machine_autoscaling_idle_count } : {},
    var.runners_machine_autoscaling_idle_time != null ? { IdleTime = var.runners_machine_autoscaling_idle_time } : {},
    var.runners_machine_autoscaling_timezone != null ? { Timezone = var.runners_machine_autoscaling_timezone } : {},
  )

  runners_defaults = {
    machine_driver             = var.docker_machine_driver
    machine_name               = var.docker_machine_name
    aws_region                 = var.aws_region
    gitlab_url                 = var.runners_gitlab_url
    name                       = var.environment
    additional_volumes         = local.runners_additional_volumes
    token                      = var.runners_token
    executor                   = var.runners_executor
    limit                      = var.runners_limit
    image                      = var.runners_image
    privileged                 = var.runners_privileged
    shm_size                   = var.runners_shm_size
    pull_policy                = var.runners_pull_policy
    idle_count                 = var.runners_idle_count
    idle_time                  = var.runners_idle_time
    max_builds                 = local.runners_max_builds_string
    docker_machine_autoscaling = [local.docker_machine_autoscaling_defaults]
    environment_vars           = jsonencode(var.runners_environment_vars)
    pre_build_script           = var.runners_pre_build_script
    post_build_script          = var.runners_post_build_script
    pre_clone_script           = var.runners_pre_clone_script
    request_concurrency        = var.runners_request_concurrency
    output_limit               = var.runners_output_limit
    volumes_tmpfs              = join(",", [for v in var.runners_volumes_tmpfs : format("\"%s\" = \"%s\"", v["volume"], v["options"])])
    services_volumes_tmpfs     = join(",", [for v in var.runners_services_volumes_tmpfs : format("\"%s\" = \"%s\"", v["volume"], v["options"])])
    docker_machine_options     = var.docker_machine_options
    bucket_name                = var.cache_bucket
    shared_cache               = var.cache_shared
  }

  template_runner_config_header = templatefile("${path.module}/template/runner-config-header.tpl", {
    runners_concurrent = var.runners_concurrent
  })

  # Pre-process any complex runner structures before we merge anything.
  processed_runners = [
    for runner in var.runners : merge(runner,
      contains(keys(runner), "docker_machine_autoscaling") ? {
        docker_machine_autoscaling = [
          for autoscaling in runner.docker_machine_autoscaling :
          # One level "deep" merge, allow parts of the default settings to be
          # overwritten.
          merge(
            local.docker_machine_autoscaling_defaults,
            autoscaling
          )
        ]
      } : {}
    )

  ]

  template_runner_config_runners = join("\n", [
    for runner in local.processed_runners :
    templatefile("${path.module}/template/runner-config-runners.tpl", merge(local.runners_defaults, runner))
  ])

  runner_config = <<-EOF
    ${local.template_runner_config_header}
    ${local.template_runner_config_runners}
  EOF
}

################################################################################
### Trust policy
################################################################################
resource "aws_iam_instance_profile" "instance" {
  name = "${var.environment}-instance-profile"
  role = var.instance_role.name
}

################################################################################
### Service linked policy, optional
################################################################################
resource "aws_iam_policy" "service_linked_role" {
  count = var.allow_iam_service_linked_role_creation ? 1 : 0

  name        = "${var.environment}-service_linked_role"
  path        = "/"
  description = "Policy for creation of service linked roles."

  policy = templatefile("${path.module}/policies/service-linked-role-create-policy.json", {
    arn_format = var.arn_format
  })
}

resource "aws_iam_role_policy_attachment" "service_linked_role" {
  count = var.allow_iam_service_linked_role_creation ? 1 : 0

  role       = var.instance_role.name
  policy_arn = aws_iam_policy.service_linked_role[0].arn
}
