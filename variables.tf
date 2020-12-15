variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "aws_zone" {
  description = "Deprecated. Will be removed in the next major release."
  type        = string
  default     = "a"
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

variable "subnet_id_runners" {
  description = "List of subnets used for hosting the gitlab-runners."
  type        = string
}

variable "subnet_ids_gitlab_runner" {
  description = "Subnet used for hosting the GitLab runner."
  type        = list(string)
}

variable "metrics_autoscaling" {
  description = "A list of metrics to collect. The allowed values are GroupDesiredCapacity, GroupInServiceCapacity, GroupPendingCapacity, GroupMinSize, GroupMaxSize, GroupInServiceInstances, GroupPendingInstances, GroupStandbyInstances, GroupStandbyCapacity, GroupTerminatingCapacity, GroupTerminatingInstances, GroupTotalCapacity, GroupTotalInstances."
  type        = list(string)
  default     = null
}

variable "instance_type" {
  description = "Instance type used for the GitLab runner."
  type        = string
  default     = "t3.micro"
}

variable "runner_instance_ebs_optimized" {
  description = "Enable the GitLab runner instance to be EBS-optimized."
  type        = bool
  default     = true
}

variable "runner_instance_spot_price" {
  description = "By setting a spot price bid price the runner agent will be created via a spot request. Be aware that spot instances can be stopped by AWS."
  type        = string
  default     = null
}

variable "ssh_key_pair" {
  description = "Set this to use existing AWS key pair"
  type        = string
  default     = null
}

variable "docker_machine_instance_type" {
  description = "Instance type used for the instances hosting docker-machine."
  type        = string
  default     = "m5.large"
}

variable "docker_machine_spot_price_bid" {
  description = "Spot price bid."
  type        = string
  default     = "0.06"
}

variable "docker_machine_download_url" {
  description = "Full url pointing to a linux x64 distribution of docker machine. Once set `docker_machine_version` will be ingored. For example the GitLab version, https://gitlab-docker-machine-downloads.s3.amazonaws.com/v0.16.2-gitlab.2/docker-machine."
  type        = string
  default     = ""
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

variable "docker_machine_version" {
  description = "Version of docker-machine. The version will be ingored once `docker_machine_download_url` is set."
  type        = string
  default     = "0.16.2"
}

variable "runners_name" {
  description = "Name of the runner, will be used in the runner config.toml."
  type        = string
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

variable "runners_monitoring" {
  description = "Enable detailed cloudwatch monitoring for spot instances."
  type        = bool
  default     = false
}

variable "runners_ebs_optimized" {
  description = "Enable runners to be EBS-optimized."
  type        = bool
  default     = true
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

variable "runners_root_size" {
  description = "Runner instance root size in GB."
  type        = number
  default     = 16
}

variable "runners_iam_instance_profile_name" {
  description = "IAM instance profile name of the runners, will be used in the runner config.toml"
  type        = string
  default     = ""
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

variable "userdata_pre_install" {
  description = "User-data script snippet to insert before GitLab runner install"
  type        = string
  default     = ""
}

variable "userdata_post_install" {
  description = "User-data script snippet to insert after GitLab runner install"
  type        = string
  default     = ""
}

variable "runners_use_private_address" {
  description = "Restrict runners to the use of a private IP address"
  type        = bool
  default     = true
}

variable "runners_request_spot_instance" {
  description = "Whether or not to request spot instances via docker-machine"
  type        = bool
  default     = true
}

variable "cache_bucket_prefix" {
  description = "Prefix for s3 cache bucket name."
  type        = string
  default     = ""
}

variable "cache_bucket_name_include_account_id" {
  description = "Boolean to add current account ID to cache bucket name."
  type        = bool
  default     = true
}

variable "cache_bucket_versioning" {
  description = "Boolean used to enable versioning on the cache bucket, false by default."
  type        = bool
  default     = false
}

variable "cache_expiration_days" {
  description = "Number of days before cache objects expires."
  type        = number
  default     = 1
}

variable "cache_shared" {
  description = "Enables cache sharing between runners, false by default."
  type        = bool
  default     = false
}

variable "gitlab_runner_version" {
  description = "Version of the GitLab runner."
  type        = string
  default     = "13.1.1"
}

variable "enable_ping" {
  description = "Allow ICMP Ping to the ec2 instances."
  type        = bool
  default     = false
}

variable "enable_gitlab_runner_ssh_access" {
  description = "Enables SSH Access to the gitlab runner instance."
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

variable "runner_tags" {
  description = "Map of tags that will be added to runner EC2 instances."
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

variable "instance_role_json" {
  description = "Default runner instance override policy, expected to be in JSON format."
  type        = string
  default     = ""
}

variable "docker_machine_role_json" {
  description = "Docker machine runner instance override policy, expected to be in JSON format."
  type        = string
  default     = ""
}

variable "ami_filter" {
  description = "List of maps used to create the AMI filter for the Gitlab runner agent AMI. Must resolve to an Amazon Linux 1 or 2 image."
  type        = map(list(string))

  default = {
    name = ["amzn2-ami-hvm-2.*-x86_64-ebs"]
  }
}

variable "ami_owners" {
  description = "The list of owners used to select the AMI of Gitlab runner agent instances."
  type        = list(string)
  default     = ["amazon"]
}

variable "runner_ami_filter" {
  description = "List of maps used to create the AMI filter for the Gitlab runner docker-machine AMI."
  type        = map(list(string))

  default = {
    name = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

variable "runner_ami_owners" {
  description = "The list of owners used to select the AMI of Gitlab runner docker-machine instances."
  type        = list(string)

  # Canonical
  default = ["099720109477"]
}

variable "overrides" {
  description = "This maps provides the possibility to override some defaults. The following attributes are supported: `name_sg` overwrite the `Name` tag for all security groups created by this module. `name_runner_agent_instance` override the `Name` tag for the ec2 instance defined in the auto launch configuration. `name_docker_machine_runners` overrides the `Name` tag spot instances created by the runner agent."
  type        = map(string)

  default = {
    name_sg                     = ""
    name_runner_agent_instance  = ""
    name_docker_machine_runners = ""
  }
}

variable "cache_bucket" {
  description = "Configuration to control the creation of the cache bucket. By default the bucket will be created and used as shared cache. To use the same cache across multiple runners disable the creation of the cache and provide a policy and bucket name. See the public runner example for more details."
  type        = map

  default = {
    create = true
    policy = ""
    bucket = ""
  }
}

variable "enable_runner_user_data_trace_log" {
  description = "Enable bash xtrace for the user data script that creates the EC2 instance for the runner agent. Be aware this could log sensitive data such as you GitLab runner token."
  type        = bool
  default     = false
}

variable "enable_schedule" {
  description = "Flag used to enable/disable auto scaling group schedule for the runner instance. "
  type        = bool
  default     = false
}

variable "schedule_config" {
  description = "Map containing the configuration of the ASG scale-in and scale-up for the runner instance. Will only be used if enable_schedule is set to true. "
  type        = map
  default = {
    scale_in_recurrence  = "0 18 * * 1-5"
    scale_in_count       = 0
    scale_out_recurrence = "0 8 * * 1-5"
    scale_out_count      = 1
  }
}

variable "runner_root_block_device" {
  description = "The EC2 instance root block device configuration. Takes the following keys: `delete_on_termination`, `volume_type`, `volume_size`, `encrypted`, `iops`"
  type        = map(string)
  default     = {}
}

variable "enable_runner_ssm_access" {
  description = "Add IAM policies to the runner agent instance to connect via the Session Manager."
  type        = bool
  default     = false
}

variable "enable_docker_machine_ssm_access" {
  description = "Add IAM policies to the docker-machine instances to connect via the Session Manager."
  type        = bool
  default     = false
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

variable "kms_key_id" {
  description = "KMS key id to encrypted the CloudWatch logs. Ensure CloudWatch has access to the provided KMS key."
  type        = string
  default     = ""
}

variable "enable_kms" {
  description = "Let the module manage a KMS key, logs will be encrypted via KMS. Be-aware of the costs of an custom key."
  type        = bool
  default     = false
}

variable "kms_deletion_window_in_days" {
  description = "Key rotation window, set to 0 for no rotation. Only used when `enable_kms` is set to `true`."
  type        = number
  default     = 7
}

variable "enable_eip" {
  description = "Enable the assignment of an EIP to the gitlab runner instance"
  default     = false
  type        = bool
}

variable "enable_asg_recreation" {
  description = "Enable automatic redeployment of the Runner ASG when the Launch Configs change."
  default     = true
  type        = bool
}

variable "enable_forced_updates" {
  description = "DEPRECATED! and is replaced by `enable_asg_recreation. Setting this variable to true will do the oposite as expected. For backward compatibility the variable will remain some releases. Old desription: Enable automatic redeployment of the Runner ASG when the Launch Configs change."
  default     = null
  type        = string
}

variable "permissions_boundary" {
  description = "Name of permissions boundary policy to attach to AWS IAM roles"
  default     = ""
  type        = string
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

################################################################################
### Variables passed directly to config module.
################################################################################

variable "config_bucket" {
  type        = string
  default     = ""
  description = "If you already have exisiting S3 Bucket for storing configuration files, pass it's name here. Otherwise, leave this field empty and a new, private S3 bucket will be created by this module."
}

variable "config_key" {
  type        = string
  default     = ""
  description = "Path to Gitlab runner configuration on configuration S3 bucket. If left empty, defaults to `config.toml`."
}

variable "cloudtrail_bucket" {
  type        = string
  default     = ""
  description = "If you already have exisiting S3 Bucket for CloudTrail, pass it's name here. Otherwise, leave this field empty and a new CloudTrail S3 bucket will be created by this module."
}

variable "cloudtrail_prefix" {
  type        = string
  default     = ""
  description = "Prefix on S3 bucket for storing CloudTrail logs."
}

variable "post_reload_config" {
  description = "Custom script to be executed after config.toml file is reloaded. If you use `userdata_post_install` to further modify config.toml, you may need to do the same modifications here, to ensure that configuration is always modified in the same way."
  default     = ""
  type        = string
}

variable "extra_files_prefix" {
  type        = string
  default     = "/extra-files/"
  description = "S3 Prefix used before keys of extra files on S3 bucket."
}

variable "extra_files" {
  type        = map(string)
  default     = {}
  description = "Map of additional files to push to Gitlab Runner in { \"/path/from/root\": \"file contents\" } format. Files can be later found at /extra-files path and used in user-data script or in config reload script."
}
