data "aws_caller_identity" "current" {}

locals {

  template_user_data = templatefile("${path.module}/template/user-data.tpl",
    {
      aws_cli_version          = "2.0.30"
      eip                      = var.enable_eip ? local.template_eip : ""
      logging                  = var.enable_cloudwatch_logging ? local.logging_user_data : ""
      gitlab_runner            = local.template_gitlab_runner
      extra_files_sync_command = module.config.extra_files_sync_command
      user_data_trace_log      = var.enable_runner_user_data_trace_log
  })

  template_eip = templatefile("${path.module}/template/eip.tpl", {
    eip = join(",", aws_eip.gitlab_runner.*.public_ip)
  })

  template_gitlab_runner = templatefile("${path.module}/template/gitlab-runner.tpl",
    {
      gitlab_runner_version       = var.gitlab_runner_version
      docker_machine_version      = var.docker_machine_version
      docker_machine_download_url = var.docker_machine_download_url
      runners_config_s3_uri       = module.config.config_uri
      runners_executor            = var.runners_executor
      pre_install                 = var.userdata_pre_install
      post_install                = var.userdata_post_install
  })

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

resource "aws_autoscaling_group" "gitlab_runner_instance" {
  name                      = var.enable_asg_recreation ? "${aws_launch_configuration.gitlab_runner_instance.name}-asg" : "${var.environment}-as-group"
  vpc_zone_identifier       = var.subnet_ids_gitlab_runner
  min_size                  = "1"
  max_size                  = "1"
  desired_capacity          = "1"
  health_check_grace_period = 0
  launch_configuration      = aws_launch_configuration.gitlab_runner_instance.name
  enabled_metrics           = var.metrics_autoscaling
  tags                      = data.null_data_source.agent_tags.*.outputs
}

resource "aws_autoscaling_schedule" "scale_in" {
  count                  = var.enable_schedule ? 1 : 0
  autoscaling_group_name = aws_autoscaling_group.gitlab_runner_instance.name
  scheduled_action_name  = "scale_in-${aws_autoscaling_group.gitlab_runner_instance.name}"
  recurrence             = var.schedule_config["scale_in_recurrence"]
  min_size               = var.schedule_config["scale_in_count"]
  desired_capacity       = var.schedule_config["scale_in_count"]
  max_size               = var.schedule_config["scale_in_count"]
}

resource "aws_autoscaling_schedule" "scale_out" {
  count                  = var.enable_schedule ? 1 : 0
  autoscaling_group_name = aws_autoscaling_group.gitlab_runner_instance.name
  scheduled_action_name  = "scale_out-${aws_autoscaling_group.gitlab_runner_instance.name}"
  recurrence             = var.schedule_config["scale_out_recurrence"]
  min_size               = var.schedule_config["scale_out_count"]
  desired_capacity       = var.schedule_config["scale_out_count"]
  max_size               = var.schedule_config["scale_out_count"]
}

data "aws_ami" "runner" {
  most_recent = "true"

  dynamic "filter" {
    for_each = var.ami_filter
    content {
      name   = filter.key
      values = filter.value
    }
  }

  owners = var.ami_owners

  count = var.aws_ami_id != null ? 1 : 0
}

locals {
  aws_ami_id = var.aws_ami_id != null ? var.aws_ami_id : data.aws_ami.runner[0].id
}

resource "aws_launch_configuration" "gitlab_runner_instance" {
  name_prefix          = var.environment
  security_groups      = [aws_security_group.runner.id]
  key_name             = var.ssh_key_pair
  image_id             = local.aws_ami_id
  user_data            = local.template_user_data
  instance_type        = var.instance_type
  ebs_optimized        = var.runner_instance_ebs_optimized
  spot_price           = var.runner_instance_spot_price
  iam_instance_profile = aws_iam_instance_profile.instance.name
  dynamic "root_block_device" {
    for_each = [var.runner_root_block_device]
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", true)
      volume_type           = lookup(root_block_device.value, "volume_type", "gp2")
      volume_size           = lookup(root_block_device.value, "volume_size", 8)
      encrypted             = lookup(root_block_device.value, "encrypted", true)
      iops                  = lookup(root_block_device.value, "iops", null)
    }
  }

  associate_public_ip_address = false == var.runners_use_private_address

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
### Create config bucket & save config.toml there
################################################################################

module "config" {
  source = "./modules/config"

  name                          = var.environment
  runner_autoscaling_group_name = aws_autoscaling_group.gitlab_runner_instance.name

  config_content = local.runner_config
  tags           = local.tags

  post_reload_script = var.post_reload_config
  config_bucket      = var.config_bucket
  config_key         = var.config_key
  cloudtrail_bucket  = var.cloudtrail_bucket
  cloudtrail_prefix  = var.cloudtrail_prefix
  extra_files_prefix = var.extra_files_prefix
  extra_files        = var.extra_files
}

resource "aws_iam_role_policy_attachment" "config_bucket" {
  role       = aws_iam_role.instance.name
  policy_arn = module.config.config_iam_policy_arn
}

################################################################################
### Trust policy
################################################################################
resource "aws_iam_instance_profile" "instance" {
  name = "${var.environment}-instance-profile"
  role = aws_iam_role.instance.name
}

resource "aws_iam_role" "instance" {
  name                 = "${var.environment}-instance-role"
  assume_role_policy   = length(var.instance_role_json) > 0 ? var.instance_role_json : templatefile("${path.module}/policies/instance-role-trust-policy.json", {})
  permissions_boundary = var.permissions_boundary == "" ? null : "${var.arn_format}:iam::${data.aws_caller_identity.current.account_id}:policy/${var.permissions_boundary}"
}

################################################################################
### Policies for runner agent instance to create docker machines via spot req.
################################################################################
resource "aws_iam_policy" "instance_docker_machine_policy" {
  name        = "${var.environment}-docker-machine"
  path        = "/"
  description = "Policy for docker machine."

  policy = templatefile("${path.module}/policies/instance-docker-machine-policy.json", {})
}

resource "aws_iam_role_policy_attachment" "instance_docker_machine_policy" {
  role       = aws_iam_role.instance.name
  policy_arn = aws_iam_policy.instance_docker_machine_policy.arn
}

################################################################################
### Policies for runner agent instance to allow connection via Session Manager
################################################################################
resource "aws_iam_policy" "instance_session_manager_policy" {
  count = var.enable_runner_ssm_access ? 1 : 0

  name        = "${var.environment}-session-manager"
  path        = "/"
  description = "Policy session manager."

  policy = templatefile("${path.module}/policies/instance-session-manager-policy.json", {})
}

resource "aws_iam_role_policy_attachment" "instance_session_manager_policy" {
  count = var.enable_runner_ssm_access ? 1 : 0

  role       = aws_iam_role.instance.name
  policy_arn = aws_iam_policy.instance_session_manager_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "instance_session_manager_aws_managed" {
  count = var.enable_runner_ssm_access ? 1 : 0

  role       = aws_iam_role.instance.name
  policy_arn = "${var.arn_format}:iam::aws:policy/AmazonSSMManagedInstanceCore"
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

  role       = aws_iam_role.instance.name
  policy_arn = aws_iam_policy.service_linked_role[0].arn
}

resource "aws_eip" "gitlab_runner" {
  count = var.enable_eip ? 1 : 0
}

################################################################################
### AWS assign EIP
################################################################################
resource "aws_iam_policy" "eip" {
  count = var.enable_eip ? 1 : 0

  name        = "${var.environment}-eip"
  path        = "/"
  description = "Policy for runner to assign EIP"

  policy = templatefile("${path.module}/policies/instance-eip.json", {})
}

resource "aws_iam_role_policy_attachment" "eip" {
  count = var.enable_eip ? 1 : 0

  role       = aws_iam_role.instance.name
  policy_arn = aws_iam_policy.eip[0].arn
}
