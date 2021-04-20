variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "arn_format" {
  type        = string
  default     = "arn:aws"
  description = "ARN format to be used. May be changed to support deployment in GovCloud/China regions."
}

variable "environment" {
  description = "A name that identifies the environment, used as prefix and for tagging."
  type        = string
}

variable "vpc_id" {
  description = "The target VPC for the docker-machine and runner instances."
  type        = string
}

variable "docker_machine_driver" {
  description = "Name of docker-machine driver. Set it to use a custom docker-machine driver."
  type        = string
  default     = "amazonec2"
}

variable "docker_machine_name" {
  description = "MachineName parameter in [runners.machine] settings. Set it to use a custom name."
  type        = string
  default     = "runner-%s"
}

variable "runners_executor" {
  description = "The executor to use. Currently supports `docker+machine` or `docker`."
  type        = string
  default     = "docker+machine"
}

variable "runners_gitlab_url" {
  description = "URL of the GitLab instance to connect to."
  type        = string
}

variable "runners_token" {
  description = "Token for the runner, will be used in the runner config.toml."
  type        = string
  default     = null
}

variable "runners_limit" {
  description = "Limit for the runners, will be used in the runner config.toml."
  type        = number
  default     = 0
}

variable "runners_concurrent" {
  description = "Concurrent value for the runners, will be used in the runner config.toml."
  type        = number
  default     = 10
}

variable "runners_idle_time" {
  description = "Idle time of the runners, will be used in the runner config.toml."
  type        = number
  default     = 600
}

variable "runners_idle_count" {
  description = "Idle count of the runners, will be used in the runner config.toml."
  type        = number
  default     = 0
}

variable "runners_max_builds" {
  description = "Max builds for each runner after which it will be removed, will be used in the runner config.toml. By default set to 0, no maxBuilds will be set in the configuration."
  type        = number
  default     = 0
}

variable "runners_image" {
  description = "Image to run builds, will be used in the runner config.toml"
  type        = string
  default     = "docker:18.03.1-ce"
}

variable "runners_privileged" {
  description = "Runners will run in privileged mode, will be used in the runner config.toml"
  type        = bool
  default     = true
}

variable "runners_additional_volumes" {
  description = "Additional volumes that will be used in the runner config.toml, e.g Docker socket"
  type        = list(string)
  default     = []
}

variable "runners_shm_size" {
  description = "shm_size for the runners, will be used in the runner config.toml"
  type        = number
  default     = 0
}

variable "runners_pull_policy" {
  description = "pull_policy for the runners, will be used in the runner config.toml"
  type        = string
  default     = "always"
}

variable "runners_machine_autoscaling_periods" {
  description = "runners.machine.autoscaling.Periods: https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runnersmachineautoscaling-sections"
  type        = list(string)
  default     = null
}

variable "runners_machine_autoscaling_idle_count" {
  description = "runners.machine.autoscaling.IdleCount: https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runnersmachineautoscaling-sections"
  type        = number
  default     = null
}

variable "runners_machine_autoscaling_idle_time" {
  description = "runners.machine.autoscaling.IdleTime: https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runnersmachineautoscaling-sections"
  type        = number
  default     = null
}

variable "runners_machine_autoscaling_timezone" {
  description = "runners.machine.autoscaling.Timezone: https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runnersmachineautoscaling-sections"
  type        = string
  default     = null
}

variable "runners_environment_vars" {
  description = "Environment variables during build execution, e.g. KEY=Value, see runner-public example. Will be used in the runner config.toml"
  type        = list(string)
  default     = []
}

variable "runners_pre_build_script" {
  description = "Script to execute in the pipeline just before the build, will be used in the runner config.toml"
  type        = string
  default     = ""
}

variable "runners_post_build_script" {
  description = "Commands to be executed on the Runner just after executing the build, but before executing after_script. "
  type        = string
  default     = ""
}

variable "runners_pre_clone_script" {
  description = "Commands to be executed on the Runner before cloning the Git repository. this can be used to adjust the Git client configuration first, for example. "
  type        = string
  default     = ""
}

variable "runners_request_concurrency" {
  description = "Limit number of concurrent requests for new jobs from GitLab (default 1)"
  type        = number
  default     = 1
}

variable "runners_output_limit" {
  description = "Sets the maximum build log size in kilobytes, by default set to 4096 (4MB)"
  type        = number
  default     = 4096
}

variable "cache_shared" {
  description = "Enables cache sharing between runners, false by default."
  type        = bool
  default     = false
}

variable "enable_ping" {
  description = "Allow ICMP Ping to the ec2 instances."
  type        = bool
  default     = false
}

variable "gitlab_runner_ssh_cidr_blocks" {
  description = "List of CIDR blocks to allow SSH Access to the gitlab runner instance."
  type        = list(string)
  default     = []
}

variable "gitlab_runner_security_group_ids" {
  description = "A list of security group ids that are allowed to access the gitlab runner agent"
  type        = list(string)
  default     = []
}

variable "enable_cloudwatch_logging" {
  description = "Boolean used to enable or disable the CloudWatch logging."
  type        = bool
  default     = true
}

variable "cloudwatch_logging_retention_in_days" {
  description = "Retention for cloudwatch logs. Defaults to unlimited"
  type        = number
  default     = 0
}

variable "tags" {
  description = "Map of tags that will be added to created resources. By default resources will be tagged with name and environment."
  type        = map(string)
  default     = {}
}

variable "agent_tags" {
  description = "Map of tags that will be added to agent EC2 instances."
  type        = map(string)
  default     = {}
}

variable "allow_iam_service_linked_role_creation" {
  description = "Boolean used to control attaching the policy to a runner instance to create service linked roles."
  type        = bool
  default     = true
}

variable "docker_machine_options" {
  description = "List of additional options for the docker machine config. Each element of this list must be a key=value pair. E.g. '[\"amazonec2-zone=a\"]'"
  type        = list(string)
  default     = []
}

variable "overrides" {
  description = "This maps provides the possibility to override some defaults. The following attributes are supported: `name_sg` overwrite the `Name` tag for all security groups created by this module. `name_runner_agent_instance` override the `Name` tag for the ec2 instance defined in the auto launch configuration."
  type        = map(string)

  default = {
    name_sg                    = ""
    name_runner_agent_instance = ""

  }
}

variable "cache_bucket" {
  description = "Bucket to use for GitLab artifacts caching. You should ensure right permissions ahead of time."
  type        = string
}

variable "runners_volumes_tmpfs" {
  type = list(object({
    volume  = string
    options = string
  }))
  default = []
}

variable "runners_services_volumes_tmpfs" {
  type = list(object({
    volume  = string
    options = string
  }))
  default = []
}

variable "log_group_name" {
  description = "Option to override the default name (`environment`) of the log group, requires `enable_cloudwatch_logging = true`."
  default     = null
  type        = string
}

variable "runners" {
  description = "List of [[runners]] groups defined in GitLab runner configuration. Defaults from `local.runners_defaults` apply to all groups. To see what specific values can be set, see definition of `local.runners_defaults` and variables that can be set directly on this module, which make up a base configuration if you don't set any values here."
  default     = [{}]
  type        = list(any)
}


variable "instance_role" {
  description = "Instance role that's used by our EC2 instance via instance profile. Any role policies will be attached to this."
  type = object({
    name = string
  })
}
